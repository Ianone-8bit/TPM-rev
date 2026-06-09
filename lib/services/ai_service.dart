import 'dart:convert';

import 'package:http/http.dart' as http;

class AiService {
  static final AiService instance =
      AiService();

  static const String apiKey =
      "YOUR_API_KEY_HERE";

  Future<String> getHunterAdvice({
    required int level,
    required int exp,
    required int gold,
    required String rank,

  }) async {
    final response =
        await http.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey',
      ),
      headers: {
        'Content-Type':
            'application/json',
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text":
                    """
Kamu adalah AI Hunter Advisor.

Data Hunter:

Rank: $rank
Level: $level
EXP: $exp
Gold: $gold

Daftar mission yang tersedia:

- Walk 1000 Steps
- Read 15 Minutes
- Drink 2L Water
- Shadow Training
- Visit Hunter Outpost
- Walk 10000 Steps
- Complete 5 Missions

ATURAN:
- Jangan mengubah rank hunter.
- Gunakan rank yang diberikan.
- Jangan membuat mission baru.
- Rekomendasi hanya boleh berasal dari daftar mission di atas.

Berikan:

Analisis Rank Hunter :

Kekuatan :

Kelemahan :

Rekomendasi Mission :

Gunakan Bahasa Indonesia.
Maksimal 120 kata.
"""
              }
            ]
          }
        ]
      }),
    )
    .timeout(
      const Duration(seconds: 15),
    );

        print(response.statusCode);
        print(response.body);

    final data =
        jsonDecode(response.body);

    return data["candidates"][0]
            ["content"]["parts"][0]
        ["text"];
  }
}