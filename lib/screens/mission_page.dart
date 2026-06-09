import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/mission.dart';
import '../../services/auth_service.dart';
import '../../services/hunter_service.dart';
import '../../services/mission_db_service.dart';
import '../../services/mission_service.dart';
import '../../services/sensor_service.dart';
import '../../services/location_service.dart';
import '../../services/outpost_service.dart';
import '../../services/notification_service.dart';

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
        setState(() {
          shakeProgress = count;
        });

        _checkMissionCompletion(6, count >= 20, "Shadow Training reward is ready to claim!");
      },
      onStepChanged: (count) async {
        if (!mounted) return;
        setState(() {
          stepProgress = count;
        });

        _checkMissionCompletion(1, count >= 1000, "Walk 1000 Steps reward is ready to claim!");
        _checkMissionCompletion(4, count >= 10000, "Walk 10000 Steps reward is ready to claim!");
      },
    );
  }

  Future<void> _checkMissionCompletion(int missionId, bool conditionMet, String notificationBody) async {
    try {
      final mission = missions.firstWhere((m) => m.id == missionId);
      if (conditionMet && mission.status == MissionStatus.accepted) {
        setState(() {
          mission.status = MissionStatus.completed;
        });
        await NotificationService.instance.showNotification(
          title: "Mission Completed",
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

    if (mounted) {
      setState(() {
        currentDistance = distance;
      });
    }

    _checkMissionCompletion(7, distance <= 20, "Visit Hunter Outpost reward is ready to claim!");
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
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> claimReward(Mission mission) async {
    String username = await AuthService.instance.currentUser();
    await HunterService.instance.addExp(username, mission.rewardExp);
    await HunterService.instance.addGold(username, mission.rewardGold);
    await MissionDbService.instance.saveStatus(mission.id, 'claimed');

    setState(() {
      mission.status = MissionStatus.claimed;
    });
    await NotificationService.instance.showNotification(
      title: "Reward Claimed",
      body: "+${mission.rewardExp} EXP | +${mission.rewardGold} Gold",
    );
  }

  Widget buildMissionCard(Mission mission) {
    String buttonText = '';
    VoidCallback? action;

    switch (mission.status) {
      case MissionStatus.available:
        buttonText = "Accept";
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
        if (mission.id == 7) { // Outpost
          buttonText = "${currentDistance.toStringAsFixed(0)} m";
          action = () async { await checkLocationMission(); };
        } else if (mission.id == 6) { // Shadow Training
          buttonText = "Progress $shakeProgress / 20";
          action = null;
        } else if (mission.id == 1) { // Walk 1000
          buttonText = "Steps: $stepProgress / 1000";
          action = null;
        } else if (mission.id == 4) { // Walk 10000
          buttonText = "Steps: $stepProgress / 10000";
          action = null;
        } else if (mission.id == 3) { // Water
          buttonText = "Drink Glass ($waterGlasses/8)";
          action = () {
            setState(() {
              waterGlasses++;
              if (waterGlasses >= 8) {
                _checkMissionCompletion(3, true, "Hydration mission complete!");
              }
            });
          };
        } else if (mission.id == 2) { // Read
          if (isReading) {
            buttonText = "Reading... ${readingSecondsLeft ~/ 60}:${(readingSecondsLeft % 60).toString().padLeft(2, '0')}";
            action = null;
          } else {
            buttonText = "Start Timer";
            action = () {
              setState(() {
                isReading = true;
              });
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
                    _checkMissionCompletion(2, true, "Reading session completed!");
                  }
                });
              });
            };
          }
        } else {
          // Fallback (e.g., Complete 5 Missions)
          buttonText = "Complete";
          action = () async {
            _checkMissionCompletion(mission.id, true, "${mission.title} completed!");
          };
        }
        break;

      case MissionStatus.completed:
        buttonText = "Claim";
        action = () { claimReward(mission); };
        break;

      case MissionStatus.claimed:
        buttonText = "Claimed";
        action = null;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mission.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 5),
            Text(mission.description),
            const SizedBox(height: 10),
            Text("Reward: ${mission.rewardExp} EXP | ${mission.rewardGold} Gold", style: const TextStyle(color: Color(0xFF00E5FF))),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: action,
              child: Text(buttonText),
            ),
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
        const Text("Daily Missions", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 10),
        ...daily.map(buildMissionCard),
        const SizedBox(height: 20),
        const Text("Weekly Missions", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 10),
        ...weekly.map(buildMissionCard),
      ],
    );
  }
}