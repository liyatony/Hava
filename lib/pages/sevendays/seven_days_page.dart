import 'package:flutter/material.dart';
import 'package:hava/pages/sevendays/day_detail_screen.dart';
import 'package:hava/services/weather_service.dart';
import 'package:hava/widgets/shimmer.dart';
import 'package:intl/intl.dart';

class SevenDaysScreen extends StatefulWidget {
  const SevenDaysScreen({Key? key}) : super(key: key);

  @override
  State<SevenDaysScreen> createState() => _SevenDaysScreenState();
}

class _SevenDaysScreenState extends State<SevenDaysScreen> {
  final WeatherService _weatherService = WeatherService();
  List<Map<String, dynamic>> weeklyForecast = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeeklyForecast();
  }

  Future<void> _fetchWeeklyForecast() async {
    try {
      setState(() => isLoading = true);
      
      DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
      List<Map<String, dynamic>> forecast = await _weatherService.getDailyForecast();
      
      weeklyForecast = forecast.where((day) {
        DateTime date = day['date'];
        return date.isAfter(DateTime.now());
      }).take(7).toList();

      setState(() => isLoading = false);
    } catch (e) {
      print('Error fetching weekly forecast: $e');
      setState(() => isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, MMM d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Shimmer(
        child: Column(
          children: [
            const SizedBox(height: 16),
            SevenDaysForecastSkeleton(),
          ],
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: List.generate(weeklyForecast.length, (index) {
              final forecast = weeklyForecast[index];
              final date = forecast['date'] as DateTime;
              final condition = forecast['condition'] as String;
              
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeatherDetailScreen(
                        date: _formatDate(date),
                        targetDate: date,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: const Color(0xFFEBDEFF),
                  ),
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDate(date),
                              style: const TextStyle(
                                color: Color(0xFF2E004E),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 11),
                            Text(
                              condition,
                              style: const TextStyle(
                                color: Color(0xFF494649),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${forecast['max_temp'].round()}°",
                            style: const TextStyle(
                              color: Color(0xFF2E004E),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 11),
                          Text(
                            "${forecast['min_temp'].round()}°",
                            style: const TextStyle(
                              color: Color(0xFF2E004E),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Container(
                        color: const Color(0xFF4B454D),
                        width: 1,
                        height: 35,
                      ),
                      const SizedBox(width: 14),
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: forecast['icon'],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}