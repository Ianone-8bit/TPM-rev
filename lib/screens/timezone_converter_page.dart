import 'package:flutter/material.dart';
import '../services/time_service.dart';

class TimeConverterPage extends StatefulWidget {
  const TimeConverterPage({super.key});

  @override
  State<TimeConverterPage> createState() => _TimeConverterPageState();
}

class _TimeConverterPageState extends State<TimeConverterPage> {
  Map<String, String>? times;
  bool isLoading = false;

  static const List<Map<String, dynamic>> cityInfo = [
    {
      'key': 'Jakarta',
      'label': 'Jakarta',
      'flag': '🇮🇩',
      'timezone': 'WIB (UTC+7)',
      'color': Color(0xFF10B981),
    },
    {
      'key': 'Tokyo',
      'label': 'Tokyo',
      'flag': '🇯🇵',
      'timezone': 'JST (UTC+9)',
      'color': Color(0xFFEF4444),
    },
    {
      'key': 'London',
      'label': 'London',
      'flag': '🇬🇧',
      'timezone': 'GMT (UTC+0/+1)',
      'color': Color(0xFF7C3AED),
    },
    {
      'key': 'New York',
      'label': 'New York',
      'flag': '🇺🇸',
      'timezone': 'EST (UTC-5/-4)',
      'color': Color(0xFF06B6D4),
    },
  ];

  @override
  void initState() {
    super.initState();
    loadTimes();
  }

  Future<void> loadTimes() async {
    setState(() => isLoading = true);
    final data = await TimeService.instance.getWorldTimes();
    setState(() {
      times = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Zona Waktu Dunia"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF7C3AED).withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.public_rounded,
                      color: Color(0xFF7C3AED), size: 18),
                  const SizedBox(width: 10),
                  Text(
                    "Waktu saat ini di berbagai kota dunia",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7), fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // City cards
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
                ),
              )
            else if (times == null)
              const Expanded(
                child: Center(
                  child: Text("Gagal memuat data waktu",
                      style: TextStyle(color: Colors.white54)),
                ),
              )
            else
              Expanded(
                child: ListView(
                  children: cityInfo.map((city) {
                    final timeStr =
                        times![city['key'] as String] ?? '--:--';
                    final color = city['color'] as Color;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: color.withOpacity(0.3)),
                            ),
                            child: Center(
                              child: Text(
                                city['flag'] as String,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  city['label'] as String,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  city['timezone'] as String,
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.45),
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            timeStr,
                            style: TextStyle(
                              color: color,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFeatures: const [],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: isLoading ? null : loadTimes,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text("Perbarui Waktu"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}