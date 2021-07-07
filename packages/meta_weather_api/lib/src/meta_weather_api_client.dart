import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../meta_weather_api.dart';

class LocationIdRequestFailure implements Exception {}

class LocationNotFoundFailure implements Exception {}

class WeatherRequestFailure implements Exception {}

class MetaWeatherApiClient {
  final _httpClient = http.Client();

  Future<Weather> getWeather(int locationId) async {
    final weatherRequest = Uri.https(_baseUrl, '/api/location/$locationId');
    final weatherResponse = await _httpClient.get(weatherRequest);

    if (weatherResponse.statusCode != 200) {
      throw WeatherRequestFailure();
    }

    final weatherJson = jsonDecode(
      weatherResponse.body,
    )['consolidated_weather'] as List;

    if (weatherJson.isEmpty) {
      throw WeatherRequestFailure();
    }

    return Weather.fromJson(weatherJson.first as Map<String, dynamic>);
  }

  Future<Location> locationSearch(String query) async {
    final locationRequest = Uri.https(
      _baseUrl,
      '/api/location/search',
      <String, String>{'query': query},
    );
    final locationResponse = await _httpClient.get(locationRequest);

    if (locationResponse.statusCode != 200) {
      throw LocationNotFoundFailure();
    }

    final locationJson = jsonDecode(
      locationResponse.body,
    ) as List;

    if (locationJson.isEmpty) {
      throw LocationIdRequestFailure();
    }

    return Location.fromJson(locationJson.first as Map<String, dynamic>);
  }
}