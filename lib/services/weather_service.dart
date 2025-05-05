import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class WeatherService {
  final SupabaseClient _supabase = Supabase.instance.client;
  Map<String, dynamic> _currentWeatherCache = {};
  List<Map<String, dynamic>> _dailyForecastCache = [];
  List<Map<String, dynamic>> _hourlyForecastCache = [];
  DateTime _lastFetchTime = DateTime.now().subtract(Duration(minutes: 5));

  // Helper function to safely convert to double
  double toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Widget buildWeatherIcon(String condition, {double size = 50, DateTime? time, String? sunrise, String? sunset}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Svg(
            getWeatherIcon(condition, time: time, sunrise: sunrise, sunset: sunset),
            size: Size(size, size),
          ),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  bool _isDaytime(DateTime time, String? sunrise, String? sunset) {
    if (sunrise == null || sunset == null) {
      // Fallback to simple hour-based check if sunrise/sunset not available
      final hour = time.hour;
      return hour >= 6 && hour < 18;
    }

    try {
      // Safely handle various time formats
      List<String> sunriseParts = sunrise.contains(':') 
          ? sunrise.split(':') 
          : ['6', '00']; // Default to 6:00 AM if format is invalid
      
      List<String> sunsetParts = sunset.contains(':') 
          ? sunset.split(':') 
          : ['18', '00']; // Default to 6:00 PM if format is invalid
      
      // Make sure we have at least hours and minutes
      if (sunriseParts.length < 2 || sunsetParts.length < 2) {
        return time.hour >= 6 && time.hour < 18;
      }
      
      final sunriseTime = TimeOfDay(
          hour: int.tryParse(sunriseParts[0]) ?? 6, 
          minute: int.tryParse(sunriseParts[1]) ?? 0);
      
      final sunsetTime = TimeOfDay(
          hour: int.tryParse(sunsetParts[0]) ?? 18, 
          minute: int.tryParse(sunsetParts[1]) ?? 0);
      
      final currentTime = TimeOfDay.fromDateTime(time);
      
      final currentMinutes = currentTime.hour * 60 + currentTime.minute;
      final sunriseMinutes = sunriseTime.hour * 60 + sunriseTime.minute;
      final sunsetMinutes = sunsetTime.hour * 60 + sunsetTime.minute;
      
      return currentMinutes >= sunriseMinutes && currentMinutes < sunsetMinutes;
    } catch (e) {
      print('Error parsing sunrise/sunset: $e');
      // Fallback to simple hour-based check
      final hour = time.hour;
      return hour >= 6 && hour < 18;
    }
  }

  String getWeatherIcon(String condition, {DateTime? time, String? sunrise, String? sunset}) {
    final currentTime = time ?? DateTime.now();
    final isDaytime = _isDaytime(currentTime, sunrise, sunset);
    
    // Normalize condition string to lowercase for case-insensitive matching
    final normalizedCondition = condition.toLowerCase().trim();
    
    // Check for rain-related conditions first (highest priority)
    if (normalizedCondition.contains('rain') || 
        normalizedCondition.contains('shower') ||
        normalizedCondition.contains('drizzle')) {
      return 'assets/animations/rain.svg';
    }
    
    // Check for thunderstorm conditions
    if (normalizedCondition.contains('thunder') || 
        normalizedCondition.contains('storm') ||
        normalizedCondition.contains('lightning')) {
      return 'assets/animations/thunderstorm.svg';
    }
    
    // Check for snow conditions
    if (normalizedCondition.contains('snow') || 
        normalizedCondition.contains('sleet') ||
        normalizedCondition.contains('ice')) {
      return 'assets/animations/snow.svg';
    }
    
    // Check for foggy conditions
    if (normalizedCondition.contains('mist') || 
        normalizedCondition.contains('fog') ||
        normalizedCondition.contains('haze')) {
      return 'assets/animations/mist.svg';
    }
    
    // Check for windy conditions
    if (normalizedCondition.contains('wind') || normalizedCondition.contains('gust')) {
      return 'assets/animations/wind.svg';
    }
    
    // Clear conditions
    if (normalizedCondition == 'clear' || normalizedCondition == 'sunny') {
      return isDaytime 
          ? 'assets/animations/clear_sunny.svg'
          : 'assets/animations/clear_night.svg';
    }
    
    // Partly cloudy conditions
    if (normalizedCondition.contains('partly cloudy') || 
        normalizedCondition.contains('partially cloudy')) {
      return isDaytime
          ? 'assets/animations/partly_cloudy.svg'
          : 'assets/animations/partly_clear_night.svg';
    }
    
    // Cloudy or overcast conditions
    if (normalizedCondition.contains('cloud') || normalizedCondition.contains('overcast')) {
      // If it contains "partly" or "partially", it's partly cloudy
      if (normalizedCondition.contains('partly') || normalizedCondition.contains('partially')) {
        return isDaytime
            ? 'assets/animations/partly_cloudy.svg'
            : 'assets/animations/partly_clear_night.svg';
      }
      // Otherwise it's fully cloudy
      return 'assets/animations/cloudy.svg';
    }
    
    // Default icon (partly cloudy for day/night)
    return isDaytime
        ? 'assets/animations/partly_cloudy.svg'
        : 'assets/animations/partly_clear_night.svg';
  }

  Future<Map<String, dynamic>> getCurrentSensorData() async {
    try {
      final response = await _supabase
          .from('sensor_data')
          .select('*')
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      return {
        'temperature': toDouble(response['temperature']),
        'humidity': toDouble(response['humidity']),
        'pressure': toDouble(response['pressure']),
        'uv_index': toDouble(response['uv_index']),
      };
    } catch (e) {
      print('Error fetching sensor data: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    if (_currentWeatherCache.isNotEmpty && DateTime.now().difference(_lastFetchTime).inMinutes < 3) {
      return _currentWeatherCache;
    }

    try {
      final now = DateTime.now();
      final response = await _supabase
          .from('weather_predictions')
          .select('*')
          .gte('datetime', now.toIso8601String())
          .limit(1)
          .single();

      final condition = response['condition'] as String;
      final sunrise = response['sunrise'] as String?;
      final sunset = response['sunset'] as String?;

      _currentWeatherCache = {
        'temp': toDouble(response['temp']),
        'condition': condition,
        'icon': buildWeatherIcon(
          condition, 
          size: 100, 
          time: now,
          sunrise: sunrise,
          sunset: sunset,
        ),
        'wind': toDouble(response['wind']),
        'humidity': toDouble(response['humidity']),
        'uvIndex': toDouble(response['uvIndex']),
        'pressure': toDouble(response['pressure']),
        'rainChance': toDouble(response['rainChance']),
        'wbt': toDouble(response['wbt']),
        'rain_level': toDouble(response['rain_level']),
        'wind_direction': toDouble(response['wind_direction']),
        'sunrise': sunrise,
        'sunset': sunset,
      };

      _lastFetchTime = DateTime.now();
      return _currentWeatherCache;
    } catch (e) {
      print('Error fetching current weather: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getDailyForecast() async {
    if (_dailyForecastCache.isNotEmpty && DateTime.now().difference(_lastFetchTime).inMinutes < 3) {
      return _dailyForecastCache;
    }

    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day);
      final endDate = startDate.add(const Duration(days: 8));

      final response = await _supabase
          .from('weather_predictions')
          .select('*')
          .gte('datetime', startDate.toIso8601String())
          .lt('datetime', endDate.toIso8601String())
          .order('datetime');

      Map<String, Map<String, dynamic>> dailyStats = {};

      for (var pred in response) {
        final date = DateTime.parse(pred['datetime']);
        final dateKey = DateTime(date.year, date.month, date.day).toIso8601String();

        if (!dailyStats.containsKey(dateKey)) {
          dailyStats[dateKey] = {
            'date': date,
            'min_temp': double.infinity,
            'max_temp': -double.infinity,
            'conditions': <String, int>{}, // Changed to Map<String, int> to track condition frequency
            'total_rain_chance': 0.0,
            'count': 0,
          };
        }

        final stats = dailyStats[dateKey]!;
        stats['min_temp'] = math.min(stats['min_temp'] as double, toDouble(pred['temp']));
        stats['max_temp'] = math.max(stats['max_temp'] as double, toDouble(pred['temp']));
        
        // Update condition counter
        final conditionsMap = stats['conditions'] as Map<String, int>;
        final condition = pred['condition'] as String;
        conditionsMap[condition] = (conditionsMap[condition] ?? 0) + 1;
        
        stats['total_rain_chance'] = (stats['total_rain_chance'] as double) + toDouble(pred['rainChance']);
        stats['count'] = (stats['count'] as int) + 1;

        if (!stats.containsKey('wind')) {
          stats['wind'] = toDouble(pred['wind']);
          stats['humidity'] = toDouble(pred['humidity']);
          stats['uvIndex'] = toDouble(pred['uvIndex']);
          stats['pressure'] = toDouble(pred['pressure']);
          stats['rain_level'] = toDouble(pred['rain_level']);
          stats['wind_direction'] = toDouble(pred['wind_direction']);
          stats['sunrise'] = pred['sunrise'];
          stats['sunset'] = pred['sunset'];
        }
      }

      _dailyForecastCache = dailyStats.values.map((stats) {
        // Find the most frequent condition
        final conditionsMap = stats['conditions'] as Map<String, int>;
        String mostFrequentCondition = 'Unknown';
        int maxCount = 0;

        conditionsMap.forEach((condition, count) {
          if (count > maxCount) {
            maxCount = count;
            mostFrequentCondition = condition;
          }
        });
        
        final noonTime = DateTime((stats['date'] as DateTime).year, 
                                (stats['date'] as DateTime).month, 
                                (stats['date'] as DateTime).day, 12);
        final sunrise = stats['sunrise'] as String?;
        final sunset = stats['sunset'] as String?;

        return {
          'date': stats['date'] as DateTime,
          'min_temp': (stats['min_temp'] as double).roundToDouble(),
          'max_temp': (stats['max_temp'] as double).roundToDouble(),
          'condition': mostFrequentCondition,
          'icon': buildWeatherIcon(
            mostFrequentCondition, 
            time: noonTime,
            sunrise: sunrise,
            sunset: sunset,
          ),
          'wind': stats['wind'],
          'humidity': stats['humidity'],
          'uvIndex': stats['uvIndex'],
          'pressure': stats['pressure'],
          'rainChance': ((stats['total_rain_chance'] as double) / (stats['count'] as int)).roundToDouble(),
          'rain_level': stats['rain_level'],
          'wind_direction': stats['wind_direction'],
          'sunrise': sunrise,
          'sunset': sunset,
        };
      }).toList()
        ..sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

      _lastFetchTime = DateTime.now();
      return _dailyForecastCache;
    } catch (e) {
      print('Error fetching daily forecast: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getHourlyForecast({DateTime? targetDate}) async {
    if (_hourlyForecastCache.isNotEmpty && DateTime.now().difference(_lastFetchTime).inMinutes < 3) {
      return _hourlyForecastCache;
    }

    try {
      final date = targetDate ?? DateTime.now();
      final startTime = DateTime(date.year, date.month, date.day);
      final endTime = startTime.add(const Duration(days: 1));

      final response = await _supabase
          .from('weather_predictions')
          .select('datetime, temp, condition, sunrise, sunset')
          .gte('datetime', startTime.toIso8601String())
          .lt('datetime', endTime.toIso8601String())
          .order('datetime');

      _hourlyForecastCache = response.map<Map<String, dynamic>>((data) {
        final datetime = DateTime.parse(data['datetime']);
        final condition = data['condition'] as String;
        final sunrise = data['sunrise'] as String?;
        final sunset = data['sunset'] as String?;
        final now = DateTime.now();

        String timeLabel;
        if (datetime.day == now.day && datetime.hour == now.hour) {
          timeLabel = 'Now';
        } else {
          timeLabel = '${datetime.hour}:00';
        }

        return {
          'time': timeLabel,
          'temp': toDouble(data['temp']),
          'condition': condition,
          'icon': buildWeatherIcon(
            condition, 
            time: datetime,
            sunrise: sunrise,
            sunset: sunset,
          ),
          'datetime': datetime,
          'sunrise': sunrise,
          'sunset': sunset,
        };
      }).toList();

      _lastFetchTime = DateTime.now();
      return _hourlyForecastCache;
    } catch (e) {
      print('Error fetching hourly forecast: $e');
      return [];
    }
  }
}