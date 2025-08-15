import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timetable/network/logger.dart';
import '../../models/vehicle_position.dart';
import '../../network/endpoints/vehicle_position.dart';

part 'vehicle_position_provider.g.dart';

@riverpod
class VehiclePositionNotifier extends _$VehiclePositionNotifier {
  final VehiclePositionEndpoint _vehiclePositionEndpoint = VehiclePositionEndpoint();
  Timer? _updateTimer;

  @override
  Future<VehiclePosition?> build(String vehicleId) async {
    // Set up cleanup when the provider is disposed
    ref.onDispose(() {
      AppLogger.log('VehiclePositionNotifier disposed');
      stopPeriodicUpdates();
    });

    return _vehiclePositionEndpoint.getVehiclePosition(vehicleId);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      return _vehiclePositionEndpoint.getVehiclePosition(vehicleId);
    });
  }

  void startPeriodicUpdates() {
    // Cancel any existing timer
    _updateTimer?.cancel();

    // Start periodic updates every 10 seconds
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      refresh();
    });
  }

  void stopPeriodicUpdates() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }
}
