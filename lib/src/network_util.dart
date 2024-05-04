import 'dart:convert';

import 'package:flutter_polyline_points/src/utils/polyline_decoder.dart';
import 'package:flutter_polyline_points/src/utils/polyline_request.dart';
import 'package:http/http.dart' as http;
import 'PointLatLng.dart';
import 'utils/polyline_result.dart';

class NetworkUtil {
  static const String STATUS_OK = "ok";

  ///Get the encoded string from google directions api
  ///
  Future<List<PolylineResult>> getRouteBetweenCoordinates({
    required PolylineRequest request,
  }) async {
    List<PolylineResult> results = [];

    var response = await http.get(request.toUri());
    if (response.statusCode == 200) {
      var parsedJson = json.decode(response.body);
      if (parsedJson["status"]?.toLowerCase() == STATUS_OK &&
          parsedJson["routes"] != null &&
          parsedJson["routes"].isNotEmpty) {
        List<dynamic> routeList = parsedJson["routes"];
        for (var route in routeList) {
          final bounds = route["bounds"];
          final northeast = bounds["northeast"];
          final southwest = bounds["southwest"];
          final boundsNortheast = PointLatLng(
            northeast["lat"] ?? 0,
            northeast["lng"] ?? 0,
          );
          final boundsSouthwest = PointLatLng(
            southwest["lat"] ?? 0,
            southwest["lng"] ?? 0,
          );

          final leg = route["legs"][0];
          results.add(
            PolylineResult(
              points: PolylineDecoder.run(route["overview_polyline"]["points"]),
              errorMessage: "",
              status: parsedJson["status"],
              distance: leg["distance"]["text"],
              distanceValue: leg["distance"]["value"],
              overviewPolyline: route["overview_polyline"]["points"],
              durationValue: leg["duration"]["value"],
              endAddress: leg['end_address'],
              startAddress: leg['start_address'],
              duration: leg["duration"]["text"],
              boundsNortheast: boundsNortheast,
              boundsSouthwest: boundsSouthwest,
            ),
          );
        }
      } else {
        throw Exception(
            "Unable to get route: Response ---> ${parsedJson["status"]} ");
      }
    }
    return results;
  }
}
