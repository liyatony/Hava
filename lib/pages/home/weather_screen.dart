import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:hava/pages/home/today_screen.dart';
import 'package:hava/pages/home/tomorrow_screen.dart';
import 'package:hava/pages/search/search_location.dart';
import 'package:hava/pages/sevendays/seven_days_page.dart';
import 'package:hava/pages/sidedrawer/sidedrawer.dart';
import 'package:hava/services/weather_service.dart';
import 'package:hava/services/external_weather_service.dart'; // Import the ExternalWeatherService

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final WeatherService _weatherService = WeatherService(); // Keep using WeatherService
  final ExternalWeatherService _externalWeatherService = ExternalWeatherService(); // Add ExternalWeatherService for search
  Map<String, dynamic> currentWeather = {};

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    final weather = await _weatherService.getCurrentWeather();
    setState(() {
      currentWeather = weather;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const CustomDrawer(),
      body: ForecastPage(
        weatherService: _weatherService, // Pass WeatherService
        externalWeatherService: _externalWeatherService, // Pass ExternalWeatherService
        currentWeather: currentWeather,
      ),
    );
  }
}

class ForecastPage extends StatefulWidget {
  final WeatherService weatherService; // Keep using WeatherService
  final ExternalWeatherService externalWeatherService; // Add ExternalWeatherService for search
  final Map<String, dynamic> currentWeather;

  const ForecastPage({
    super.key,
    required this.weatherService,
    required this.externalWeatherService, // Add this parameter
    required this.currentWeather,
  });

  @override
  State<ForecastPage> createState() => _ForecastPageState();
}

class _ForecastPageState extends State<ForecastPage> {
  int _selectedTabIndex = 0;
  static const double minAppBarHeight = 200.0;
  static const double maxAppBarHeight = 430.0;
  static const double backgroundHeight = 350.0;

  // Define max width for tab buttons in collapsed header
  static const double collapsedTabMaxWidth = 90.0;

  void _showSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchLocation(
        weatherService: widget.externalWeatherService, // Pass ExternalWeatherService for search
      ),
    );
  }
  
  Widget _buildTabButton(String text, bool isSelected, bool isCollapsed) {
    // Use a constrained width for collapsed tab buttons
    final double width = isCollapsed ? collapsedTabMaxWidth : 116;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTabIndex = (text == "Today")
              ? 0
              : (text == "Tomorrow")
                  ? 1
                  : 2;
        });
      },
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected
              ? const Color(0xFFE0B6FF)
              : const Color(0xFFF6EDFF),
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
              color: isSelected
                  ? const Color(0xFF2E004E)
                  : const Color(0xFF000000),
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    // Format as hour:minute (24-hour format)
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final temp = widget.currentWeather['temp']?.toString() ?? '0';
    final feelsLike = widget.currentWeather['wbt']?.toString() ?? '0';
    final condition = widget.currentWeather['condition'] ?? 'Unknown';
    final weatherIcon = widget.weatherService.buildWeatherIcon(condition); // Use WeatherService for weather icon
    
    // Calculate available screen width for layout decisions
    final screenWidth = MediaQuery.of(context).size.width;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          pinned: true,
          expandedHeight: maxAppBarHeight,
          collapsedHeight: minAppBarHeight,
          backgroundColor: const Color(0xFFF6EDFF),
          elevation: 0,
          toolbarHeight: 0,
          leadingWidth: 0,
          leading: null,
          actions: const [],
          flexibleSpace: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double percentScrolled = ((maxAppBarHeight - constraints.maxHeight) /
                      (maxAppBarHeight - minAppBarHeight))
                  .clamp(0.0, 1.0);

              return FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: EdgeInsets.zero,
                title: percentScrolled > 0.5
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE2D3FA),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Text(
                                    "Choondacherry,Kottayam",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(
                                        Icons.search,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                      onPressed: _showSearch,
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(
                                        Icons.menu,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        Scaffold.of(context).openEndDrawer();
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${temp}°",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: weatherIcon,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildTabButton("Today", _selectedTabIndex == 0, true),
                                _buildTabButton("Tomorrow", _selectedTabIndex == 1, true),
                                _buildTabButton("7 Days", _selectedTabIndex == 2, true),
                              ],
                            ),
                          ],
                        ),
                      )
                    : null,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: backgroundHeight,
                      child: ClipPath(
                        clipper: CurvedBottomClipper(),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF6EDFF),
                                  image: DecorationImage(
                                    image: AssetImage('assets/images/backgroundnew.jpeg'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                color: const Color(0xFFE1D3FA)
                                    .withOpacity(percentScrolled),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      left: 24,
                      right: 24,
                      child: Opacity(
                        opacity: 1 - percentScrolled,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _getCurrentTime(), // Updated to use current time
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(
                                  Icons.signal_cellular_alt,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Text(
                                    "Choondacherry,Kottayam",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.search,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      onPressed: _showSearch,
                                    ),
                                    Builder(
                                      builder: (context) => IconButton(
                                        icon: const Icon(
                                          Icons.menu,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        onPressed: () {
                                          Scaffold.of(context).openEndDrawer();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // The main temperature/condition row that's causing the overflow
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Left side - temperature section
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${temp}°",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 80,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Feels like ${feelsLike}°",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                // Right side - weather condition section (modified to handle overflow)
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        width: 64,
                                        height: 64,
                                        child: weatherIcon,
                                      ),
                                      const SizedBox(height: 8),
                                      // Condition text with overflow handling
                                      Container(
                                        constraints: BoxConstraints(
                                          maxWidth: screenWidth * 0.4, // Limit to 40% of screen width
                                        ),
                                        child: Text(
                                          condition,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2, // Allow wrapping to two lines
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: backgroundHeight + 20,
                      left: 24,
                      right: 24,
                      child: Opacity(
                        opacity: 1 - percentScrolled,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildTabButton("Today", _selectedTabIndex == 0, false),
                            _buildTabButton("Tomorrow", _selectedTabIndex == 1, false),
                            _buildTabButton("7 Days", _selectedTabIndex == 2, false),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            if (_selectedTabIndex == 0) const TodayScreen(),
            if (_selectedTabIndex == 1) const TomorrowScreen(),
            if (_selectedTabIndex == 2) const SevenDaysScreen(),
          ]),
        ),
      ],
    );
  }
}

class CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height - 20);
    path.quadraticBezierTo(
      size.width * 0.05,
      size.height,
      size.width * 0.1,
      size.height,
    );
    path.lineTo(size.width * 0.9, size.height);
    path.quadraticBezierTo(
      size.width * 0.95,
      size.height,
      size.width,
      size.height - 20,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}