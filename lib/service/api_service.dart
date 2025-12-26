import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//flutter pub add flutter_dotenv
import 'package:flutter_dotenv/flutter_dotenv.dart';

String apiKey = dotenv.env['API_KEY'] ?? '';

class WeatherApiService {
  final String _baseUrl = 'https://api.weatherapi.com/v1';
  Future<Map<String, dynamic>> getHourlyForecast(String location) async {
    final url = Uri.parse(
      '$_baseUrl/forecast.json?key=$apiKey&q=$location&day=7',
    );
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Failed to load data: ${res.body}');
    }
    final data = json.decode(res.body);
    //check if api returned err
    if (data.containsKey('error')) {
      throw Exception(data['error']['message'] ?? 'Invalid location');
    }
    return data;
  }

  //prev 7 days forecast
  Future<List<Map<String, dynamic>>> getPast7DaysWeather(
    String location,
  ) async {
    final List<Map<String, dynamic>> pastWeather = [];
    final today = DateTime.now();
    for (int i = 1; i <= 7; i++) {
      final data = today.subtract(Duration(days: i));
      final formattedDate =
          '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
      final url = Uri.parse(
        '$_baseUrl/history.json?key=$apiKey&q=$location&dt=$formattedDate',
      );
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        //check if api returned err
        if (data.containsKey('error')) {
          throw Exception(data['error']['message'] ?? 'Invalid location');
        }
        if (data['forecast']?['forecastday'] != null) {
          pastWeather.add(data);
        } else {
          debugPrint('No data found for $formattedDate : ${res.body}');
        }
      }
    }
    return pastWeather;
  }
}
