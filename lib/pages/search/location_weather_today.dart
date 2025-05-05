import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hava/services/external_weather_service.dart';
import 'package:hava/widgets/sun_arc_painter.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WeatherToday extends StatelessWidget {
  final List<dynamic> forecastData;
  final bool isDaytime;
  final ExternalWeatherService weatherService;

  const WeatherToday({
    Key? key,
    required this.forecastData,
    required this.isDaytime,
    required this.weatherService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (forecastData.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text("No data for today"),
      );
    }

    final todayData = forecastData[0];
    final hourlyData = todayData['hour'] as List;
    final sunrise = todayData['astro']['sunrise'];
    final sunset = todayData['astro']['sunset'];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildWeatherDetails(todayData),
          ),
          const SizedBox(height: 16),
          _buildHourlyForecastWidget(hourlyData, DateTime.now(), sunrise, sunset),
          const SizedBox(height: 16),
          _buildSunMoonSchedule(sunrise, sunset),
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
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

  Widget _buildSunMoonSchedule(String sunrise, String sunset) {
    final sunriseTime = _parseTime(sunrise);
    final sunsetTime = _parseTime(sunset);
    final now = DateTime.now();
    final isNight = !isDaytime;

    final hours = isNight
        ? sunriseTime.add(const Duration(days: 1)).difference(sunsetTime)
        : sunsetTime.difference(sunriseTime);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0x4DD0BCFF),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 9),
                width: 32,
                height: 32,
                child: Image.asset(
                  isNight ?'assets/icons/moon.png' : 'assets/icons/sun.png',
                  fit: BoxFit.fill,
                ),
              ),
              Text(
                isNight ? "Moon Schedule" : "Sun Schedule",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 80,
            child: CustomPaint(
              size: Size.infinite,
              painter: SunArcPainter(
                progress: calculateCurrentProgress(sunriseTime, sunsetTime),
                sunriseTime: sunriseTime,
                sunsetTime: sunsetTime,
                currentTime: now,
                isNight: isNight,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSunTimeColumn(true, sunrise, isNight),
              Column(
                children: [
                  Text(
                    isNight ? "Night hours" : "Daylight hours",
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "${hours.inHours}h ${hours.inMinutes % 60}min",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              _buildSunTimeColumn(false, sunset, isNight),
            ],
          ),
        ],
      ),
    );
  }

  DateTime _parseTime(String timeStr) {
    final parts = timeStr.split(' ');
    final timeParts = parts[0].split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final isPm = parts.length > 1 && parts[1].toLowerCase() == 'pm';
    
    return DateTime(
      DateTime.now().year, 
      DateTime.now().month, 
      DateTime.now().day, 
      isPm && hour < 12 ? hour + 12 : hour, 
      minute
    );
  }

  Widget _buildSunTimeColumn(bool isRise, String time, bool isNight) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          child: Image.asset(
            isNight
                ? (isRise ? 'assets/icons/moonrise.png' : 'assets/icons/moonset.png')
                : (isRise ? 'assets/icons/sunrise.png' : 'assets/icons/sunset.png'),
            width: 33,
            height: 33,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          time,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  double calculateCurrentProgress(DateTime sunrise, DateTime sunset) {
    final now = DateTime.now();
    final isNight = now.isBefore(sunrise) || now.isAfter(sunset);
    
    if (isNight) {
      final nextSunrise = sunrise.add(const Duration(days: 1));
      final nightDuration = nextSunrise.difference(sunset).inMinutes;
      final elapsedNight = now.isAfter(sunset)
          ? now.difference(sunset).inMinutes
          : now.difference(sunset.subtract(const Duration(days: 1))).inMinutes;
      return elapsedNight / nightDuration;
    } else {
      if (now.isBefore(sunrise)) return 0.0;
      if (now.isAfter(sunset)) return 1.0;
      
      final totalDuration = sunset.difference(sunrise).inMinutes;
      final elapsed = now.difference(sunrise).inMinutes;
      return elapsed / totalDuration;
    }
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