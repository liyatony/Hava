import 'package:flutter/material.dart';
import 'package:hava/pages/sidedrawer/historycomparison/daytoday.dart';
import 'package:hava/pages/sidedrawer/historycomparison/monthtomonth.dart';
import 'package:hava/pages/sidedrawer/historycomparison/yeartoyear.dart';
import 'package:hava/services/weather_history_service.dart';

class WeatherHistoryScreen extends StatefulWidget {
  const WeatherHistoryScreen({Key? key}) : super(key: key);

  @override
  State<WeatherHistoryScreen> createState() => _WeatherHistoryScreenState();
}

class _WeatherHistoryScreenState extends State<WeatherHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final WeatherHistoryService _historyService = WeatherHistoryService();
  final String _defaultLocation = 'choondacherry';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather History Comparison"),
        backgroundColor: const Color(0xFFD0BCFF).withOpacity(0.7),
        toolbarHeight: 100,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Day to Day"),
            Tab(text: "Month to Month"),
            Tab(text: "Year to Year"),
          ],
        ),
      ),
      body: Container(
        color: const Color(0xFFF6EDFF),
        child: TabBarView(
          controller: _tabController,
          children: [
            DayToDayComparison(
              historyService: _historyService,
              defaultLocation: _defaultLocation,
            ),
            MonthToMonthComparison(
              historyService: _historyService,
              defaultLocation: _defaultLocation,
            ),
            YearToYearComparison(
              historyService: _historyService,
              defaultLocation: _defaultLocation,
            ),
          ],
        ),
      ),
    );
  }
}