import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

class WeeklyForecastScreen extends StatefulWidget {
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
  State<WeeklyForecastScreen> createState() => _WeeklyForecastScreenState();
}

class _WeeklyForecastScreenState extends State<WeeklyForecastScreen> {
  String formatApiData(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    return DateFormat('d MMMM, EEEE').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
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
              //// next 7 days forecast
              SizedBox(height: 20),
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
                return ListTile(
                  leading: Image.network(
                    'https:$icon',
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                    date,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    '${maxTemp}°C / ${minTemp}°C',
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
    );
  }
}
