import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hava/pages/search/location_weather_seven_days.dart';
import 'package:hava/pages/search/location_weather_today.dart';
import 'package:hava/pages/search/location_weather_tomorrow.dart';
import 'package:intl/intl.dart';
import 'package:hava/services/external_weather_service.dart';

class LocationWeatherPage extends StatefulWidget {
  final Map<String, dynamic> weatherData;
  final ExternalWeatherService weatherService;

  const LocationWeatherPage({
    Key? key,
    required this.weatherData,
    required this.weatherService,
  }) : super(key: key);

  @override
  State<LocationWeatherPage> createState() => _LocationWeatherPageState();
}

class _LocationWeatherPageState extends State<LocationWeatherPage> with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  late bool _isDaytime;
  bool _isExpanded = false;
  final double _collapsedHeight = 285.0;
  final double _expandedHeight = 600.0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _determineDayNightStatus();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(
      begin: _collapsedHeight,
      end: _expandedHeight,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _determineDayNightStatus() {
    final localTime = widget.weatherData['localtime'] ?? DateTime.now().toString();
    try {
      final locationTime = DateTime.parse(localTime);
      final hour = locationTime.hour;
      _isDaytime = hour >= 6 && hour < 18;
    } catch (e) {
      _isDaytime = true; // Default to daytime if parsing fails
    }
  }

  Widget _buildTabButton(String text, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTabIndex = (text == "Today") ? 0 : (text == "Tomorrow") ? 1 : 2;
        });
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected ? const Color(0xFFE0B6FF) : const Color(0xFFF6EDFF),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? const Color(0xFF2E004E) : const Color(0xFF000000),
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentForTab(int tabIndex) {
    if (widget.weatherData['forecast'] == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text("No forecast data available"),
        ),
      );
    }

    final forecastData = widget.weatherData['forecast'] as List;

    switch (tabIndex) {
      case 0:
        return WeatherToday(
          forecastData: forecastData,
          isDaytime: _isDaytime,
          weatherService: widget.weatherService,
        );
      case 1:
        return WeatherTomorrow(
          forecastData: forecastData,
          isDaytime: _isDaytime,
          weatherService: widget.weatherService,
        );
      case 2:
        return Weather7Days(
          forecastData: forecastData,
          isDaytime: _isDaytime,
          weatherService: widget.weatherService,
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final temp = widget.weatherData['temp']?.toString() ?? '0';
    final feelsLike = widget.weatherData['wbt']?.toString() ?? '0';
    final condition = widget.weatherData['condition'] ?? 'Unknown';
    final location = widget.weatherData['location'] ?? 'Unknown Location';
    final country = widget.weatherData['country'] ?? '';
    final weatherIcon = widget.weatherService.getWeatherIcon(
      condition,
      time: DateTime.now(),
      sunrise: widget.weatherData['sunrise'],
      sunset: widget.weatherData['sunset'],
    );

    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('EEEE, MMM d').format(now);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              _isDaytime
                ? 'assets/images/backgroundnewsun.jpg'
                : 'assets/images/backgroundnewmoon.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Back Button
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Location Info
          Positioned(
            top: 90,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  location.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (country.isNotEmpty)
                  Text(
                    country,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Weather Info (collapsed)
          if (!_isExpanded) ...[
            Positioned(
              bottom: _collapsedHeight + 10,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        temp,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "°C",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Feels like ${feelsLike}°",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: _collapsedHeight + 10,
              right: 20,
              child: Column(
                children: [
                  SvgPicture.asset(  // Changed from Image.asset to SvgPicture.asset
                    weatherIcon,
                    width: 60,
                    height: 60,
                  ),
                  Text(
                    condition,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Draggable Panel
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: _animation.value,
                child: GestureDetector(
                  onVerticalDragEnd: (details) {
                    if (details.velocity.pixelsPerSecond.dy < -500 && !_isExpanded) {
                      _toggleExpansion();
                    } else if (details.velocity.pixelsPerSecond.dy > 500 && _isExpanded) {
                      _toggleExpansion();
                    }
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF6EDFF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Drag handle
                        Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),

                        // Tab buttons
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildTabButton("Today", _selectedTabIndex == 0),
                              _buildTabButton("Tomorrow", _selectedTabIndex == 1),
                              _buildTabButton("3 Days", _selectedTabIndex == 2),
                            ],
                          ),
                        ),

                        // Content
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: _buildContentForTab(_selectedTabIndex),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Expand indicator (only when collapsed)
          if (!_isExpanded)
            Positioned(
              bottom: _collapsedHeight - 24,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}