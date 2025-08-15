import 'package:timetable/models/vehicle_position.dart';
import 'package:timetable/network/api_service.dart';

class VehiclePositionEndpoint {
  static const endpoint = '/public/vehiclepositions';

  Future<VehiclePosition?> getVehiclePosition(String vehicleId) async {
    var queryParams = {'scopes': 'info'};

    final response = await ApiService.instance.get('$endpoint/$vehicleId', queryParameters: queryParams);

    if (response.data != null && response.data.isNotEmpty) {
      return VehiclePosition.fromJson(response.data);
    }
    return null;
  }
}
