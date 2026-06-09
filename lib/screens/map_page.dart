import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../services/outpost_service.dart';

import '../services/location_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() =>
      _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Position? position;

  // sementara target tetap
  LatLng? hunterOutpost;

  double distance = 0;

  @override
  void initState() {
    super.initState();
    loadLocation();
  }

  Future<void> loadLocation() async {
  final current =
      await LocationService.instance
          .getCurrentLocation();

  if (current == null) return;

  final outpost =
      await OutpostService.instance
          .getOrCreateOutpost(
    current,
  );

  hunterOutpost = LatLng(
    outpost['lat']!,
    outpost['lon']!,
  );

  distance = LocationService.instance
      .calculateDistance(
    current.latitude,
    current.longitude,
    hunterOutpost!.latitude,
    hunterOutpost!.longitude,
  );

  if (!mounted) return;

  setState(() {
    position = current;
  });
}

  @override
  Widget build(BuildContext context) {
    if (position == null ||
    hunterOutpost == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final currentLocation = LatLng(
      position!.latitude,
      position!.longitude,
    );

    return Column(
      children: [
        Expanded(
          child: FlutterMap(
            options: MapOptions(
              initialCenter:
                  currentLocation,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName:
                    'com.example.hunter_system',
              ),

              MarkerLayer(
                markers: [
                  Marker(
                    point:
                        currentLocation,
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.person_pin_circle,
                      size: 45,
                      color: Colors.blue,
                    ),
                  ),

                  Marker(
                    point:
                        hunterOutpost!,
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.flag,
                      size: 45,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Container(
          padding:
              const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                "Hunter Outpost",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                "Distance : ${distance.toStringAsFixed(0)} meters",
              ),

              const SizedBox(
                height: 10,
              ),

              Column(
  children: [
    ElevatedButton(
      onPressed: loadLocation,
      child: const Text(
        "Refresh Location",
      ),
    ),

    const SizedBox(height: 10),

    ElevatedButton(
      onPressed: () async {
        await OutpostService.instance
            .resetOutpost();

        await loadLocation();
      },
      child: const Text(
        "Refresh Outpost",
      ),
    ),
  ],
)
            ],
          ),
        ),
      ],
    );
  }
}