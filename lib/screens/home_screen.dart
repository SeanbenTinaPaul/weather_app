import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/provider/theme_provider.dart';
import 'package:weather_app/screens/weekly_forecast_screen.dart';
import 'package:weather_app/service/api_service.dart';
import 'package:weather_app/screens/splash_screen.dart';

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
        debugPrint('currentValue: $currentValue');
      });
    } catch (e) {
      setState(() {
        currentValue = {};
        hourly = [];
        next7days = [];
        pastWeek = [];
        // city = '';
        // country = '';
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('City not found or invalid. Please try again.')),
      );
    }
  }

  //content displayed
  String formateTime(String timeString) {
    DateTime time = DateTime.parse(timeString);
    return DateFormat.j().format(time); //e.g. 2 AM, 12 AM, 12 PM
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final notifier = ref.read(themeNotifierProvider.notifier);
    final isDarkMode = themeMode == ThemeMode.dark; //set initial theme mode
    debugPrint('Current Theme Mode: $themeMode, isDarkMode: $isDarkMode');

    //select weather icon
    String iconPath = currentValue['condition']?['icon'] ?? '';
    debugPrint(
      'iconPath: $iconPath',
    ); //cdn.weatherapi.com/weather/64x64/night/113.png
    String imgUrl = iconPath.isNotEmpty ? 'https:$iconPath' : 'assets/images/';

    Widget imageWidget = imgUrl.isNotEmpty
        ? Image.network(imgUrl, height: 200, width: 200, fit: BoxFit.cover)
        : Image.asset(imgUrl, height: 200, width: 200, fit: BoxFit.cover);

    // prior to theme.dart
    final contentColor = isDarkMode
        ? const Color(0xFFEEEEEE)
        : const Color(0xFF333333);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: SizedBox(
          height: 50,
          child: TextField(
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            onSubmitted: (value) {
              if (value.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a city name.')),
                );
                return;
              }
              city = value.trim();
              _fetchWeatherData();
            },
            decoration: InputDecoration(
              labelText: 'Search City',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: Icon(Icons.search, color: Colors.grey),
              labelStyle: TextStyle(color: Colors.grey),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(color: Colors.grey),
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
        actions: [
          // Subtle logout button
          IconButton(
            icon: Icon(Icons.logout, size: 20, color: Colors.grey),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SplashScreen()),
                (route) => false,
              );
            },
          ),
          SizedBox(width: 10),
          //// toggle theme btn
          GestureDetector(
            onTap: () {
              notifier.toggleTheme();
              // print('isDarkMode: $isDarkMode');
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 0.0),
              child: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            ),
          ),
          SizedBox(width: 25),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : currentValue.isNotEmpty
          ? LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 20),
                          //// weather, city name, temp
                          Text(
                            '$city${country.isEmpty ? '' : ', $country'}',
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '${currentValue['temp_c']}°C',
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '${currentValue['condition']['text']}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          imageWidget, // Widget defined in build method
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Container(
                              height: 100,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Theme.of(
                                  context,
                                ).scaffoldBackgroundColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.shadow,
                                    blurRadius: 10,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/humidity.png',
                                        width: 30,
                                        height: 30,
                                      ),
                                      Text(
                                        '${currentValue['humidity']}%',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Humidity',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/wind.png',
                                        width: 30,
                                        height: 30,
                                        fit: BoxFit.cover,
                                      ),
                                      Text(
                                        '${currentValue['wind_kph']} km/h',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Wind Speed',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/thermometer.png',
                                        width: 30,
                                        height: 30,
                                        fit: BoxFit.cover,
                                      ),
                                      Text(
                                        '${hourly.isNotEmpty ? hourly.map((h) => h['temp_c']).reduce((a, b) => a > b ? a : b).toString() : 'N/A'}°C',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Today\'s High',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/uv_index.png',
                                        width: 30,
                                        height: 30,
                                        fit: BoxFit.cover,
                                      ),
                                      Text(
                                        '${currentValue['uv']}',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'UV Index',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          const SizedBox(height: 20),
                          //// bottom forecast
                          Expanded(
                            child: Container(
                              width: double.maxFinite,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Theme.of(context).colorScheme.shadow,
                                  ),
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(40),
                                ),
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 15),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Today Forecast',
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    WeeklyForecastScreen(
                                                      city: city,
                                                      currentValue:
                                                          currentValue,
                                                      pastWeek: pastWeek,
                                                      next7days: next7days,
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Weekly Forecast',
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.color,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    color: Theme.of(context).colorScheme.shadow,
                                  ),
                                  //// time forecast carousel
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 150,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: hourly.length,
                                      itemBuilder: (context, index) {
                                        final hour = hourly[index];
                                        final now = DateTime.now();
                                        final hourTime = DateTime.parse(
                                          hour['time'],
                                        );
                                        final isCurrentHour =
                                            now.hour == hourTime.hour &&
                                            now.day == hourTime.day;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          child: Container(
                                            height: 70,
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              gradient:
                                                  (isCurrentHour && isDarkMode)
                                                  ? LinearGradient(
                                                      colors: [
                                                        Theme.of(
                                                          context,
                                                        ).primaryColor,
                                                        Theme.of(
                                                          context,
                                                        ).colorScheme.secondary,
                                                      ],
                                                    )
                                                  : null,
                                              color: isCurrentHour
                                                  ? (isDarkMode
                                                        ? null
                                                        : Theme.of(
                                                            context,
                                                          ).colorScheme.primary)
                                                  : Theme.of(
                                                      context,
                                                    ).scaffoldBackgroundColor,
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  isCurrentHour ? 'Now' : '',
                                                ),
                                                Text(
                                                  formateTime(
                                                    hourly[index]['time'],
                                                  ),
                                                  style: TextStyle(
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.onSurface,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Image.network(
                                                  'https:${hourly[index]['condition']['icon']}',
                                                  width: 40,
                                                ),
                                                Text(
                                                  '${hourly[index]['temp_c']}°C',
                                                  style: TextStyle(
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.onSurface,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                Text(
                                                  'UV ${hourly[index]['uv']}',
                                                  style: TextStyle(
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.onSurface,
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : const SizedBox.shrink(),
    );
  }
}
