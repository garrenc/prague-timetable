import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timetable/network/endpoints/stops.dart';
import '../../models/stop.dart';

part 'stops_provider.g.dart';

@riverpod
class StopsNotifier extends _$StopsNotifier {
  final StopsEndpoint _stopsEndpoint = StopsEndpoint();

  @override
  Future<List<Stop>> build() async => [];

  Future<void> searchStops(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final stops = await _stopsEndpoint.getStops(limit: 100, offset: 0, searchQuery: query);

      // Group by name, merge ids
      final Map<String, Stop> grouped = {};
      for (final stop in stops) {
        final key = stop.name.trim();
        final existing = grouped[key];
        if (existing == null) {
          // First occurrence for this name
          grouped[key] = Stop(ids: [...stop.ids], name: stop.name, lat: stop.lat, lon: stop.lon, wheelchairAccessible: stop.wheelchairAccessible, zoneId: stop.zoneId, platform: stop.platform);
        } else {
          // Merge ids; keep first lat/lon/other fields as representative
          existing.ids.addAll(stop.ids);
        }
      }

      // Optional: dedupe + sort ids for stability
      final result =
          grouped.values.map((s) {
            final uniqueIds = s.ids.toSet().toList()..sort();
            return Stop(ids: uniqueIds, name: s.name, lat: s.lat, lon: s.lon, wheelchairAccessible: s.wheelchairAccessible, zoneId: s.zoneId, platform: s.platform);
          }).toList();

      state = AsyncValue.data(result);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
