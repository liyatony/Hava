import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hava/services/external_weather_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Weather7Days extends StatelessWidget {
  final List<dynamic> forecastData;
  final bool isDaytime;
  final ExternalWeatherService weatherService;

  const Weather7Days({
    Key? key,
    required this.forecastData,
    required this.isDaytime,
    required this.weatherService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "3-Day Forecast",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E004E),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: forecastData.length,
          itemBuilder: (context, index) {
            final dayData = forecastData[index];
            final date = dayData['date'];
            final maxTemp = dayData['day']['maxtemp_c'].toString();
            final minTemp = dayData['day']['mintemp_c'].toString();
            final condition = dayData['day']['condition']['text'];
            final isDay = index == 0 ? isDaytime : true; // Assume daytime for future days

            final DateTime dateTime = DateTime.parse(date);
            final String dayName = _getDayName(dateTime.weekday);

            return Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEBDEFF),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('MMM d').format(dateTime),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "$minTemp°",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "$maxTemp°",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Container(
                    color: const Color(0xFF4B454D),
                    width: 1,
                    height: 35,
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: SvgPicture.asset(
                      weatherService.getWeatherIcon(condition),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return "Monday";
      case 2: return "Tuesday";
      case 3: return "Wednesday";
      case 4: return "Thursday";
      case 5: return "Friday";
      case 6: return "Saturday";
      case 7: return "Sunday";
      default: return "";
    }
  }
}