import 'dart:convert';

import 'package:http/http.dart'
    as http;

class CurrencyService {
  static final CurrencyService
      instance =
      CurrencyService();

  Future<Map<String, double>>
      getRates() async {
    final response =
        await http.get(
      Uri.parse(
        'https://open.er-api.com/v6/latest/USD',
      ),
    );

    final data =
        jsonDecode(response.body);

    return {
      "USD": 1.0,
      "IDR":
          (data["rates"]["IDR"] as num)
              .toDouble(),
      "JPY":
          (data["rates"]["JPY"] as num)
              .toDouble(),
    };
  }
}