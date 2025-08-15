import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:timetable/models/vehicle_position.dart';
import 'package:timetable/providers/vehicle_position/vehicle_position_provider.dart';
import 'package:timetable/widgets/error_widget.dart';

class VehicleMapScreen extends ConsumerStatefulWidget {
  final String vehicleId;
  final String routeName;
  final String headsign;

  const VehicleMapScreen({super.key, required this.vehicleId, required this.routeName, required this.headsign});

  @override
  ConsumerState<VehicleMapScreen> createState() => _VehicleMapScreenState();
}

class _VehicleMapScreenState extends ConsumerState<VehicleMapScreen> {
  MapController? _mapController;
  List<Marker> _markers = [];
  VehiclePosition? _currentPosition;
  bool _isFollowingVehicle = true;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vehiclePositionNotifierProvider(widget.vehicleId).notifier).startPeriodicUpdates();
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vehiclePositionAsync = ref.watch(vehiclePositionNotifierProvider(widget.vehicleId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Vozidlo ${widget.routeName}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_isFollowingVehicle ? Icons.gps_fixed : Icons.gps_off),
            onPressed: () {
              setState(() {
                _isFollowingVehicle = !_isFollowingVehicle;
              });
            },
            tooltip: _isFollowingVehicle ? 'Vypnout sledování' : 'Zapnout sledování',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(vehiclePositionNotifierProvider(widget.vehicleId).notifier).refresh();
            },
            tooltip: 'Aktualizovat',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Linka: ${widget.routeName}', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Směr: ${widget.headsign}', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Expanded(
            child: vehiclePositionAsync.when(
              data: (position) {
                if (position == null) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.location_off, size: 64, color: Colors.grey), SizedBox(height: 16), Text('Poloha vozidla není dostupná', style: TextStyle(fontSize: 18))],
                    ),
                  );
                }

                _currentPosition = position;
                _updateMarkers();

                return Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(position.lat, position.lon),
                        initialZoom: 16.0,
                        onMapEvent: (MapEvent mapEvent) {
                          // Mark map as ready on first event
                          if (!_isMapReady) {
                            setState(() {
                              _isMapReady = true;
                            });
                            _updateMarkers();
                          }

                          // Update following state when user manually moves the map
                          if (_isFollowingVehicle && mapEvent is MapEventMove) {
                            final vehicleLatLng = LatLng(position.lat, position.lon);
                            final distance = _calculateDistance(mapEvent.camera.center.latitude, mapEvent.camera.center.longitude, vehicleLatLng.latitude, vehicleLatLng.longitude);

                            if (distance > 100) {
                              // If moved more than 100m from vehicle
                              setState(() {
                                _isFollowingVehicle = false;
                              });
                            }
                          }
                        },
                      ),
                      children: [TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.timetable'), MarkerLayer(markers: _markers)],
                    ),
                    // Custom map controls
                    Positioned(
                      right: 16,
                      top: 16,
                      child: Column(
                        children: [
                          FloatingActionButton.small(
                            onPressed:
                                _isMapReady
                                    ? () {
                                      _mapController?.move(_mapController!.camera.center, _mapController!.camera.zoom + 1);
                                    }
                                    : null,
                            heroTag: 'zoomIn',
                            child: const Icon(Icons.add),
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton.small(
                            onPressed:
                                _isMapReady
                                    ? () {
                                      _mapController?.move(_mapController!.camera.center, _mapController!.camera.zoom - 1);
                                    }
                                    : null,
                            heroTag: 'zoomOut',
                            child: const Icon(Icons.remove),
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton.small(
                            onPressed:
                                _isMapReady
                                    ? () {
                                      _mapController?.move(LatLng(position.lat, position.lon), 16.0);
                                      setState(() {
                                        _isFollowingVehicle = true;
                                      });
                                    }
                                    : null,
                            heroTag: 'centerVehicle',
                            backgroundColor: _isFollowingVehicle ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
                            child: Icon(Icons.my_location, color: _isFollowingVehicle ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: Text('Načítání polohy vozidla...')),
              error:
                  (error, stackTrace) => ErrorStateWidget(
                    message: 'Chyba při načítání polohy',
                    details: error.toString(),
                    onRetry: () {
                      ref.read(vehiclePositionNotifierProvider(widget.vehicleId).notifier).refresh();
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateMarkers() {
    if (_currentPosition == null) return;

    setState(() {
      _markers = [
        Marker(
          point: LatLng(_currentPosition!.lat, _currentPosition!.lon),
          width: 50,
          height: 25,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(widget.routeName, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 12, fontWeight: FontWeight.bold))),
          ),
        ),
      ];
    });

    // Animate camera to vehicle position if following is enabled after each update
    if (_isFollowingVehicle && _isMapReady) {
      _mapController?.move(LatLng(_currentPosition!.lat, _currentPosition!.lon), _mapController!.camera.zoom);
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Earth's radius in meters
    final double dLat = (lat2 - lat1) * (pi / 180);
    final double dLon = (lon2 - lon1) * (pi / 180);
    final double a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1 * (pi / 180)) * cos(lat2 * (pi / 180)) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }
}
