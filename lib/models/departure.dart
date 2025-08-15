import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timetable/models/metro_line.dart';
import 'package:timetable/models/transport_type.dart';

class Departure {
  final String id;
  final DateTime? timeScheduled;
  final DateTime? timePredicted;
  final String? platform;
  final String? direction;
  final Route route;
  final String? tripId;
  final String? vehicleId;

  Departure({required this.id, required this.timeScheduled, required this.timePredicted, required this.route, this.platform, this.direction, this.tripId, this.vehicleId});

  factory Departure.fromJson(Map<String, dynamic> json) {
    var departure = json['departure'];
    var route = json['route'];

    return Departure(
      id: departure['id'] ?? '',
      route: Route.fromJson(route),
      vehicleId: json['vehicle']?['id'],
      timeScheduled: DateTime.tryParse(departure['timestamp_scheduled'] ?? ''),
      timePredicted: DateTime.tryParse(departure['timestamp_predicted'] ?? ''),
      platform: json['stop']?['platform_code'],
      direction: json['trip']?['headsign'],
    );
  }

  String get formattedTimeScheduled {
    if (timeScheduled == null) {
      return '';
    }

    return DateFormat('HH:mm').format(timeScheduled!);
  }

  int get difference {
    if (timeScheduled == null || timePredicted == null) {
      return 0;
    }

    return timePredicted!.difference(timeScheduled!).inMinutes;
  }
}

class Route {
  final TransportType transportType;
  final String linkName;
  final MetroLine? metroLine;

  Route({required this.transportType, required this.linkName, this.metroLine});

  factory Route.fromJson(Map<String, dynamic> json) {
    var transportType = TransportType.parse(json['type']);
    var linkName = json['short_name'];
    var metroLine = transportType == TransportType.metro ? MetroLine.values.firstWhere((e) => e.name == linkName.toString()) : null;
    return Route(transportType: transportType, linkName: linkName, metroLine: metroLine);
  }

  Color get color {
    switch (transportType) {
      case TransportType.metro:
        return metroLine!.color;
      case TransportType.tram:
        return Colors.brown;
      case TransportType.bus:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class PlatformDepartures {
  final String platform;
  final String stationName;
  final List<Departure> departures;

  PlatformDepartures({required this.platform, required this.stationName, required this.departures});

  static List<PlatformDepartures> groupByPlatform(List<Departure> departures, String stationName) {
    final Map<String, List<Departure>> platformGroups = {};

    for (final departure in departures) {
      final platform = departure.platform ?? '';
      platformGroups.putIfAbsent(platform, () => []).add(departure);
    }

    // convert to list of PlatformDepartures
    return platformGroups.entries.map((entry) {
        return PlatformDepartures(platform: entry.key, stationName: stationName, departures: entry.value);
      }).toList()
      ..sort((a, b) => a.platform.compareTo(b.platform)); // sort by platform name
  }
}
