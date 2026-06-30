import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static final AiService instance = AiService();

  // ─────────────────────────────────────────────────
  // 🔑 API KEY GROQ — Sudah diatur
  // Untuk mengganti key, ubah nilai di bawah ini.
  // Dapatkan key baru di: https://console.groq.com/keys
  // ─────────────────────────────────────────────────
  static const String _apiKey = "ISI_GROQ_KEY_DISINI";

  // Model Groq yang digunakan (bisa diganti)
  // Pilihan: llama-3.3-70b-versatile, llama3-8b-8192, mixtral-8x7b-32768
  static const String _model = "llama-3.3-70b-versatile";

  Future<String> getHunterAdvice({
    required int level,
    required int exp,
    required int gold,
    required String rank,
  }) async {
    if (_apiKey.trim().isEmpty || _apiKey == "ISI_GROQ_KEY_DISINI") {
      return "⚠️ API Key Groq belum diatur.\n\n"
          "Buka file: lib/services/ai_service.dart\n"
          "Isi variabel _apiKey dengan key dari:\n"
          "https://console.groq.com/keys";
    }

    try {
      final response = await http
          .post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              "model": _model,
              "messages": [
                {
                  "role": "system",
                  "content":
                      "Kamu adalah AI Growth Advisor untuk aplikasi self-development bernama GrowUp. "
                          "Berikan saran pengembangan diri yang memotivasi, praktis, dan positif dalam Bahasa Indonesia. "
                          "Maksimal 150 kata. Gunakan emoji secukupnya agar terasa ramah."
                },
                {
                  "role": "user",
                  "content": """
Data pengguna GrowUp:
- Badge: $rank (Level $level)
- Points: $exp/100
- Coins: $gold

Kebiasaan tersedia di aplikasi:
1. Jalan 1.000 Langkah (Harian)
2. Membaca 15 Menit (Harian)
3. Minum 8 Gelas Air (Harian)
4. Jump Training / Lompat 20x (Harian)
5. Kunjungi Check-in Spot (Harian)
6. Jalan 10.000 Langkah (Mingguan)
7. Selesaikan 5 Kebiasaan (Mingguan)

Berikan analisis dengan format:
📊 Analisis Perkembangan:
💪 Kekuatan:
🎯 Area Peningkatan:
✅ Rekomendasi Kebiasaan (pilih dari daftar di atas):

Gunakan Bahasa Indonesia. Maksimal 150 kata.
"""
                }
              ],
              "max_tokens": 400,
              "temperature": 0.7,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choices = data["choices"] as List?;
        if (choices == null || choices.isEmpty) {
          return "Tidak ada respons dari AI. Coba lagi.";
        }
        final text = choices[0]["message"]["content"] as String?;
        return text?.trim() ?? "Respons AI tidak tersedia.";
      } else if (response.statusCode == 401) {
        return "❌ API Key Groq tidak valid.\n\n"
            "Periksa kembali key di:\nhttps://console.groq.com/keys";
      } else if (response.statusCode == 429) {
        return "⏳ Terlalu banyak permintaan. Coba lagi dalam beberapa saat.";
      } else if (response.statusCode == 503) {
        return "🔧 Server Groq sedang sibuk. Coba lagi sebentar.";
      } else {
        // Coba parse pesan error dari Groq
        try {
          final err = jsonDecode(response.body);
          final msg = err["error"]?["message"] ?? "Unknown error";
          return "❌ Groq Error (${response.statusCode}): $msg";
        } catch (_) {
          return "❌ Gagal mendapat respons (${response.statusCode}).";
        }
      }
    } on http.ClientException {
      return "📶 Tidak ada koneksi internet. Hubungkan perangkat ke internet dan coba lagi.";
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return "⏱️ Koneksi timeout. Pastikan internet stabil dan coba lagi.";
      }
      return "❌ Terjadi kesalahan: $e";
    }
  }
}