import 'package:supabase_flutter/supabase_flutter.dart';

class HistoricalWeatherData {
  final String location;
  final DateTime datetime;
  final double tempMax;
  final double tempMin;
  final double temp;
  final double humidity;
  final double precip;
  final String? precipType;
  final double? windGust;
  final double windSpeed;
  final double windDir;
  final double seaLevelPressure;
  final double cloudCover;
  final double? uvIndex;
  final DateTime sunrise;
  final DateTime sunset;
  final String conditions;
  final String icon;
  final double sunshineHours;

  HistoricalWeatherData({
    required this.location,
    required this.datetime,
    required this.tempMax,
    required this.tempMin,
    required this.temp,
    required this.humidity,
    required this.precip,
    this.precipType,
    this.windGust,
    required this.windSpeed,
    required this.windDir,
    required this.seaLevelPressure,
    required this.cloudCover,
    this.uvIndex,
    required this.sunrise,
    required this.sunset,
    required this.conditions,
    required this.icon,
    required this.sunshineHours,
  });

  factory HistoricalWeatherData.fromJson(Map<String, dynamic> json) {
    return HistoricalWeatherData(
      location: json['name'] as String,
      datetime: DateTime.parse(json['datetime']),
      tempMax: (json['tempmax'] as num).toDouble(),
      tempMin: (json['tempmin'] as num).toDouble(),
      temp: (json['temp'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      precip: (json['precip'] as num).toDouble(),
      precipType: json['preciptype'] as String?,
      windGust: json['windgust'] != null ? (json['windgust'] as num).toDouble() : null,
      windSpeed: (json['windspeed'] as num).toDouble(),
      windDir: (json['winddir'] as num).toDouble(),
      seaLevelPressure: (json['sealevelpressure'] as num).toDouble(),
      cloudCover: (json['cloudcover'] as num).toDouble(),
      uvIndex: json['uvindex'] != null ? (json['uvindex'] as num).toDouble() : null,
      sunrise: DateTime.parse(json['sunrise']),
      sunset: DateTime.parse(json['sunset']),
      conditions: json['conditions'] as String,
      icon: json['icon'] as String,
      sunshineHours: (json['sunshineHours'] as num?)?.toDouble() ?? 0,
    );
  }
}

class WeatherHistoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<HistoricalWeatherData?> getHistoricalDataForDate(String location, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('historical_weather')
          .select()
          .eq('name', location)
          .gte('datetime', startOfDay.toIso8601String())
          .lt('datetime', endOfDay.toIso8601String())
          .order('datetime', ascending: true)
          .limit(1);

      if (response != null && response.isNotEmpty) {
        return HistoricalWeatherData.fromJson(response[0]);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<HistoricalWeatherData>> getHistoricalDataForMonth(String location, int year, int month) async {
    try {
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = (month < 12)
          ? DateTime(year, month + 1, 1)
          : DateTime(year + 1, 1, 1);

      final response = await _supabase
          .from('historical_weather')
          .select()
          .eq('name', location)
          .gte('datetime', startOfMonth.toIso8601String())
          .lt('datetime', endOfMonth.toIso8601String())
          .order('datetime');

      return response.map<HistoricalWeatherData>((json) => HistoricalWeatherData.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<HistoricalWeatherData>> getHistoricalDataForYear(String location, int year) async {
    try {
      final startOfYear = DateTime(year, 1, 1);
      final endOfYear = DateTime(year + 1, 1, 1);

      final response = await _supabase
          .from('historical_weather')
          .select()
          .eq('name', location)
          .gte('datetime', startOfYear.toIso8601String())
          .lt('datetime', endOfYear.toIso8601String())
          .order('datetime');

      return response.map<HistoricalWeatherData>((json) => HistoricalWeatherData.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> compareDates(String location, DateTime date1, DateTime date2) async {
    final data1 = await getHistoricalDataForDate(location, date1);
    final data2 = await getHistoricalDataForDate(location, date2);

    if (data1 == null || data2 == null) {
      return {'error': 'Data not available for one or both dates'};
    }

    return {
      'date1': date1,
      'date2': date2,
      'data1': data1,
      'data2': data2,
      'tempDiff': data2.temp - data1.temp,
      'maxTempDiff': data2.tempMax - data1.tempMax,
      'minTempDiff': data2.tempMin - data1.tempMin,
      'humidityDiff': data2.humidity - data1.humidity,
      'precipDiff': data2.precip - data1.precip,
      'windSpeedDiff': data2.windSpeed - data1.windSpeed,
      'sunshineHoursDiff': data2.sunshineHours - data1.sunshineHours,
    };
  }

  Future<List<HistoricalWeatherData>> compareSameDayAcrossYears(
      String location, int day, int month, List<int> years) async {
    List<HistoricalWeatherData> results = [];

    for (final year in years) {
      final date = DateTime(year, month, day);
      final data = await getHistoricalDataForDate(location, date);
      if (data != null) {
        results.add(data);
      }
    }

    return results;
  }

  Future<List<Map<String, dynamic>>> getMonthlyAveragesForYear(String location, int year) async {
    List<Map<String, dynamic>> monthlyAverages = [];

    for (int month = 1; month <= 12; month++) {
      final monthData = await getHistoricalDataForMonth(location, year, month);

      if (monthData.isEmpty) {
        continue;
      }

      double avgTemp = 0;
      double avgMaxTemp = 0;
      double avgMinTemp = 0;
      double totalPrecip = 0;
      double totalSunshineHours = 0;

      for (var data in monthData) {
        avgTemp += data.temp;
        avgMaxTemp += data.tempMax;
        avgMinTemp += data.tempMin;
        totalPrecip += data.precip;
        totalSunshineHours += data.sunshineHours;
      }

      final count = monthData.length;
      monthlyAverages.add({
        'year': year,
        'month': month,
        'avgTemp': avgTemp / count,
        'avgMaxTemp': avgMaxTemp / count,
        'avgMinTemp': avgMinTemp / count,
        'totalPrecip': totalPrecip,
        'totalSunshineHours': totalSunshineHours,
        'daysCount': count,
      });
    }

    return monthlyAverages;
  }

  Future<Map<String, dynamic>> compareYears(String location, int year1, int year2) async {
    final averages1 = await getMonthlyAveragesForYear(location, year1);
    final averages2 = await getMonthlyAveragesForYear(location, year2);

    if (averages1.isEmpty || averages2.isEmpty) {
      return {
        'error': 'No data available for one or both years',
        'monthlyComparison': [],
      };
    }

    Map<int, Map<String, dynamic>> months1 = {};
    Map<int, Map<String, dynamic>> months2 = {};

    for (var avg in averages1) {
      months1[avg['month']] = avg;
    }

    for (var avg in averages2) {
      months2[avg['month']] = avg;
    }

    List<Map<String, dynamic>> comparison = [];

    for (int month = 1; month <= 12; month++) {
      if (months1.containsKey(month) && months2.containsKey(month)) {
        comparison.add({
          'month': month,
          'year1': year1,
          'year2': year2,
          'avgTemp1': months1[month]!['avgTemp'],
          'avgTemp2': months2[month]!['avgTemp'],
          'tempDiff': months2[month]!['avgTemp'] - months1[month]!['avgTemp'],
          'maxTempDiff': months2[month]!['avgMaxTemp'] - months1[month]!['avgMaxTemp'],
          'minTempDiff': months2[month]!['avgMinTemp'] - months1[month]!['avgMinTemp'],
          'precipDiff': months2[month]!['totalPrecip'] - months1[month]!['totalPrecip'],
          'sunshineHoursDiff': months2[month]!['totalSunshineHours'] - months1[month]!['totalSunshineHours'],
        });
      }
    }

    return {
      'year1': year1,
      'year2': year2,
      'monthlyComparison': comparison,
    };
  }
}