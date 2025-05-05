import 'package:flutter/material.dart';
import 'package:hava/services/weather_service.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class DisplayModeScreen extends StatefulWidget {
  const DisplayModeScreen({super.key});

  @override
  State<DisplayModeScreen> createState() => _DisplayModeScreenState();
}

class _DisplayModeScreenState extends State<DisplayModeScreen> with TickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic> _currentWeather = {};
  Map<String, dynamic> _sensorData = {};
  List<Map<String, dynamic>> _hourlyForecast = [];
  Timer? _updateTimer;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _hourlyScrollController;
  late ScrollController _scrollController;
  bool _isLoading = true;
  
  // Add animations for weather parameters
  final List<AnimationController> _paramAnimControllers = [];
  final List<Animation<double>> _paramAnimations = [];
  
  // Purple theme colors
  final Color _primaryColor = const Color(0xFF6A1B9A);
  final Color _secondaryColor = const Color(0xFF9C27B0);
  final Color _accentColor = const Color(0xFFE1BEE7);
  final Color _textColor = Colors.white;
  final Color _secondaryTextColor = Colors.white.withOpacity(0.8);
  final Color _cardColor = Colors.white.withOpacity(0.15);
  final Color _skeletonColor = Colors.white.withOpacity(0.1);
  
  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
    
    // Set up animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCirc,
    );
    
    // Start animation
    _animationController.forward();
    
    // Set up parameter animations
    _setupParameterAnimations();
    
    // Set up scroll controller for hourly forecast
    _scrollController = ScrollController();
    _hourlyScrollController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    
    // Start auto-scroll animation
    _startAutoScroll();
    
    // Set up a timer to update the data every 5 seconds
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchWeatherData();
    });
    
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }
  
  void _startAutoScroll() {
    _hourlyScrollController.addListener(() {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;
        if (currentScroll >= maxScroll) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.animateTo(
            currentScroll + 1,
            duration: const Duration(milliseconds: 100),
            curve: Curves.linear,
          );
        }
      }
    });
  }
  
  @override
  void dispose() {
    _updateTimer?.cancel();
    _animationController.dispose();
    _hourlyScrollController.dispose();
    _scrollController.dispose();
    for (var controller in _paramAnimControllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  Future<void> _fetchWeatherData() async {
    try {
      setState(() => _isLoading = true);
      
      final weatherData = await _weatherService.getCurrentWeather();
      final sensorData = await _weatherService.getCurrentSensorData();
      final hourlyData = await _weatherService.getHourlyForecast();
      
      if (mounted) {
        setState(() {
          _currentWeather = weatherData;
          _sensorData = sensorData;
          _hourlyForecast = hourlyData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching data for display mode: $e');
      setState(() => _isLoading = false);
    }
  }
  
  void _setupParameterAnimations() {
    // Clear previous controllers
    for (var controller in _paramAnimControllers) {
      controller.dispose();
    }
    _paramAnimControllers.clear();
    _paramAnimations.clear();
    
    // Create 6 animation controllers for parameters with staggered delays
    const int paramCount = 6;
    for (int i = 0; i < paramCount; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      );
      
      final animation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.elasticOut,
        ),
      );
      
      _paramAnimControllers.add(controller);
      _paramAnimations.add(animation);
      
      // Staggered animation with increasing delays
      Future.delayed(Duration(milliseconds: 200 + (i * 150)), () {
        if (mounted) {
          controller.forward();
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 1024;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_primaryColor, _secondaryColor],
            stops: const [0.1, 0.9],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _animation,
            child: _isLoading ? _buildSkeletonLoading(isSmallScreen) : _buildMonitorDisplay(isSmallScreen),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSkeletonLoading(bool isSmallScreen) {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(now);
    final formattedTime = DateFormat('h:mm a').format(now);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App title skeleton
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _skeletonColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 150,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _skeletonColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _skeletonColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          
          // Main card skeleton
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 180,
                      height: 18,
                      decoration: BoxDecoration(
                        color: _skeletonColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 120,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _skeletonColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _skeletonColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 80,
                          height: 52,
                          decoration: BoxDecoration(
                            color: _skeletonColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _skeletonColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Weather parameters skeleton
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: GridView.count(
                    crossAxisCount: isSmallScreen ? 2 : 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: isSmallScreen ? 1.6 : 1.8,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: List.generate(6, (index) => Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: _skeletonColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Container(
                                width: 80,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: _skeletonColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            width: double.infinity,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _skeletonColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            height: 4,
                            decoration: BoxDecoration(
                              color: _skeletonColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ),
                ),
                const SizedBox(width: 20),
                // Hourly forecast skeleton
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _skeletonColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Container(
                              width: 120,
                              height: 20,
                              decoration: BoxDecoration(
                                color: _skeletonColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ListView.builder(
                            itemCount: 5,
                            itemBuilder: (context, index) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: index % 2 == 0 
                                    ? _accentColor.withOpacity(0.15)
                                    : _accentColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: _skeletonColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: _skeletonColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    width: 60,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: _skeletonColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    width: 40,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: _skeletonColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Footer skeleton
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: Container(
                width: 200,
                height: 32,
                decoration: BoxDecoration(
                  color: _skeletonColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonitorDisplay(bool isSmallScreen) {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(now);
    final formattedTime = DateFormat('h:mm a').format(now);
    
    return Stack(
      children: [
        // Background floating elements
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accentColor.withOpacity(0.1),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accentColor.withOpacity(0.1),
            ),
          ),
        ),
        
        // Main content
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App title and logo with animated refresh
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Icon(
                        Icons.cloud,
                        key: ValueKey<bool>(_currentWeather['condition']?.contains('Sunny') ?? false),
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Hava Weather',
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _cardColor,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.refresh_rounded),
                        color: _textColor,
                        onPressed: () {
                          _fetchWeatherData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Refreshing weather data...'),
                              backgroundColor: _cardColor,
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // Floating card for time and temperature
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: _secondaryTextColor,
                            fontSize: isSmallScreen ? 14 : 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            fontSize: isSmallScreen ? 30 : 42,
                            fontWeight: FontWeight.bold,
                            color: _textColor,
                            letterSpacing: 1.2,
                          ),
                          child: Text(formattedTime),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (_currentWeather.containsKey('icon'))
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: SizedBox(
                              key: ValueKey<String>(_currentWeather['icon'].toString()),
                              height: isSmallScreen ? 60 : 80,
                              width: isSmallScreen ? 60 : 80,
                              child: _currentWeather['icon'],
                            ),
                          ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: isSmallScreen ? 34 : 52,
                                fontWeight: FontWeight.bold,
                                color: _textColor,
                              ),
                              child: Text(
                                '${_currentWeather['temp']?.toStringAsFixed(1) ?? '--'}°C',
                              ),
                            ),
                            const SizedBox(height: 8),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: _accentColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                _currentWeather['condition'] ?? 'Unknown',
                                style: TextStyle(
                                  color: _textColor,
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Expanded section with weather parameters and hourly forecast
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weather parameters section (left side)
                    Expanded(
                      flex: 3,
                      child: _buildWeatherParametersSection(isSmallScreen),
                    ),
                    const SizedBox(width: 20),
                    // Hourly forecast section (right side)
                    Expanded(
                      flex: 2,
                      child: _buildHourlyForecastSection(isSmallScreen),
                    ),
                  ],
                ),
              ),
              
              // Footer with last updated info
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.update,
                          size: 16,
                          color: _secondaryTextColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Data refreshes every 5 seconds',
                          style: TextStyle(
                            color: _secondaryTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildWeatherParametersSection(bool isSmallScreen) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine how many columns to display based on width
        final crossAxisCount = constraints.maxWidth < 600 ? 2 : 3;
        
        return GridView.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: isSmallScreen ? 1.6 : 1.8,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            _buildWeatherParameter(
              'Humidity',
              '${_sensorData['humidity']?.toStringAsFixed(0) ?? _currentWeather['humidity']?.toStringAsFixed(0) ?? '--'}%',
              Icons.water_drop_outlined,
              isSmallScreen,
              0,
              _accentColor,
            ),
            _buildWeatherParameter(
              'UV Index',
              '${_sensorData['uv_index']?.toStringAsFixed(1) ?? _currentWeather['uvIndex']?.toStringAsFixed(1) ?? '--'}',
              Icons.wb_sunny_outlined,
              isSmallScreen,
              1,
              const Color(0xFFCE93D8),
            ),
            _buildWeatherParameter(
              'Wind',
              '${_currentWeather['wind']?.toStringAsFixed(1) ?? '--'} km/h',
              Icons.air_outlined,
              isSmallScreen,
              2,
              const Color(0xFFBA68C8),
            ),
            _buildWeatherParameter(
              'Pressure',
              '${_sensorData['pressure']?.toStringAsFixed(0) ?? _currentWeather['pressure']?.toStringAsFixed(0) ?? '--'} hPa',
              Icons.speed_outlined,
              isSmallScreen,
              3,
              const Color(0xFFAB47BC),
            ),
            _buildWeatherParameter(
              'Rain Chance',
              '${_currentWeather['rainChance']?.toStringAsFixed(0) ?? '--'}%',
              Icons.umbrella_outlined,
              isSmallScreen,
              4,
              const Color(0xFF9C27B0),
            ),
            _buildWeatherParameter(
              'Feels Like',
              '${_currentWeather['wbt']?.toStringAsFixed(1) ?? '--'}°C',
              Icons.thermostat_outlined,
              isSmallScreen,
              5,
              const Color(0xFF8E24AA),
            ),
          ],
        );
      }
    );
  }
  
  Widget _buildWeatherParameter(
    String title, 
    String value, 
    IconData icon, 
    bool isSmallScreen, 
    int animIndex, 
    Color iconColor
  ) {
    // Fixed the opacity error by ensuring animation values are clamped
    final animation = _paramAnimations.length > animIndex 
        ? _paramAnimations[animIndex]
        : const AlwaysStoppedAnimation(1.0);
    
    return ScaleTransition(
      scale: animation,
      child: MouseRegion(
        onEnter: (_) {
          if (_paramAnimControllers.length > animIndex) {
            _paramAnimControllers[animIndex].forward(from: 0.8);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: iconColor.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: isSmallScreen ? 22 : 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: _textColor,
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: _textColor,
                  fontSize: isSmallScreen ? 26 : 32,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                child: Text(value),
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHourlyForecastSection(bool isSmallScreen) {
    if (_hourlyForecast.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _skeletonColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  width: 120,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _skeletonColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _skeletonColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _accentColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  color: _textColor,
                  size: isSmallScreen ? 20 : 22,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Hourly Forecast',
                style: TextStyle(
                  color: _textColor,
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                // Prevent user scrolling from interfering with auto-scroll
                if (scrollNotification is UserScrollNotification) {
                  return true;
                }
                return false;
              },
              child: ListView.builder(
                controller: _scrollController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _hourlyForecast.length,
                itemBuilder: (context, index) {
                  final hourData = _hourlyForecast[index];
                  
                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 400 + (index * 100)),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, (1 - value) * 20),
                        child: Opacity(
                          opacity: value.clamp(0.0, 1.0), // Fixed opacity error
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: (index % 2 == 0)
                            ? _accentColor.withOpacity(0.15)
                            : _accentColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _accentColor.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _accentColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              hourData['time'] ?? '--',
                              style: TextStyle(
                                color: _textColor,
                                fontSize: isSmallScreen ? 12 : 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: SizedBox(
                              key: ValueKey<String>(hourData['icon'].toString()),
                              height: 36,
                              width: 36,
                              child: hourData['icon'] ?? Icon(Icons.cloud, color: _textColor),
                            ),
                          ),
                          const SizedBox(width: 16),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              color: _textColor,
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.w600,
                            ),
                            child: Text('${hourData['temp']?.toStringAsFixed(1) ?? '--'}°C'),
                          ),
                          const Spacer(),
                          if (hourData.containsKey('rainProb'))
                            Row(
                              children: [
                                Icon(
                                  Icons.water_drop,
                                  color: _accentColor,
                                  size: isSmallScreen ? 16 : 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${hourData['rainProb']?.toStringAsFixed(0) ?? '0'}%',
                                  style: TextStyle(
                                    color: _textColor,
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}