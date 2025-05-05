import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hava/services/weather_service.dart';
import 'package:hava/widgets/hourly_forecast_widget.dart';
import 'package:hava/widgets/shimmer.dart';

class TomorrowScreen extends StatefulWidget {
  const TomorrowScreen({Key? key}) : super(key: key);

  @override
  State<TomorrowScreen> createState() => _TomorrowScreenState();
}

class _TomorrowScreenState extends State<TomorrowScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic> tomorrowWeather = {};
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
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final weather = await _weatherService.getCurrentWeather(); // You'll need to modify WeatherService to get tomorrow's weather
      final hourly = await _weatherService.getHourlyForecast(targetDate: tomorrow);
      setState(() {
        tomorrowWeather = weather;
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
            ],
          ),
        ),
      ),
    );
  }

  bool _isNightTime() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final sunriseTime = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 6, 44);
    final sunsetTime = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 18, 31);
    return tomorrow.isBefore(sunriseTime) || tomorrow.isAfter(sunsetTime);
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
                  "${tomorrowWeather['temp']?.toStringAsFixed(1)}°C",
                  "assets/icons/temperature.png"
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildWeatherDetail(
                  "Humidity",
                  "${tomorrowWeather['humidity']?.toStringAsFixed(1)}%",
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
                  "${tomorrowWeather['pressure']?.toStringAsFixed(1)} hPa",
                  "assets/icons/pressuregauge.png"
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildWeatherDetail(
                  "UV Index",
                  "${tomorrowWeather['uvIndex']?.toStringAsFixed(1)}",
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
                  "${tomorrowWeather['wbt']?.toStringAsFixed(1)}",
                  "assets/icons/dewpoint.png"
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildWeatherDetail(
                  "Wind",
                  "${tomorrowWeather['wind']?.toStringAsFixed(1)} km/h",
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
                  "${tomorrowWeather['rainChance']?.toStringAsFixed(1)}%",
                  "assets/icons/rain.png"
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildWeatherDetail(
                  "Rain Level",
                  "${tomorrowWeather['rain_level']?.toStringAsFixed(1)}mm",
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
      targetDate: DateTime.now().add(const Duration(days: 1)),
    );
  }
}