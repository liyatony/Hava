import 'package:flutter/material.dart';

class HourlyForecastWidget extends StatelessWidget {
  final List<Map<String, dynamic>> hourlyData;
  final DateTime targetDate;

  const HourlyForecastWidget({
    Key? key,
    required this.hourlyData,
    required this.targetDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(width: 8), // Added spacing at the beginning to move icon right
              const Icon(Icons.access_time, size: 24),
              const SizedBox(width: 8),
              Text(
                "Hourly forecast ${_getDateLabel(targetDate)}",
                style: const TextStyle(
                  fontSize: 17, // Increased from 15 to 17
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hourlyData.length,
              itemBuilder: (context, index) {
                final hour = hourlyData[index];
                return Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hour['time'] ?? '',
                        style: const TextStyle(
                          fontSize: 15, // Increased from 14 to 15
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildIconWidget(hour['icon']),
                      const SizedBox(height: 8),
                      Text(
                        '${hour['temp']?.toStringAsFixed(1)}°',
                        style: const TextStyle(
                          fontSize: 18, // Increased from 16 to 18
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

  Widget _buildIconWidget(dynamic icon) {
  // Handle SVG loading issue
  if (icon is Widget) {
    return SizedBox(
      width: 48,  // Increased from 36
      height: 48, // Increased from 36
      child: icon,
    );
  }
  return SizedBox(width: 48, height: 48); // Also update the fallback size
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