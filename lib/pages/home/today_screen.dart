import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hava/services/weather_service.dart';
import 'package:hava/widgets/hourly_forecast_widget.dart';
import 'package:hava/widgets/shimmer.dart';
import 'package:hava/widgets/sun_arc_painter.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({Key? key}) : super(key: key);

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic> currentWeather = {};
  List<Map<String, dynamic>> hourlyForecast = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    setState(() => isLoading = true);
    try {
      final weather = await _weatherService.getCurrentWeather();
      final hourly = await _weatherService.getHourlyForecast();
      setState(() {
        currentWeather = weather;
        hourlyForecast = hourly;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading weather data: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF6EDFF),
      child: RefreshIndicator(
        onRefresh: _loadWeatherData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 24),
          child: Column(
            children: [
              isLoading ? _buildLoadingWeatherDetails() : _buildWeatherDetails(),
              const SizedBox(height: 24),
              isLoading ? 
                const Shimmer(child: HourlyForecastSkeleton()) : 
                _buildHourlyForecast(),
              const SizedBox(height: 24),
              isLoading ? 
                const Shimmer(child: SunMoonScheduleSkeleton()) : 
                _buildSunMoonSchedule(_isNightTime()),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  bool _isNightTime() {
    final now = DateTime.now();
    final sunriseTime = DateTime(now.year, now.month, now.day, 6, 44);
    final sunsetTime = DateTime(now.year, now.month, now.day, 18, 31);
    return now.isBefore(sunriseTime) || now.isAfter(sunsetTime);
  }

  Widget _buildLoadingWeatherDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(child: Shimmer(child: WeatherDetailSkeleton())),
              SizedBox(width: 16),
              Expanded(child: Shimmer(child: WeatherDetailSkeleton())),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: Shimmer(child: WeatherDetailSkeleton())),
              SizedBox(width: 16),
              Expanded(child: Shimmer(child: WeatherDetailSkeleton())),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: Shimmer(child: WeatherDetailSkeleton())),
              SizedBox(width: 16),
              Expanded(child: Shimmer(child: WeatherDetailSkeleton())),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: Shimmer(child: WeatherDetailSkeleton())),
              SizedBox(width: 16),
              Expanded(child: Shimmer(child: WeatherDetailSkeleton())),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildWeatherDetail(
                  "Temperature",
                  "${currentWeather['temp']?.toStringAsFixed(1)}°C",
                  "assets/icons/temperature.png"
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildWeatherDetail(
                  "Humidity",
                  "${currentWeather['humidity']?.toStringAsFixed(1)}%",
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
                  "${currentWeather['pressure']?.toStringAsFixed(1)} hPa",
                  "assets/icons/pressuregauge.png"
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildWeatherDetail(
                  "UV Index",
                  "${currentWeather['uvIndex']?.toStringAsFixed(1)}",
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
                  "${currentWeather['wbt']?.toStringAsFixed(1)}",
                  "assets/icons/dewpoint.png"
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildWeatherDetail(
                  "Wind",
                  "${currentWeather['wind']?.toStringAsFixed(1)} km/h",
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
                  "${currentWeather['rainChance']?.toStringAsFixed(1)}%",
                  "assets/icons/rain.png"
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildWeatherDetail(
                  "Rain Level",
                  "${currentWeather['rain_level']?.toStringAsFixed(1)}mm",
                  "assets/icons/raingauge.png"
                ),
              ),
            ],
          ),
        ],
      ),
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

  Widget _buildHourlyForecast() {
    return HourlyForecastWidget(
      hourlyData: hourlyForecast,
      targetDate: DateTime.now(),
    );
  }

  Widget _buildSunMoonSchedule(bool isNight) {
    final now = DateTime.now();
    final sunriseTime = DateTime(now.year, now.month, now.day, 6, 44);
    final sunsetTime = DateTime(now.year, now.month, now.day, 18, 31);
    final nextSunrise = sunriseTime.add(const Duration(days: 1));
    
    final hours = isNight
        ? nextSunrise.difference(sunsetTime)
        : sunsetTime.difference(sunriseTime);

    return Container(
      padding: const EdgeInsets.all(24),
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
                  isNight ? 'assets/icons/moon.png' : 'assets/icons/sun.png',
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
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: SunArcPainter(
                    progress: calculateCurrentProgress(sunriseTime, sunsetTime),
                    sunriseTime: sunriseTime,
                    sunsetTime: sunsetTime,
                    currentTime: now,
                    isNight: isNight,
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSunTimeColumn(true, currentWeather['sunrise'] ?? "06:44 AM", isNight),
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
              _buildSunTimeColumn(false, currentWeather['sunset'] ?? "06:31 PM", isNight),
            ],
          ),
        ],
      ),
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
}