import 'dart:convert';

import 'package:http/http.dart' as http;

class TimeService {
  static final TimeService instance =
      TimeService();

  Future<Map<String, String>> getWorldTimes() async {
    final tokyoResponse =
        await http.get(
      Uri.parse(
        'https://worldtimeapi.org/api/timezone/Asia/Tokyo',
      ),
    );

    final londonResponse =
        await http.get(
      Uri.parse(
        'https://worldtimeapi.org/api/timezone/Europe/London',
      ),
    );

    final newYorkResponse =
        await http.get(
      Uri.parse(
        'https://worldtimeapi.org/api/timezone/America/New_York',
      ),
    );

    final tokyo =
        jsonDecode(tokyoResponse.body);

    final london =
        jsonDecode(londonResponse.body);

    final newYork =
        jsonDecode(newYorkResponse.body);

    return {
      "Tokyo":
          tokyo["datetime"]
              .substring(11, 19),
      "London":
          london["datetime"]
              .substring(11, 19),
      "New York":
          newYork["datetime"]
              .substring(11, 19),
    };
  }
}