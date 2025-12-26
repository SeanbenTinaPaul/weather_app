import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_app/provider/theme_provider.dart';
import 'package:weather_app/service/api_service.dart';

class WeatherAppHomeScreen extends ConsumerStatefulWidget {
  const WeatherAppHomeScreen({super.key});

  @override
  ConsumerState<WeatherAppHomeScreen> createState() =>
      _WeatherAppHomeScreenState();
}

class _WeatherAppHomeScreenState extends ConsumerState<WeatherAppHomeScreen> {
  final _weatherService = WeatherApiService();
  String city = 'Khon Kaen'; //initail city
  String country = ''; //initail country
  Map<String, dynamic> currentValue = {};
  List<dynamic> hourly = [];
  List<dynamic> pastWeek = [];
  List<dynamic> next7days = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    try {
      setState(() {
        isLoading = true;
      });
      final forecast = await _weatherService.getHourlyForecast(city);
      final past7days = await _weatherService.getPast7DaysWeather(city);
      setState(() {
        currentValue = forecast['current'] ?? {};
        hourly = forecast['forecast']?['forecastday']?[0]?['hour'] ?? [];
        //forecast 7 days
        next7days = forecast['forecast']?['forecastday'] ?? [];

        pastWeek = past7days;
        city = forecast['location']?['name'] ?? city;
        country = forecast['location']?['country'] ?? '';

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        currentValue = {};
        hourly = [];
        next7days = [];
        pastWeek = [];
        city = '';
        country = '';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final notifier = ref.read(themeNotifierProvider.notifier);
    final isDarkMode = themeMode == ThemeMode.dark;

    debugPrint('Current Theme Mode: $themeMode, isDarkMode: $isDarkMode');

    final contentColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          SizedBox(width: 25),
          SizedBox(
            width: 320,
            height: 50,
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search City',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: Icon(Icons.search, color: contentColor),
                labelStyle: TextStyle(color: contentColor),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: contentColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: contentColor),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: contentColor),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: contentColor),
                ),
              ),
            ),
          ),
          Spacer(),
          //toggle theme icon
          GestureDetector(
            onTap: () {
              notifier.toggleTheme();
              // print('isDarkMode: $isDarkMode');
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            ),
          ),
        ],
      ),
    );
  }
}
