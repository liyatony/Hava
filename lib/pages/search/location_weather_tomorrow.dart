import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hava/services/external_weather_service.dart';
import 'package:hava/widgets/sun_arc_painter.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WeatherTomorrow extends StatelessWidget {
  final List<dynamic> forecastData;
  final bool isDaytime;
  final ExternalWeatherService weatherService;

  const WeatherTomorrow({
    Key? key,
    required this.forecastData,
    required this.isDaytime,
    required this.weatherService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (forecastData.length < 2) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text("No data for tomorrow"),
      );
    }

    final tomorrowData = forecastData[1];
    final hourlyData = tomorrowData['hour'] as List;
    final sunrise = tomorrowData['astro']['sunrise'];
    final sunset = tomorrowData['astro']['sunset'];
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildWeatherDetails(tomorrowData),
          ),
          const SizedBox(height: 16),
          _buildHourlyForecastWidget(hourlyData, tomorrow, sunrise, sunset),
        ],
      ),
    );
  }

  Widget _buildWeatherDetails(Map<String, dynamic> data) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildWeatherDetail(
                "Temperature",
                "${data['day']['avgtemp_c']}°C",
                "assets/icons/temperature.png"
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildWeatherDetail(
                "Humidity",
                "${data['day']['avghumidity']}%",
                "assets/icons/moisture.png"
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildWeatherDetail(
                "Pressure",
                "${data['day']['pressure_mb'] ?? 'N/A'} hPa",
                "assets/icons/pressuregauge.png"
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildWeatherDetail(
                "UV Index",
                "${data['day']['uv']}",
                "assets/icons/sun.png"
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildWeatherDetail(
                "WBT",
                "${data['day']['feelslike_c'] ?? 'N/A'}°C",
                "assets/icons/dewpoint.png"
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildWeatherDetail(
                "Wind",
                "${data['day']['maxwind_kph']} km/h",
                "assets/icons/wind.png"
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildWeatherDetail(
                "Rain Chance",
                "${data['day']['daily_chance_of_rain']}%",
                "assets/icons/rain.png"
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildWeatherDetail(
                "Rain Level",
                "${data['day']['totalprecip_mm']}mm",
                "assets/icons/raingauge.png"
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherDetail(String label, String value, String imagePath) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: const Color(0x4DD0BCFF),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Image.asset(
              imagePath,
              width: 24,
              height: 24,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecastWidget(List hourlyData, DateTime targetDate, String sunrise, String sunset) {
    final processedHourlyData = _processHourlyData(hourlyData);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0x4DD0BCFF),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, size: 24),
              const SizedBox(width: 8),
              Text(
                "Hourly forecast ${_getDateLabel(targetDate)}",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: processedHourlyData.length,
              itemBuilder: (context, index) {
                final hour = processedHourlyData[index];
                final hourTime = _parseHourTime(hour['time'], targetDate);
                
                return Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hour['time'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 36,
                        width: 36,
                        child: SvgPicture.asset(
                          weatherService.getWeatherIcon(
                            hour['condition'] ?? '',
                            time: hourTime,
                            sunrise: sunrise,
                            sunset: sunset,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${hour['temp_c']?.toString() ?? '0'}°',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  DateTime _parseHourTime(String timeStr, DateTime targetDate) {
    final timeParts = timeStr.split(' ');
    final hourMinute = timeParts[0].split(':');
    final hour = int.parse(hourMinute[0]);
    final minute = int.parse(hourMinute[1]);
    
    return DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      hour,
      minute,
    );
  }

  List<Map<String, dynamic>> _processHourlyData(List hourlyData) {
    return hourlyData.map((hour) {
      final timeStr = hour['time'].toString();
      final time = timeStr.contains(' ') ? timeStr.split(' ')[1] : timeStr;

      return {
        'time': time,
        'temp_c': hour['temp_c'],
        'condition': hour['condition']['text'],
        'is_day': hour['is_day'],
      };
    }).toList();
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return '';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day + 1) {
      return '(Tomorrow)';
    }
    return '(${date.day}/${date.month})';
  }
}