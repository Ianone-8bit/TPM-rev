import 'dart:async';
import 'package:flutter/material.dart';

import '../models/mission.dart';
import '../services/auth_service.dart';
import '../services/hunter_service.dart';
import '../services/mission_db_service.dart';
import '../services/mission_service.dart';
import '../services/sensor_service.dart';
import '../services/location_service.dart';
import '../services/outpost_service.dart';
import '../services/notification_service.dart';

class MissionPage extends StatefulWidget {
  const MissionPage({super.key});

  @override
  State<MissionPage> createState() => _MissionPageState();
}

class _MissionPageState extends State<MissionPage> {
  final missions = MissionService.instance.missions;

  int shakeProgress = 0;
  int stepProgress = 0;
  double currentDistance = 999999;

  // Water Tracker
  int waterGlasses = 0;

  // Reading Timer
  int readingSecondsLeft = 15 * 60;
  Timer? readingTimer;
  bool isReading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkLocationMission();
  }

  @override
  void initState() {
    super.initState();
    loadMissionStatus();
    checkLocationMission();

    SensorService.instance.startListening(
      onShakeChanged: (count) async {
        if (!mounted) return;
        setState(() => shakeProgress = count);
        _checkMissionCompletion(
            6, count >= 20, "Jump Training selesai! Reward siap diklaim.");
      },
      onStepChanged: (count) async {
        if (!mounted) return;
        setState(() => stepProgress = count);
        _checkMissionCompletion(
            1, count >= 1000, "1000 Langkah tercapai! Reward siap diklaim.");
        _checkMissionCompletion(
            4, count >= 10000, "10.000 Langkah tercapai! Reward siap diklaim.");
      },
    );
  }

  Future<void> _checkMissionCompletion(
      int missionId, bool conditionMet, String notificationBody) async {
    try {
      final mission = missions.firstWhere((m) => m.id == missionId);
      if (conditionMet && mission.status == MissionStatus.accepted) {
        setState(() => mission.status = MissionStatus.completed);
        await NotificationService.instance.showNotification(
          title: "Aktivitas Selesai! 🎉",
          body: notificationBody,
        );
        await MissionDbService.instance.saveStatus(mission.id, 'completed');
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    SensorService.instance.stop();
    readingTimer?.cancel();
    super.dispose();
  }

  Future<void> checkLocationMission() async {
    final position = await LocationService.instance.getCurrentLocation();
    if (position == null) return;

    final outpost = await OutpostService.instance.getOrCreateOutpost(position);
    double distance = LocationService.instance.calculateDistance(
      position.latitude,
      position.longitude,
      outpost['lat']!,
      outpost['lon']!,
    );

    if (mounted) setState(() => currentDistance = distance);

    _checkMissionCompletion(
        7, distance <= 20, "Check-in Spot dikunjungi! Reward siap diklaim.");
  }

  Future<void> loadMissionStatus() async {
    for (var mission in missions) {
      String? status = await MissionDbService.instance.getStatus(mission.id);
      if (status == null) continue;

      switch (status) {
        case 'accepted':
          mission.status = MissionStatus.accepted;
          break;
        case 'completed':
          mission.status = MissionStatus.completed;
          break;
        case 'claimed':
          mission.status = MissionStatus.claimed;
          break;
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> claimReward(Mission mission) async {
    String username = await AuthService.instance.currentUser();
    await HunterService.instance.addExp(username, mission.rewardExp);
    await HunterService.instance.addGold(username, mission.rewardGold);
    await MissionDbService.instance.saveStatus(mission.id, 'claimed');

    setState(() => mission.status = MissionStatus.claimed);
    await NotificationService.instance.showNotification(
      title: "Reward Diklaim! 🎁",
      body: "+${mission.rewardExp} Points | +${mission.rewardGold} Coins",
    );
  }

  Color _statusColor(MissionStatus status) {
    switch (status) {
      case MissionStatus.available:
        return Colors.white38;
      case MissionStatus.accepted:
        return const Color(0xFF7C3AED);
      case MissionStatus.completed:
        return const Color(0xFF10B981);
      case MissionStatus.claimed:
        return Colors.white24;
    }
  }

  String _statusLabel(MissionStatus status) {
    switch (status) {
      case MissionStatus.available:
        return 'Tersedia';
      case MissionStatus.accepted:
        return 'Sedang Berjalan';
      case MissionStatus.completed:
        return 'Selesai ✓';
      case MissionStatus.claimed:
        return 'Sudah Diklaim';
    }
  }

  Widget buildMissionCard(Mission mission) {
    String buttonText = '';
    VoidCallback? action;

    switch (mission.status) {
      case MissionStatus.available:
        buttonText = "Mulai";
        action = () async {
          await MissionDbService.instance.saveStatus(mission.id, 'accepted');
          setState(() {
            mission.status = MissionStatus.accepted;
            if (mission.id == 6) {
              SensorService.instance.reset();
              shakeProgress = 0;
            }
          });
        };
        break;

      case MissionStatus.accepted:
        if (mission.id == 7) {
          buttonText = "${currentDistance.toStringAsFixed(0)} m";
          action = () async => checkLocationMission();
        } else if (mission.id == 6) {
          buttonText = "Lompat $shakeProgress / 20";
          action = null;
        } else if (mission.id == 1) {
          buttonText = "Langkah: $stepProgress / 1.000";
          action = null;
        } else if (mission.id == 4) {
          buttonText = "Langkah: $stepProgress / 10.000";
          action = null;
        } else if (mission.id == 3) {
          buttonText = "Minum Segelas ($waterGlasses/8)";
          action = () {
            setState(() {
              waterGlasses++;
              if (waterGlasses >= 8) {
                _checkMissionCompletion(3, true, "Minum air 8 gelas selesai!");
              }
            });
          };
        } else if (mission.id == 2) {
          if (isReading) {
            buttonText =
                "Membaca... ${readingSecondsLeft ~/ 60}:${(readingSecondsLeft % 60).toString().padLeft(2, '0')}";
            action = null;
          } else {
            buttonText = "Mulai Timer";
            action = () {
              setState(() => isReading = true);
              readingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
                if (!mounted) {
                  timer.cancel();
                  return;
                }
                setState(() {
                  readingSecondsLeft--;
                  if (readingSecondsLeft <= 0) {
                    timer.cancel();
                    isReading = false;
                    _checkMissionCompletion(2, true, "Sesi membaca selesai!");
                  }
                });
              });
            };
          }
        } else {
          buttonText = "Tandai Selesai";
          action = () async =>
              _checkMissionCompletion(mission.id, true, "${mission.title} selesai!");
        }
        break;

      case MissionStatus.completed:
        buttonText = "Klaim Reward";
        action = () => claimReward(mission);
        break;

      case MissionStatus.claimed:
        buttonText = "Sudah Diklaim";
        action = null;
        break;
    }

    final statusColor = _statusColor(mission.status);
    final isClaimed = mission.status == MissionStatus.claimed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isClaimed ? Colors.white38 : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mission.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: isClaimed
                              ? Colors.white24
                              : Colors.white.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    _statusLabel(mission.status),
                    style: TextStyle(
                        color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.stars_rounded,
                    color: const Color(0xFF7C3AED).withOpacity(isClaimed ? 0.4 : 1),
                    size: 16),
                const SizedBox(width: 4),
                Text(
                  "+${mission.rewardExp} Points",
                  style: TextStyle(
                      color: isClaimed
                          ? Colors.white24
                          : const Color(0xFF7C3AED),
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Icon(Icons.monetization_on_rounded,
                    color: const Color(0xFF10B981).withOpacity(isClaimed ? 0.4 : 1),
                    size: 16),
                const SizedBox(width: 4),
                Text(
                  "+${mission.rewardGold} Coins",
                  style: TextStyle(
                      color: isClaimed
                          ? Colors.white24
                          : const Color(0xFF10B981),
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (!isClaimed) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: action,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mission.status == MissionStatus.completed
                        ? const Color(0xFF10B981)
                        : const Color(0xFF7C3AED),
                    disabledBackgroundColor: const Color(0xFF7C3AED).withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(buttonText,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daily = missions.where((m) => m.type == MissionType.daily).toList();
    final weekly = missions.where((m) => m.type == MissionType.weekly).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Daily header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.wb_sunny_outlined,
                  color: Color(0xFF10B981), size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Kebiasaan Harian",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text("Reset setiap hari",
                    style: TextStyle(fontSize: 12, color: Colors.white38)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...daily.map(buildMissionCard),

        const SizedBox(height: 20),

        // Weekly header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.calendar_month_outlined,
                  color: Color(0xFF7C3AED), size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Goals Mingguan",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text("Reset setiap minggu",
                    style: TextStyle(fontSize: 12, color: Colors.white38)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...weekly.map(buildMissionCard),
        const SizedBox(height: 16),
      ],
    );
  }
}