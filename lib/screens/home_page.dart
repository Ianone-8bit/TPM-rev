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
  State<HomePage> createState() =>
      _HomePageState();
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
    'Mission',
    'Map',
    'Mini Game',
    'Profile',
  ];

  // Logout moved to profile page

  Future<void> checkWeeklyReset() async {
  bool resetNeeded =
      await WeeklyResetService.instance
          .shouldReset();

  if (!resetNeeded) return;

  await MissionDbService.instance
      .resetWeeklyMissions();

  await NotificationService.instance
      .showNotification(
    title: "Weekly Quest Reset",
    body:
        "New weekly missions are available!",
  );

  if (mounted) {
    setState(() {});
  }
}

  Future<void> checkDailyReset() async {
  bool resetNeeded =
      await DailyResetService.instance
          .shouldReset();

  if (!resetNeeded) return;

  await MissionDbService.instance
      .resetDailyMissions();

  if (mounted) {
    setState(() {});
  }

  await NotificationService.instance
      .showNotification(
    title: "Daily Quest Reset",
    body:
        "Hunter, new daily missions are available!",
  );
}

  @override
  void initState(){
    super.initState();

    checkDailyReset();
    checkWeeklyReset();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[currentIndex], style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: const Color(0xFF00E5FF),
        unselectedItemColor: Colors.white54,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Mission',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports),
            label: 'Game',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}