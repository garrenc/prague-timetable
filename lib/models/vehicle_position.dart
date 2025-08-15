class VehiclePosition {
  final String vehicleId;
  final double lat;
  final double lon;
  final double? bearing;
  final DateTime timestamp;

  VehiclePosition({required this.vehicleId, required this.lat, required this.lon, this.bearing, required this.timestamp});

  factory VehiclePosition.fromJson(Map<String, dynamic> json) {
    var cords = json['geometry']?['coordinates'];
    return VehiclePosition(
      vehicleId: json['vehicle_id'] ?? '',
      lat: cords[1],
      lon: cords[0],
      bearing: json['bearing']?.toDouble(),
      timestamp: DateTime.parse(json['origin_timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}
