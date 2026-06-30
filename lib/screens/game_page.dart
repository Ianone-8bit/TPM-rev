import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../models/game_object.dart';
import '../services/auth_service.dart';
import '../services/hunter_service.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final List<GameObject> objects = [];

  Timer? gameTimer;
  Timer? spawnTimer;
  Timer? countdownTimer;

  StreamSubscription<GyroscopeEvent>? gyroSubscription;

  double hunterX = 60;
  double containerWidth = 350;
  double hunterY = 0;

  int score = 0;
  int timeLeft = 30;

  bool gameRunning = false;

  @override
  void initState() {
    super.initState();

    gyroSubscription = gyroscopeEventStream().listen((event) {
      if (!gameRunning) return;
      setState(() {
        hunterX += event.y * 20;
        final maxX = containerWidth - 80;
        if (hunterX < 0) hunterX = 0;
        if (hunterX > maxX) hunterX = maxX;
      });
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    spawnTimer?.cancel();
    countdownTimer?.cancel();
    gyroSubscription?.cancel();
    super.dispose();
  }

  void startGame() {
    score = 0;
    timeLeft = 30;
    hunterX = (containerWidth - 60) / 2;
    objects.clear();
    gameRunning = true;

    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!gameRunning) return;
      setState(() => timeLeft--);
      if (timeLeft <= 0) finishGame();
    });

    spawnTimer?.cancel();
    spawnTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      objects.add(GameObject.random(containerWidth));
    });

    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      updateGame();
    });

    setState(() {});
  }

  Future<void> finishGame() async {
    gameRunning = false;
    gameTimer?.cancel();
    spawnTimer?.cancel();
    countdownTimer?.cancel();

    String username = await AuthService.instance.currentUser();
    int pointsReward = score > 0 ? score * 2 : 0;
    int coinsReward = score > 0 ? score : 0;

    await HunterService.instance.addExp(username, pointsReward);
    await HunterService.instance.addGold(username, coinsReward);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.sports_esports_rounded,
                    color: Color(0xFF7C3AED), size: 22),
              ),
              const SizedBox(width: 10),
              const Text("Hasil Game",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F1A),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildResultItem("Skor", "$score",
                        Icons.bar_chart_rounded, Colors.white),
                    _buildResultItem("+Points", "$pointsReward",
                        Icons.stars_rounded, const Color(0xFF7C3AED)),
                    _buildResultItem("+Coins", "$coinsReward",
                        Icons.monetization_on_rounded, const Color(0xFF10B981)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                score >= 15
                    ? "Luar biasa! Kamu sangat fokus! 🎉"
                    : score >= 8
                        ? "Bagus! Terus tingkatkan! 💪"
                        : "Coba lagi, kamu pasti bisa! 🌱",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.6), fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text("Main Lagi"),
            ),
          ],
        );
      },
    );

    setState(() {});
  }

  Widget _buildResultItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.5), fontSize: 11)),
      ],
    );
  }

  void updateGame() {
    for (int i = objects.length - 1; i >= 0; i--) {
      final object = objects[i];
      object.y += 5;

      bool collision = object.y + 30 >= hunterY &&
          object.y <= hunterY + 60 &&
          object.x + 30 >= hunterX &&
          object.x <= hunterX + 60;

      if (collision) {
        if (object.type == ObjectType.equipment) {
          score++;
        } else {
          score--;
        }
        objects.removeAt(i);
        continue;
      }

      if (object.y > 600) objects.removeAt(i);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Scoreboard ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: const Color(0xFF1A1A2E),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildScoreChip(Icons.timer_outlined,
                  "Waktu", "$timeLeft s", const Color(0xFF10B981)),
              Container(width: 1, height: 30, color: Colors.white12),
              _buildScoreChip(Icons.bar_chart_rounded,
                  "Skor", "$score", const Color(0xFF7C3AED)),
              Container(width: 1, height: 30, color: Colors.white12),
              _buildScoreChip(Icons.stars_rounded,
                  "Est. Points", "${score > 0 ? score * 2 : 0}", Colors.amber),
            ],
          ),
        ),

        if (!gameRunning)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ElevatedButton.icon(
              onPressed: startGame,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text("Mulai Focus Rush",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
            ),
          ),

        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              containerWidth = constraints.maxWidth;
              final maxWidth = constraints.maxWidth;
              const hunterSize = 120.0;

              hunterY = constraints.maxHeight - hunterSize - 20;

              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF0F0F1A),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/background/dungeon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Overlay hint when not playing
                    if (!gameRunning)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black45,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.sports_esports_rounded,
                                    color: Colors.white.withOpacity(0.3),
                                    size: 60),
                                const SizedBox(height: 12),
                                Text(
                                  "Tekan Mulai untuk bermain\nMiringkan HP untuk bergerak",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    // Objects
                    for (final object in objects)
                      Positioned(
                        left: object.x,
                        top: object.y,
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: Image.asset(
                            object.type == ObjectType.equipment
                                ? 'assets/equipment/dagger.png'
                                : 'assets/monster/monster.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    // Player character
                    Positioned(
                      bottom: 20,
                      left: hunterX.clamp(0.0, maxWidth - hunterSize),
                      child: SizedBox(
                        width: hunterSize,
                        height: hunterSize,
                        child: Image.asset(
                          'assets/hunter/hunter.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScoreChip(
      IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.4), fontSize: 10)),
      ],
    );
  }
}
