import 'dart:convert';

import 'package:timetable/models/departure.dart';
import 'package:timetable/network/api_service.dart';

class DeparturesEndpoint {
  static const endpoint = '/public/departureboards';

  Future<List<Departure>> getDepartures(List<String> stopIds) async {
    // Create the base parameters
    Map<String, dynamic> params = {'limit': '4', 'minutesAfter': '60'};

    // Create a list of stopIds parameters that Dio will handle correctly
    List<String> stopIdsList = [];
    for (int i = 0; i < stopIds.length; i++) {
      stopIdsList.add(
        json.encode({
          i.toString(): [stopIds[i]],
        }),
      );
    }

    // Dio will automatically format this as multiple stopIds[]= parameters
    params['stopIds'] = stopIdsList;

    final response = await ApiService.instance.get(endpoint, queryParameters: params);

    if (response.data is List) {
      final boards = response.data as List<dynamic>;
      final result = <Departure>[];

      for (final item in boards) {
        final list = item as List<dynamic>;
        final deps = list.map<Departure>((j) => Departure.fromJson(j as Map<String, dynamic>)).toList();
        result.addAll(deps);
      }
      return result;
    }

    return [];
  }
}
