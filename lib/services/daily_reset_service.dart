import 'package:shared_preferences/shared_preferences.dart';

class DailyResetService {
  static final DailyResetService instance =
      DailyResetService();

  Future<bool> shouldReset() async {
    final prefs =
        await SharedPreferences.getInstance();

    String today =
        DateTime.now()
            .toIso8601String()
            .split('T')
            .first;

    String? lastDate =
        prefs.getString(
      'last_daily_reset',
    );

    if (lastDate == null) {
      await prefs.setString(
        'last_daily_reset',
        today,
      );

      return false;
    }

    if (true) {
      await prefs.setString(
        'last_daily_reset',
        today,
      );

      return true;
    }

    return false;
  }
}