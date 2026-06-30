import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'dashboard_page.dart';
import 'game_page.dart';
import 'login_page.dart';
import 'map_page.dart';
import 'mission_page.dart';
import 'profile_page.dart';
import '../services/daily_reset_service.dart';
import '../services/mission_db_service.dart';
import '../services/notification_service.dart';
import '../services/weekly_reset_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    DashboardPage(),
    MissionPage(),
    MapPage(),
    GamePage(),
    ProfilePage(),
  ];

  final List<String> titles = [
    'Dashboard',
    'Habits',
    'Peta',
    'Mini Game',
    'Profil',
  ];

  Future<void> checkWeeklyReset() async {
    bool resetNeeded = await WeeklyResetService.instance.shouldReset();
    if (!resetNeeded) return;

    await MissionDbService.instance.resetWeeklyMissions();
    await NotificationService.instance.showNotification(
      title: "Goals Mingguan Baru!",
      body: "Goals minggu ini sudah direset. Semangat! 💪",
    );
    if (mounted) setState(() {});
  }

  Future<void> checkDailyReset() async {
    bool resetNeeded = await DailyResetService.instance.shouldReset();
    if (!resetNeeded) return;

    await MissionDbService.instance.resetDailyMissions();
    if (mounted) setState(() {});

    await NotificationService.instance.showNotification(
      title: "Hari Baru, Semangat Baru! 🌅",
      body: "Kebiasaan harian sudah direset. Yuk mulai!",
    );
  }

  @override
  void initState() {
    super.initState();
    checkDailyReset();
    checkWeeklyReset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currentIndex == 0) ...[
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF10B981)],
                  ),
                ),
                child: const Icon(Icons.trending_up_rounded,
                    size: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              currentIndex == 0 ? 'GrowUp' : titles[currentIndex],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: pages[currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFF7C3AED),
            unselectedItemColor: Colors.white38,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            onTap: (index) => setState(() => currentIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle_outline),
                activeIcon: Icon(Icons.check_circle_rounded),
                label: 'Habits',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map_rounded),
                label: 'Peta',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.sports_esports_outlined),
                activeIcon: Icon(Icons.sports_esports_rounded),
                label: 'Game',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}