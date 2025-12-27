import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:weather_app/provider/theme_provider.dart';
import 'package:weather_app/screens/splash_screen.dart';

class WeeklyForecastScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> currentValue;
  final String city;
  final List<dynamic> pastWeek;
  final List<dynamic> next7days;

  const WeeklyForecastScreen({
    super.key,
    required this.currentValue,
    required this.city,
    required this.pastWeek,
    required this.next7days,
  });

  @override
  ConsumerState<WeeklyForecastScreen> createState() =>
      _WeeklyForecastScreenState();
}

class _WeeklyForecastScreenState extends ConsumerState<WeeklyForecastScreen> {
  String formatApiData(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    return DateFormat('d MMMM, EEEE').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final notifier = ref.read(themeNotifierProvider.notifier);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      notifier.toggleTheme();
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SplashScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.logout, color: Colors.grey, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: Column(
                  children: [
                    //// weather, city name, temp
                    Text(
                      widget.city,
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
                      '${widget.currentValue['temp_c']}°C',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${widget.currentValue['condition']['text']}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Image.network(
                      'https:${widget.currentValue['condition']?['icon'] ?? ''}',
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //// next 7 days forecast
                    Text(
                      'Next 7 Days Forecast',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 10),
                    ...widget.next7days.map((day) {
                      final date = day['date'] ?? '';
                      final condition = day['day']?['condition']?['text'] ?? '';
                      final icon = day['day']?['condition']?['icon'] ?? '';
                      final maxTemp = day['day']?['maxtemp_c'] ?? '';
                      final minTemp = day['day']?['mintemp_c'] ?? '';
                      final iconUrl = icon.isNotEmpty ? 'https:$icon' : '';
                      return ListTile(
                        leading: iconUrl.isNotEmpty
                            ? Image.network(
                                iconUrl,
                                width: 40,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.error),
                        title: Text(
                          formatApiData(date),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          '$condition $minTemp°C - $maxTemp°C',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      );
                    }),
                    //// prev 7 days forecast
                    SizedBox(height: 20),
                    Text(
                      'Previous 7 Days Forecast',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 10),
                    ...widget.pastWeek.map((day) {
                      final forecastDay = day['forecast']?['forecastday'];
                      if (forecastDay == null || forecastDay.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final forecast = forecastDay[0];
                      final date = forecast['date'] ?? '';
                      final condition =
                          forecast['day']?['condition']?['text'] ?? '';
                      final icon = forecast['day']?['condition']?['icon'] ?? '';
                      final maxTemp = forecast['day']?['maxtemp_c'] ?? '';
                      final minTemp = forecast['day']?['mintemp_c'] ?? '';
                      final iconUrl = icon.isNotEmpty ? 'https:$icon' : '';
                      return ListTile(
                        leading: iconUrl.isNotEmpty
                            ? Image.network(
                                iconUrl,
                                width: 40,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.error),
                        title: Text(
                          formatApiData(date),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          '$condition $minTemp°C - $maxTemp°C',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
