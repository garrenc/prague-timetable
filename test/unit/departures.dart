import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/models/departure.dart' as departure_models;
import 'package:timetable/models/transport_type.dart';

void main() {
  group('DeparturesEndpoint Unit Tests', () {
    group('JSON Parsing Tests', () {
      test('should parse departure JSON correctly', () {
        final json = {
          'departure': {'id': 'test_departure_1', 'timestamp_scheduled': '2024-01-15T10:30:00Z', 'timestamp_predicted': '2024-01-15T10:32:00Z'},
          'route': {'type': 'metro', 'short_name': 'A'},
          'vehicle': {'id': 'vehicle_123'},
          'stop': {'platform_code': '1'},
          'trip': {'headsign': 'Nemocnice Motol'},
        };

        final departure = departure_models.Departure.fromJson(json);

        expect(departure.id, equals('test_departure_1'));
        expect(departure.vehicleId, equals('vehicle_123'));
        expect(departure.platform, equals('1'));
        expect(departure.direction, equals('Nemocnice Motol'));
        expect(departure.route.transportType, equals(TransportType.metro));
        expect(departure.route.linkName, equals('A'));
      });

      test('should parse route JSON correctly', () {
        final json = {'type': 'tram', 'short_name': '22'};

        final route = departure_models.Route.fromJson(json);

        expect(route.transportType, equals(TransportType.tram));
        expect(route.linkName, equals('22'));
        expect(route.metroLine, isNull);
      });

      test('should parse metro route with metro line', () {
        final json = {'type': 'metro', 'short_name': 'A'};

        final route = departure_models.Route.fromJson(json);

        expect(route.transportType, equals(TransportType.metro));
        expect(route.linkName, equals('A'));
        expect(route.metroLine, isNotNull);
      });

      test('should handle missing optional fields gracefully', () {
        final json = {
          'departure': {'id': 'test_departure_2', 'timestamp_scheduled': '2024-01-15T10:30:00Z'},
          'route': {'type': 'bus', 'short_name': '119'},
        };

        final departure = departure_models.Departure.fromJson(json);

        expect(departure.id, equals('test_departure_2'));
        expect(departure.vehicleId, isNull);
        expect(departure.platform, isNull);
        expect(departure.direction, isNull);
        expect(departure.timePredicted, isNull);
        expect(departure.route.transportType, equals(TransportType.bus));
      });
    });

    group('Time Formatting Tests', () {
      test('should format scheduled time correctly', () {
        final departure = departure_models.Departure(
          id: 'test',
          timeScheduled: DateTime(2024, 1, 15, 14, 30),
          timePredicted: DateTime(2024, 1, 15, 14, 32),
          route: departure_models.Route(transportType: TransportType.metro, linkName: 'A'),
        );

        expect(departure.formattedTimeScheduled, equals('14:30'));
      });

      test('should handle null scheduled time', () {
        final departure = departure_models.Departure(id: 'test', timeScheduled: null, timePredicted: null, route: departure_models.Route(transportType: TransportType.metro, linkName: 'A'));

        expect(departure.formattedTimeScheduled, equals(''));
      });

      test('should calculate time difference correctly', () {
        final departure = departure_models.Departure(
          id: 'test',
          timeScheduled: DateTime(2024, 1, 15, 14, 30),
          timePredicted: DateTime(2024, 1, 15, 14, 35),
          route: departure_models.Route(transportType: TransportType.metro, linkName: 'A'),
        );

        expect(departure.difference, equals(5)); // 5 minutes late
      });

      test('should handle null times in difference calculation', () {
        final departure = departure_models.Departure(
          id: 'test',
          timeScheduled: null,
          timePredicted: DateTime(2024, 1, 15, 14, 35),
          route: departure_models.Route(transportType: TransportType.metro, linkName: 'A'),
        );

        expect(departure.difference, equals(0));
      });
    });

    group('Platform Grouping Tests', () {
      test('should group departures by platform correctly', () {
        final departures = [
          departure_models.Departure(
            id: 'dep1',
            timeScheduled: DateTime(2024, 1, 15, 14, 30),
            timePredicted: DateTime(2024, 1, 15, 14, 30),
            platform: '1',
            route: departure_models.Route(transportType: TransportType.metro, linkName: 'A'),
          ),
          departure_models.Departure(
            id: 'dep2',
            timeScheduled: DateTime(2024, 1, 15, 14, 35),
            timePredicted: DateTime(2024, 1, 15, 14, 35),
            platform: '1',
            route: departure_models.Route(transportType: TransportType.metro, linkName: 'A'),
          ),
          departure_models.Departure(
            id: 'dep3',
            timeScheduled: DateTime(2024, 1, 15, 14, 40),
            timePredicted: DateTime(2024, 1, 15, 14, 40),
            platform: '2',
            route: departure_models.Route(transportType: TransportType.tram, linkName: '22'),
          ),
        ];

        final grouped = departure_models.PlatformDepartures.groupByPlatform(departures, 'Test Station');

        expect(grouped.length, equals(2));
        expect(grouped[0].platform, equals('1'));
        expect(grouped[0].departures.length, equals(2));
        expect(grouped[1].platform, equals('2'));
        expect(grouped[1].departures.length, equals(1));
      });

      test('should handle empty platform codes', () {
        final departures = [
          departure_models.Departure(
            id: 'dep1',
            timeScheduled: DateTime(2024, 1, 15, 14, 30),
            timePredicted: DateTime(2024, 1, 15, 14, 30),
            platform: null,
            route: departure_models.Route(transportType: TransportType.bus, linkName: '119'),
          ),
        ];

        final grouped = departure_models.PlatformDepartures.groupByPlatform(departures, 'Test Station');

        expect(grouped.length, equals(1));
        expect(grouped[0].platform, equals(''));
        expect(grouped[0].departures.length, equals(1));
      });
    });

    group('Route Color Tests', () {
      test('should return correct colors for different transport types', () {
        final metroRoute = departure_models.Route(transportType: TransportType.metro, linkName: 'A');

        final tramRoute = departure_models.Route(transportType: TransportType.tram, linkName: '22');

        final busRoute = departure_models.Route(transportType: TransportType.bus, linkName: '119');

        expect(tramRoute.color, equals(Colors.brown));
        expect(busRoute.color, equals(Colors.blue));
        // Metro color depends on MetroLine enum, so we just check it's not null
        expect(metroRoute.color, isNotNull);
      });
    });
  });
}
