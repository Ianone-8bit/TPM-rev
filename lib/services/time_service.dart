import 'dart:convert';
import 'package:http/http.dart' as http;

class TimeService {
  static final TimeService instance = TimeService();

  Future<Map<String, String>> getWorldTimes() async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse('https://worldtimeapi.org/api/timezone/Asia/Jakarta')),
        http.get(Uri.parse('https://worldtimeapi.org/api/timezone/Asia/Tokyo')),
        http.get(Uri.parse('https://worldtimeapi.org/api/timezone/Europe/London')),
        http.get(Uri.parse('https://worldtimeapi.org/api/timezone/America/New_York')),
      ]);

      String parseTime(http.Response r) {
        final body = jsonDecode(r.body);
        final dt = body['datetime'] as String;
        return dt.substring(11, 19);
      }

      return {
        'Jakarta': parseTime(responses[0]),
        'Tokyo': parseTime(responses[1]),
        'London': parseTime(responses[2]),
        'New York': parseTime(responses[3]),
      };
    } catch (e) {
      // Fallback: use local device time for Jakarta + offset calculation
      final now = DateTime.now().toUtc();
      String fmt(DateTime dt) =>
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';

      return {
        'Jakarta': fmt(now.add(const Duration(hours: 7))),
        'Tokyo': fmt(now.add(const Duration(hours: 9))),
        'London': fmt(now),
        'New York': fmt(now.subtract(const Duration(hours: 4))),
      };
    }
  }
}