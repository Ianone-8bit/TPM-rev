import 'package:shared_preferences/shared_preferences.dart';

class WeeklyResetService {
  static final WeeklyResetService instance =
      WeeklyResetService();

  Future<bool> shouldReset() async {
    final prefs =
        await SharedPreferences.getInstance();

    final now = DateTime.now();

    final currentWeek =
        "${now.year}-${weekNumber(now)}";

    final savedWeek =
        prefs.getString(
      'last_weekly_reset',
    );

    if (savedWeek == null) {
      await prefs.setString(
        'last_weekly_reset',
        currentWeek,
      );

      return false;
    }

    if (savedWeek != currentWeek) {
      await prefs.setString(
        'last_weekly_reset',
        currentWeek,
      );

      return true;
    }

    return false;
  }

  int weekNumber(DateTime date) {
    final firstDay =
        DateTime(date.year, 1, 1);

    return ((date
                    .difference(
                      firstDay,
                    )
                    .inDays +
                firstDay.weekday -
                1) ~/
            7) +
        1;
  }
}