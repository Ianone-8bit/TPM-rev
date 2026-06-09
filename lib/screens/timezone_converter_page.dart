import 'package:flutter/material.dart';

import '../services/time_service.dart';

class TimeConverterPage extends StatefulWidget {
  const TimeConverterPage({super.key});

  @override
  State<TimeConverterPage> createState() =>
      _TimeConverterPageState();
}

class _TimeConverterPageState
    extends State<TimeConverterPage> {
  Map<String, String>? times;

  @override
  void initState() {
    super.initState();
    loadTimes();
  }

  Future<void> loadTimes() async {
    final data =
        await TimeService.instance
            .getWorldTimes();

    setState(() {
      times = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "World Time Converter",
        ),
      ),
      body: times == null
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : Padding(
              padding:
                  const EdgeInsets.all(
                16,
              ),
              child: Column(
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.location_city,
                      ),
                      title:
                          const Text("Tokyo"),
                      trailing: Text(
                        times!["Tokyo"]!,
                      ),
                    ),
                  ),

                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.location_city,
                      ),
                      title:
                          const Text("London"),
                      trailing: Text(
                        times!["London"]!,
                      ),
                    ),
                  ),

                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.location_city,
                      ),
                      title: const Text(
                        "New York",
                      ),
                      trailing: Text(
                        times!["New York"]!,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  ElevatedButton.icon(
                    onPressed:
                        loadTimes,
                    icon: const Icon(
                      Icons.refresh,
                    ),
                    label: const Text(
                      "Refresh",
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}