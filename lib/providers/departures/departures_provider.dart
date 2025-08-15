import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timetable/network/logger.dart';
import '../../models/departure.dart';
import '../../network/endpoints/departures.dart';

part 'departures_provider.g.dart';

@riverpod
class DeparturesNotifier extends _$DeparturesNotifier {
  final DeparturesEndpoint _departuresEndpoint = DeparturesEndpoint();

  List<String> _stopIds = [];
  String _stationName = '';

  @override
  Future<List<PlatformDepartures>> build(List<String> stopIds, {String stationName = ''}) async {
    state = const AsyncValue.loading();
    _stopIds = stopIds;
    _stationName = stationName;
    return await loadDepartures();
  }

  Future<List<PlatformDepartures>> loadDepartures() async {
    state = const AsyncValue.loading();

    try {
      var departures = await _departuresEndpoint.getDepartures(_stopIds);
      var groupedDepartures = PlatformDepartures.groupByPlatform(departures, _stationName);
      state = AsyncValue.data(groupedDepartures);
      return groupedDepartures;
    } catch (e, stack) {
      AppLogger.error('Error loading departures', error: e, stackTrace: stack);
      state = AsyncValue.error(e, stack);
    }
    return [];
  }
}
