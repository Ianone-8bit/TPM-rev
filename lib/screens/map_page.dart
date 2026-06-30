import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../services/outpost_service.dart';
import '../services/location_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Position? position;
  LatLng? checkInSpot;
  double distance = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLocation();
  }

  Future<void> loadLocation() async {
    setState(() => isLoading = true);
    final current = await LocationService.instance.getCurrentLocation();

    if (current == null) {
      setState(() => isLoading = false);
      return;
    }

    final outpost = await OutpostService.instance.getOrCreateOutpost(current);

    checkInSpot = LatLng(outpost['lat']!, outpost['lon']!);

    distance = LocationService.instance.calculateDistance(
      current.latitude,
      current.longitude,
      checkInSpot!.latitude,
      checkInSpot!.longitude,
    );

    if (!mounted) return;
    setState(() {
      position = current;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || position == null || checkInSpot == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF7C3AED)),
            SizedBox(height: 16),
            Text("Memuat lokasi...",
                style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    final currentLocation = LatLng(position!.latitude, position!.longitude);
    final bool isNearby = distance <= 20;

    return Column(
      children: [
        Expanded(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: currentLocation,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.hunter_system',
              ),
              MarkerLayer(
                markers: [
                  // Current position marker
                  Marker(
                    point: currentLocation,
                    width: 60,
                    height: 60,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7C3AED).withOpacity(0.5),
                                blurRadius: 12,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: const Icon(Icons.person_pin_circle_rounded,
                              size: 22, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  // Check-in spot marker
                  Marker(
                    point: checkInSpot!,
                    width: 60,
                    height: 60,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isNearby
                                ? const Color(0xFF10B981)
                                : const Color(0xFFD97706),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isNearby
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFD97706))
                                    .withOpacity(0.5),
                                blurRadius: 12,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: const Icon(Icons.flag_rounded,
                              size: 22, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Info Panel ──
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Check-in Spot",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            isNearby
                                ? Icons.check_circle_rounded
                                : Icons.directions_walk_rounded,
                            color: isNearby
                                ? const Color(0xFF10B981)
                                : const Color(0xFFD97706),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isNearby
                                ? "Kamu sudah di sini! ✓"
                                : "${distance.toStringAsFixed(0)} m lagi",
                            style: TextStyle(
                              color: isNearby
                                  ? const Color(0xFF10B981)
                                  : Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isNearby
                          ? const Color(0xFF10B981).withOpacity(0.15)
                          : const Color(0xFFD97706).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isNearby
                            ? const Color(0xFF10B981).withOpacity(0.4)
                            : const Color(0xFFD97706).withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      isNearby ? "Sudah Dekat" : "Belum Dekat",
                      style: TextStyle(
                        color: isNearby
                            ? const Color(0xFF10B981)
                            : const Color(0xFFD97706),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: loadLocation,
                      icon: const Icon(Icons.my_location_rounded, size: 16),
                      label: const Text("Refresh Lokasi"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await OutpostService.instance.resetOutpost();
                        await loadLocation();
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text("Reset Spot"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white60,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}