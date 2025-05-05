import 'dart:convert';
import 'package:hava/services/env_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ExternalWeatherService {
  final String apiKey = EnvService.weatherApiKey;

  bool isDaytime(String localTime) {
    DateTime locationTime;

    try {
      locationTime = DateTime.parse(localTime);
    } catch (e) {
      print('Error parsing local time: $e');
      return true;
    }

    final hour = locationTime.hour;
    return hour >= 6 && hour < 18;
  }

  Future<Map<String, dynamic>> getWeatherByCity(String cityName) async {
    final url = 'https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$cityName&days=10&aqi=no&alerts=no';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final String localTime = data['location']['localtime'];
        final current = data['current'];
        final forecastDay = data['forecast']['forecastday'][0];

        return {
          'temp': current['temp_c'],
          'temp_f': current['temp_f'],
          'wbt': current['feelslike_c'],
          'wbt_f': current['feelslike_f'],
          'condition': current['condition']['text'],
          'location': '${data['location']['name']}, ${data['location']['region']}',
          'country': data['location']['country'],
          'localtime': localTime,
          'is_day': current['is_day'] == 1,
          'forecast': data['forecast']['forecastday'],
          'humidity': current['humidity'],
          'wind_kph': current['wind_kph'],
          'wind_mph': current['wind_mph'],
          'wind_dir': current['wind_dir'],
          'pressure_mb': current['pressure_mb'],
          'pressure_in': current['pressure_in'],
          'precip_mm': current['precip_mm'],
          'precip_in': current['precip_in'],
          'cloud': current['cloud'],
          'uv': current['uv'],
          'sunrise': forecastDay['astro']['sunrise'],
          'sunset': forecastDay['astro']['sunset'],
          'timezone': data['location']['tz_id'],
          'latitude': data['location']['lat'],
          'longitude': data['location']['lon'],
          'hourly_forecast': forecastDay['hour'],
          'daily_chance_of_rain': forecastDay['day']['daily_chance_of_rain'],
          'totalprecip_mm': forecastDay['day']['totalprecip_mm'],
          'avghumidity': forecastDay['day']['avghumidity'],
          'avgtemp_c': forecastDay['day']['avgtemp_c'],
          'maxwind_kph': forecastDay['day']['maxwind_kph'],
        };
      } else {
        print('Error status code: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Error fetching weather: $e');
      return {};
    }
  }

  Future<List<Map<String, String>>> searchCities(String query) async {
    if (query.isEmpty) {
      return [
        {'name': 'London', 'country': 'United Kingdom'},
        {'name': 'New York', 'country': 'United States of America'},
        {'name': 'Tokyo', 'country': 'Japan'},
        {'name': 'Paris', 'country': 'France'},
        {'name': 'Sydney', 'country': 'Australia'},
        {'name': 'Dubai', 'country': 'United Arab Emirates'},
        {'name': 'Singapore', 'country': 'Singapore'},
      ];
    }

    final url = 'https://api.weatherapi.com/v1/search.json?key=$apiKey&q=$query';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map<Map<String, String>>((city) => {
          'name': city['name'] as String,
          'country': city['country'] as String,
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error searching cities: $e');
      return [];
    }
  }

  bool _isDaytime(DateTime time, String? sunrise, String? sunset) {
    // If we have sunrise and sunset data, use it
    if (sunrise != null && sunset != null) {
      try {
        // Parse sunrise and sunset times (assuming they're in HH:MM AM/PM format)
        final sunriseTime = _parseTimeString(sunrise);
        final sunsetTime = _parseTimeString(sunset);
        
        // Convert current time to minutes since midnight
        final currentMinutes = time.hour * 60 + time.minute;
        final sunriseMinutes = sunriseTime.hour * 60 + sunriseTime.minute;
        final sunsetMinutes = sunsetTime.hour * 60 + sunsetTime.minute;
        
        return currentMinutes >= sunriseMinutes && currentMinutes < sunsetMinutes;
      } catch (e) {
        // Fall back to simple hour-based check if parsing fails
        print('Error parsing sunrise/sunset: $e');
      }
    }
    
    // Fallback: Simple daytime check (6 AM to 6 PM)
    final hour = time.hour;
    return hour >= 6 && hour < 18;
  }

  TimeOfDay _parseTimeString(String timeStr) {
    final parts = timeStr.split(' ');
    final timeParts = parts[0].split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final isPm = parts.length > 1 && parts[1].toLowerCase() == 'pm';
    
    return TimeOfDay(
      hour: isPm && hour < 12 ? hour + 12 : hour,
      minute: minute,
    );
  }

  String getWeatherIcon(String condition, {DateTime? time, String? sunrise, String? sunset}) {
    final currentTime = time ?? DateTime.now();
    final isDaytime = _isDaytime(currentTime, sunrise, sunset);
    
    condition = condition.toLowerCase();
    
    if (condition.contains('clear') || condition.contains('sunny')) {
      return isDaytime 
          ? 'assets/animations/clear_sunny.svg'
          : 'assets/animations/clear_night.svg';
    } else if (condition.contains('partly cloudy') || condition.contains('partially cloudy')) {
      return isDaytime
          ? 'assets/animations/partly_cloudy.svg'
          : 'assets/animations/partly_clear_night.svg';
    } else if (condition.contains('cloudy') || condition.contains('overcast')) {
      return 'assets/animations/cloudy.svg';
    } else if (condition.contains('rain')) {
      return 'assets/animations/rain.svg';
    } else if (condition.contains('thunder') || condition.contains('storm')) {
      return 'assets/animations/thunderstorm.svg';
    } else if (condition.contains('snow')) {
      return 'assets/animations/snow.svg';
    } else if (condition.contains('mist') || condition.contains('fog')) {
      return 'assets/animations/mist.svg';
    } else if (condition.contains('wind')) {
      return 'assets/animations/wind.svg';
    }
    
    return isDaytime
        ? 'assets/animations/partly_cloudy.svg'
        : 'assets/animations/partly_clear_night.svg';
  }

  String getWeatherBackgroundImage(bool isDay) {
    return isDay ? 'assets/images/backgroundnewsun.jpg' : 'assets/images/backgroundnewmoon.jpg';
  }
}