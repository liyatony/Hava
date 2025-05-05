import 'package:flutter/material.dart';
import 'package:hava/services/weather_history_service.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DayToDayComparison extends StatefulWidget {
  final WeatherHistoryService historyService;
  final String defaultLocation;

  const DayToDayComparison({
    Key? key,
    required this.historyService,
    required this.defaultLocation,
  }) : super(key: key);

  @override
  _DayToDayComparisonState createState() => _DayToDayComparisonState();
}

class _DayToDayComparisonState extends State<DayToDayComparison> {
  DateTime _selectedDate1 = DateTime.now().subtract(const Duration(days: 1));
  DateTime _selectedDate2 = DateTime.now();
  Map<String, dynamic> _dateComparisonResults = {};
  bool _isLoadingDateComparison = false;

  Future<void> _loadDateComparison() async {
    setState(() {
      _isLoadingDateComparison = true;
    });

    final results = await widget.historyService.compareDates(
      widget.defaultLocation,
      _selectedDate1,
      _selectedDate2,
    );

    setState(() {
      _dateComparisonResults = results;
      _isLoadingDateComparison = false;
    });
  }

  Future<void> _exportToPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Day to Day Weather Comparison', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Date 1: ${DateFormat('MMM d, y').format(_selectedDate1)}'),
              pw.Text('Date 2: ${DateFormat('MMM d, y').format(_selectedDate2)}'),
              pw.SizedBox(height: 20),
              pw.Text('Temperature Comparison', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Max Temp: ${_dateComparisonResults['data1'].tempMax.toStringAsFixed(1)}°C vs ${_dateComparisonResults['data2'].tempMax.toStringAsFixed(1)}°C'),
              pw.Text('Avg Temp: ${_dateComparisonResults['data1'].temp.toStringAsFixed(1)}°C vs ${_dateComparisonResults['data2'].temp.toStringAsFixed(1)}°C'),
              pw.Text('Min Temp: ${_dateComparisonResults['data1'].tempMin.toStringAsFixed(1)}°C vs ${_dateComparisonResults['data2'].tempMin.toStringAsFixed(1)}°C'),
              pw.SizedBox(height: 20),
              pw.Text('Other Metrics', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text('Humidity: ${_dateComparisonResults['data1'].humidity.toStringAsFixed(1)}% vs ${_dateComparisonResults['data2'].humidity.toStringAsFixed(1)}%'),
              pw.Text('Precipitation: ${_dateComparisonResults['data1'].precip.toStringAsFixed(2)} mm vs ${_dateComparisonResults['data2'].precip.toStringAsFixed(2)} mm'),
              pw.Text('Wind Speed: ${_dateComparisonResults['data1'].windSpeed.toStringAsFixed(1)} km/h vs ${_dateComparisonResults['data2'].windSpeed.toStringAsFixed(1)} km/h'),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Dates to Compare",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateSelector(
                          "First Date",
                          _selectedDate1,
                          (newDate) {
                            setState(() {
                              _selectedDate1 = newDate;
                            });
                            _loadDateComparison();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDateSelector(
                          "Second Date",
                          _selectedDate2,
                          (newDate) {
                            setState(() {
                              _selectedDate2 = newDate;
                            });
                            _loadDateComparison();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.compare_arrows),
                      label: const Text("Compare"),
                      onPressed: _loadDateComparison,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD0BCFF),
                        foregroundColor: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _isLoadingDateComparison
              ? Center(
                  child: SpinKitFadingCircle(
                    color: Colors.purple,
                    size: 50.0,
                  ),
                )
              : _dateComparisonResults.containsKey('error')
                  ? Center(
                      child: Text(
                        _dateComparisonResults['error'],
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : Column(
                      children: [
                        _buildDateComparisonResults(),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _exportToPDF,
                          child: const Text('Export to PDF'),
                        ),
                      ],
                    ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(
    String label,
    DateTime selectedDate,
    Function(DateTime) onDateChanged,
  ) {
    final dateFormat = DateFormat('MMM d, y');

    return InkWell(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );

        if (pickedDate != null) {
          onDateChanged(pickedDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(selectedDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateComparisonResults() {
    if (_dateComparisonResults.isEmpty) {
      return const Center(
        child: Text("Select dates to compare weather data."),
      );
    }

    final data1 = _dateComparisonResults['data1'] as HistoricalWeatherData;
    final data2 = _dateComparisonResults['data2'] as HistoricalWeatherData;
    final date1 = DateFormat('MMM d, y').format(data1.datetime);
    final date2 = DateFormat('MMM d, y').format(data2.datetime);

    return Column(
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Temperature Comparison",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 220,
                  child: _buildTemperatureComparisonChart(data1, data2, date1, date2),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Weather Details Comparison",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                _buildComparisonTable(data1, data2, date1, date2),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTemperatureComparisonChart(
    HistoricalWeatherData data1,
    HistoricalWeatherData data2,
    String date1,
    String date2,
  ) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _calculateMaxY(data1, data2),
        minY: _calculateMinY(data1, data2),
        barGroups: [
          _buildBarGroup(0, 'Max Temp', data1.tempMax, data2.tempMax, Colors.red),
          _buildBarGroup(1, 'Avg Temp', data1.temp, data2.temp, Colors.amber),
          _buildBarGroup(2, 'Min Temp', data1.tempMin, data2.tempMin, Colors.blue),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const titles = ['Max', 'Avg', 'Min'];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    titles[value.toInt()],
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          drawHorizontalLine: true,
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.grey.shade800,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rodIndex == 0 ? date1 : date2}: ${rod.toY.toStringAsFixed(1)}°C',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(
    int x,
    String title,
    double y1,
    double y2,
    Color color,
  ) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: color.withOpacity(0.6),
          width: 15,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
        BarChartRodData(
          toY: y2,
          color: color,
          width: 15,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
    );
  }

  double _calculateMaxY(HistoricalWeatherData data1, HistoricalWeatherData data2) {
    return [data1.tempMax, data2.tempMax].reduce((curr, next) => curr > next ? curr : next) + 5;
  }

  double _calculateMinY(HistoricalWeatherData data1, HistoricalWeatherData data2) {
    double min = [data1.tempMin, data2.tempMin].reduce((curr, next) => curr < next ? curr : next);
    return min > 0 ? 0 : min - 5;
  }

  Widget _buildComparisonTable(
    HistoricalWeatherData data1,
    HistoricalWeatherData data2,
    String date1,
    String date2,
  ) {
    return Table(
      border: TableBorder.all(
        color: Colors.grey.shade300,
        width: 1,
        style: BorderStyle.solid,
      ),
      columnWidths: const {
        0: FlexColumnWidth(1.5),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
      },
      children: [
        _buildTableHeaderRow(date1, date2),
        _buildTableDataRow(
          "Temperature (°C)",
          "${data1.temp.toStringAsFixed(1)}°C",
          "${data2.temp.toStringAsFixed(1)}°C",
          _buildDifferenceText(data2.temp - data1.temp, '°C'),
        ),
        _buildTableDataRow(
          "Max Temperature",
          "${data1.tempMax.toStringAsFixed(1)}°C",
          "${data2.tempMax.toStringAsFixed(1)}°C",
          _buildDifferenceText(data2.tempMax - data1.tempMax, '°C'),
        ),
        _buildTableDataRow(
          "Min Temperature",
          "${data1.tempMin.toStringAsFixed(1)}°C",
          "${data2.tempMin.toStringAsFixed(1)}°C",
          _buildDifferenceText(data2.tempMin - data1.tempMin, '°C'),
        ),
        _buildTableDataRow(
          "Humidity",
          "${data1.humidity.toStringAsFixed(1)}%",
          "${data2.humidity.toStringAsFixed(1)}%",
          _buildDifferenceText(data2.humidity - data1.humidity, '%'),
        ),
        _buildTableDataRow(
          "Precipitation",
          "${data1.precip.toStringAsFixed(2)} mm",
          "${data2.precip.toStringAsFixed(2)} mm",
          _buildDifferenceText(data2.precip - data1.precip, ' mm'),
        ),
        _buildTableDataRow(
          "Wind Speed",
          "${data1.windSpeed.toStringAsFixed(1)} km/h",
          "${data2.windSpeed.toStringAsFixed(1)} km/h",
          _buildDifferenceText(data2.windSpeed - data1.windSpeed, ' km/h'),
        ),
        _buildTableDataRow(
          "Pressure",
          "${data1.seaLevelPressure.toStringAsFixed(1)} hPa",
          "${data2.seaLevelPressure.toStringAsFixed(1)} hPa",
          _buildDifferenceText(data2.seaLevelPressure - data1.seaLevelPressure, 'hPa'),
        ),
        _buildTableDataRow(
          "Cloud Cover",
          "${data1.cloudCover.toStringAsFixed(1)}%",
          "${data2.cloudCover.toStringAsFixed(1)}%",
          _buildDifferenceText(data2.cloudCover - data1.cloudCover, '%'),
        ),
        _buildTableDataRow(
          "Sunshine Hours",
          "${data1.sunshineHours.toStringAsFixed(1)} hours",
          "${data2.sunshineHours.toStringAsFixed(1)} hours",
          _buildDifferenceText(data2.sunshineHours - data1.sunshineHours, ' hours'),
        ),
        _buildTableDataRow(
          "Conditions",
          data1.conditions,
          data2.conditions,
          "",
        ),
      ],
    );
  }

  TableRow _buildTableHeaderRow(String date1, String date2) {
    return TableRow(
      decoration: BoxDecoration(
        color: const Color(0xFFD0BCFF).withOpacity(0.3),
      ),
      children: [
        _buildTableCell("Metric", isHeader: true),
        _buildTableCell(date1, isHeader: true),
        _buildTableCell(date2, isHeader: true),
        _buildTableCell("Difference", isHeader: true),
      ],
    );
  }

  TableRow _buildTableDataRow(
    String metric,
    String value1,
    String value2,
    String difference,
  ) {
    return TableRow(
      children: [
        _buildTableCell(metric, alignment: Alignment.centerLeft),
        _buildTableCell(value1),
        _buildTableCell(value2),
        _buildTableCell(difference),
      ],
    );
  }

  Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    Alignment alignment = Alignment.center,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      alignment: alignment,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: isHeader ? 14 : 13,
        ),
      ),
    );
  }

  String _buildDifferenceText(double difference, String unit) {
    if (difference == 0) {
      return "No change";
    }

    final sign = difference > 0 ? "+" : "";
    final color = difference > 0 ? Colors.red : Colors.blue;

    return "$sign${difference.toStringAsFixed(1)}$unit";
  }
}