class Stop {
  final List<String> ids; // instead of just one string
  final String name;
  final double lat;
  final double lon;
  final String? wheelchairAccessible;
  final String? zoneId;
  final String? platform;
  double? _distanceFromUser;

  Stop({required this.ids, required this.name, required this.lat, required this.lon, this.wheelchairAccessible, this.zoneId, this.platform});

  void setDistanceFromUser(double distanceInMeters) {
    _distanceFromUser = distanceInMeters;
  }

  double? get distanceFromUser => _distanceFromUser;

  factory Stop.fromJson(Map<String, dynamic> json) {
    var coordinates = json['geometry']['coordinates'];
    var properties = json['properties'];
    return Stop(
      ids: [properties['stop_id'] ?? ''], // store as list with one element
      name: properties['stop_name'] ?? '',
      lat: coordinates[1],
      lon: coordinates[0],
      wheelchairAccessible: properties['wheelchair_boarding']?.toString(),
      zoneId: properties['zone_id'],
      platform: properties['platform'],
    );
  }
}
