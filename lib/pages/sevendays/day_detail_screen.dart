import 'package:flutter/material.dart';
import 'package:hava/services/weather_service.dart';
import 'package:hava/widgets/shimmer.dart';
import 'package:intl/intl.dart';

class WeatherDetailScreen extends StatefulWidget {
  final String date;
  final DateTime targetDate;

  const WeatherDetailScreen({
    Key? key,
    required this.date,
    required this.targetDate,
  }) : super(key: key);

  @override
  State<WeatherDetailScreen> createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen> with SingleTickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic> weatherData = {};
  List<Map<String, dynamic>> hourlyForecast = [];
  bool isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Setup animation controller for smoother animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _fetchWeatherData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeatherData() async {
    try {
      setState(() => isLoading = true);
      
      // Fetch detailed weather data for the selected date
      final dailyForecast = await _weatherService.getDailyForecast();
      final dayData = dailyForecast.firstWhere(
        (day) => _isSameDay(day['date'] as DateTime, widget.targetDate),
        orElse: () => {},
      );

      if (dayData.isNotEmpty) {
        // Fetch hourly data for the selected date
        final hourly = await _weatherService.getHourlyForecast(
          targetDate: widget.targetDate,
        );

        // Add a small delay to show loading state
        await Future.delayed(const Duration(milliseconds: 800));

        setState(() {
          weatherData = dayData;
          hourlyForecast = hourly;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching weather details: $e');
      setState(() => isLoading = false);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EDFF),
      body: isLoading 
          ? _buildLoadingState() 
          : _buildContentState(),
    );
  }

  Widget _buildLoadingState() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(
                left: 16, 
                right: 16, 
                top: 32, 
                bottom: 24
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE2D3FA), Color(0xFFF6EDFF)],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Shimmer(
                            child: Container(
                              width: 120,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.black),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Shimmer(
                        child: Container(
                          width: 120,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      Shimmer(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer(
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Shimmer(
                    child: Container(
                      width: 160,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: List.generate(
                      6,
                      (index) => Shimmer(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentState() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SafeArea(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(
                left: 16, 
                right: 16, 
                top: 32, 
                bottom: 24
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE2D3FA), Color(0xFFF6EDFF)],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Text(
                            widget.date,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 22, // Increased text size
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 26), // Increased icon size
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Temperature display
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${weatherData['max_temp'].round()}°",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 64, // Increased text size
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // Weather icon and condition text below it
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildAnimatedWeatherIcon(),
                          const SizedBox(height: 8),
                          Text(
                            weatherData['condition'],
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 18, // Increased text size
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHourlyForecast(),
                const SizedBox(height: 24),
                _buildWeatherGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedWeatherIcon() {
    // Animated weather icon with animation controller
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animationController.value * 3),
          child: SizedBox(
            width: 64, // Increased icon size
            height: 64, // Increased icon size
            child: weatherData['icon'],
          ),
        );
      },
    );
  }

  Widget _buildHourlyForecast() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.access_time, size: 22), // Increased icon size
              SizedBox(width: 8),
              Text(
                'Hourly forecast',
                style: TextStyle(
                  fontSize: 18, // Increased text size
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120, // Increased height
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hourlyForecast.length,
              itemBuilder: (context, index) {
                final hour = hourlyForecast[index];
                // Use animated icon for hourly forecast
                return Container(
                  width: 70, // Increased width
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hour['time'],
                        style: const TextStyle(
                          fontSize: 16, // Increased text size
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _animationController.value * 2),
                            child: SizedBox(
                              width: 32, // Increased icon size
                              height: 32, // Increased icon size
                              child: hour['icon'],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${hour['temp'].round()}°',
                        style: const TextStyle(
                          fontSize: 18, // Increased text size
                          fontWeight: FontWeight.w600,
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

  Widget _buildWeatherGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weather Details',
          style: TextStyle(
            color: Color(0xFF6750A4),
            fontSize: 22, // Increased text size
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildWeatherCard(
              'Wind',
              '${weatherData['wind']} km/h',
              weatherData['wind_direction']?.toString() ?? '',
              'assets/icons/wind.png',
            ),
            _buildWeatherCard(
              'Humidity',
              '${weatherData['humidity']}%',
              '',
              'assets/icons/dewpoint.png',
            ),
            _buildWeatherCard(
              'UV Index',
              weatherData['uvIndex']?.toString() ?? '',
              'Very high',
              'assets/icons/sun.png',
            ),
            _buildWeatherCard(
              'Pressure',
              '${weatherData['pressure']} hPa',
              '',
              'assets/icons/pressuregauge.png',
            ),
            _buildWeatherCard(
              'Rain chance',
              '${weatherData['rainChance']}%',
              '',
              'assets/icons/rain.png',
            ),
            _buildWeatherCard(
              'Rain level',
              '${weatherData['rain_level']} mm',
              'Expected',
              'assets/icons/raingauge.png',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherCard(
    String title,
    String value,
    String subtitle,
    String iconAsset,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                iconAsset,
                width: 24, // Increased icon size
                height: 24, // Increased icon size
                fit: BoxFit.fill,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF6750A4).withOpacity(0.7),
                  fontSize: 16, // Increased text size
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF6750A4),
              fontSize: 22, // Increased text size
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: TextStyle(
                color: const Color(0xFF6750A4).withOpacity(0.7),
                fontSize: 14, // Increased text size
              ),
            ),
        ],
      ),
    );
  }
}