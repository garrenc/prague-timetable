import 'package:timetable/extensions/string.dart';
import 'package:timetable/models/stop.dart';
import 'package:timetable/network/api_service.dart';

class StopsEndpoint {
  static const endpoint = '/gtfs/stops';

  Future<List<Stop>> getStops({int limit = 20, int offset = 0, String? searchQuery}) async {
    final queryParams = <String, dynamic>{'limit': limit.toString(), 'offset': offset.toString()};

    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryParams['names[]'] = [searchQuery.toLowerCase(), searchQuery.capitalize()];
    }

    final response = await ApiService.instance.get(endpoint, queryParameters: queryParams);

    if (response.data['features'] is List) {
      final List<dynamic> data = response.data['features'];
      return data.map((json) => Stop.fromJson(json)).toList();
    }
    return [];
  }
}
