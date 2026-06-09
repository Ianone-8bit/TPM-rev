import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../models/game_object.dart';
import '../services/auth_service.dart';
import '../services/hunter_service.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() =>
      _GamePageState();
}

class _GamePageState
    extends State<GamePage> {
  final List<GameObject> objects = [];

  Timer? gameTimer;
  Timer? spawnTimer;
  Timer? countdownTimer;

  StreamSubscription<GyroscopeEvent>?
    gyroSubscription;

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
        // Adjust sensitivity for smoother movement
        hunterX += event.y * 20;

        final maxX = containerWidth - 80;

        if (hunterX < 0) {
          hunterX = 0;
        }

        if (hunterX > maxX) {
          hunterX = maxX;
        }
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

countdownTimer = Timer.periodic(
  const Duration(seconds: 1),
  (_) {
    if (!gameRunning) return;

    setState(() {
      timeLeft--;
    });

    if (timeLeft <= 0) {
      finishGame();
    }
  },
);
    spawnTimer?.cancel();

    spawnTimer = Timer.periodic(
      const Duration(
        milliseconds: 800,
      ),
      (_) {
        objects.add(
          GameObject.random(
            containerWidth,
          ),
        );
      },
    );

    gameTimer?.cancel();

    gameTimer = Timer.periodic(
      const Duration(
        milliseconds: 30,
      ),
      (_) {
        updateGame();
      },
    );

    setState(() {});
  }

  Future<void> finishGame() async {
    gameRunning = false;

    gameTimer?.cancel();
    spawnTimer?.cancel();
    countdownTimer?.cancel();

    String username =
        await AuthService.instance
            .currentUser();

    int expReward =
        score > 0 ? score * 2 : 0;

    int goldReward =
        score > 0 ? score : 0;

    await HunterService.instance
        .addExp(
      username,
      expReward,
    );

    await HunterService.instance
        .addGold(
      username,
      goldReward,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title:
              const Text("Game Over"),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Text(
                "Score: $score",
              ),
              Text(
                "+$expReward EXP",
              ),
              Text(
                "+$goldReward Gold",
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child:
                  const Text("OK"),
            ),
          ],
        );
      },
    );

    setState(() {});
  }

  void updateGame() {
    for (int i =
            objects.length - 1;
        i >= 0;
        i--) {
      final object = objects[i];

      object.y += 5;

      bool collision =
    object.y + 30 >= hunterY &&
    object.y <= hunterY + 60 &&
    object.x + 30 >= hunterX &&
    object.x <= hunterX + 60;

      if (collision) {
        if (object.type ==
            ObjectType.equipment) {
          score++;
        } else {
          score--;
        }

        objects.removeAt(i);

        continue;
      }

      if (object.y > 600) {
        objects.removeAt(i);
      }
    }

    setState(() {});
  }

  @override
  Widget build(
      BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),

        Text(
          "Time : $timeLeft",
          style:
              const TextStyle(
            fontSize: 22,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        Text(
          "Score : $score",
          style:
              const TextStyle(
            fontSize: 20,
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        if (!gameRunning)
          ElevatedButton(
            onPressed:
                startGame,
            child: const Text(
              "Start Hunter Loot Rush",
            ),
          ),

        Expanded(
  child: LayoutBuilder(
    builder: (context, constraints) {
      containerWidth = constraints.maxWidth;
      final maxWidth = constraints.maxWidth;
      final hunterSize = 120.0;

      hunterY =
          constraints.maxHeight -
          hunterSize -
          20;

      return Container(
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          border: Border.all(),
        ),
        child: Stack(
            children: [

              Positioned.fill(
                child: Image.asset(
                  'assets/background/dungeon.png',
                  fit: BoxFit.cover,
                ),
              ),
            // OBJECTS (equipment & monster)
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
                      )
              ),

            // HUNTER (FIXED BOUNDARY SAFE)
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
                )
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
}
