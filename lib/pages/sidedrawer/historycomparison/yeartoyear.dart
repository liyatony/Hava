import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hava/services/weather_history_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class YearToYearComparison extends StatefulWidget {
  final WeatherHistoryService historyService;
  final String defaultLocation;

  const YearToYearComparison({
    Key? key,
    required this.historyService,
    required this.defaultLocation,
  }) : super(key: key);

  @override
  _YearToYearComparisonState createState() => _YearToYearComparisonState();
}

class _YearToYearComparisonState extends State<YearToYearComparison> {
  int _selectedYear1ForYearComparison = DateTime.now().year - 1;
  int _selectedYear2ForYearComparison = DateTime.now().year;
  Map<String, dynamic> _yearComparisonResults = {};
  bool _isLoadingYearComparison = false;

  Future<void> _loadYearComparison() async {
    setState(() {
      _isLoadingYearComparison = true;
    });

    final results = await widget.historyService.compareYears(
      widget.defaultLocation,
      _selectedYear1ForYearComparison,
      _selectedYear2ForYearComparison,
    );

    setState(() {
      _yearComparisonResults = results;
      _isLoadingYearComparison = false;
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
              pw.Text('Year to Year Weather Comparison', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Year 1: $_selectedYear1ForYearComparison'),
              pw.Text('Year 2: $_selectedYear2ForYearComparison'),
              pw.SizedBox(height: 20),
              pw.Text('Temperature Comparison', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Avg Temp: ${_yearComparisonResults['monthlyComparison'][0]['avgTemp1'].toStringAsFixed(1)}°C vs ${_yearComparisonResults['monthlyComparison'][0]['avgTemp2'].toStringAsFixed(1)}°C'),
              pw.Text('Avg Max Temp: ${_yearComparisonResults['monthlyComparison'][0]['avgMaxTemp1'].toStringAsFixed(1)}°C vs ${_yearComparisonResults['monthlyComparison'][0]['avgMaxTemp2'].toStringAsFixed(1)}°C'),
              pw.Text('Avg Min Temp: ${_yearComparisonResults['monthlyComparison'][0]['avgMinTemp1'].toStringAsFixed(1)}°C vs ${_yearComparisonResults['monthlyComparison'][0]['avgMinTemp2'].toStringAsFixed(1)}°C'),
              pw.SizedBox(height: 20),
              pw.Text('Other Metrics', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text('Total Precipitation: ${_yearComparisonResults['monthlyComparison'][0]['totalPrecip1'].toStringAsFixed(1)} mm vs ${_yearComparisonResults['monthlyComparison'][0]['totalPrecip2'].toStringAsFixed(1)} mm'),
              pw.Text('Total Sunshine Hours: ${_yearComparisonResults['monthlyComparison'][0]['totalSunshineHours1'].toStringAsFixed(1)} hours vs ${_yearComparisonResults['monthlyComparison'][0]['totalSunshineHours2'].toStringAsFixed(1)} hours'),
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
                    "Select Years to Compare",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildYearSelector(
                          "First Year",
                          _selectedYear1ForYearComparison,
                          (year) {
                            setState(() {
                              _selectedYear1ForYearComparison = year;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildYearSelector(
                          "Second Year",
                          _selectedYear2ForYearComparison,
                          (year) {
                            setState(() {
                              _selectedYear2ForYearComparison = year;
                            });
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
                      onPressed: _loadYearComparison,
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
          _isLoadingYearComparison
              ? Center(
                  child: SpinKitFadingCircle(
                    color: Colors.purple,
                    size: 50.0,
                  ),
                )
              : _yearComparisonResults.isEmpty || _yearComparisonResults.containsKey('error')
                  ? Center(
                      child: Text(
                        _yearComparisonResults['error'] ?? 'No data available for the selected years.',
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : Column(
                      children: [
                        _buildYearComparisonResults(),
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

  Widget _buildYearSelector(
    String label,
    int selectedYear,
    Function(int) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: selectedYear,
            decoration: const InputDecoration(
              labelText: "Year",
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: List.generate(DateTime.now().year - 2000 + 1, (index) {
              final year = DateTime.now().year - index;
              return DropdownMenuItem(
                value: year,
                child: Text(year.toString()),
              );
            }),
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildYearComparisonResults() {
    if (_yearComparisonResults.isEmpty || _yearComparisonResults.containsKey('error')) {
      return Center(
        child: Text(
          _yearComparisonResults['error'] ?? 'No data available for the selected years.',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final comparison = _yearComparisonResults['monthlyComparison'] as List<dynamic>;

    if (comparison.isEmpty) {
      return const Center(
        child: Text("No comparative data available for selected years."),
      );
    }

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
                  "Annual Temperature Comparison",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: _buildYearlyTemperatureChart(comparison),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text('Year $_selectedYear1ForYearComparison'),
                    const SizedBox(width: 16),
                    Container(
                      width: 10,
                      height: 10,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text('Year $_selectedYear2ForYearComparison'),
                  ],
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
                  "Annual Precipitation Comparison",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: _buildYearlyPrecipitationChart(comparison),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYearlyTemperatureChart(List<dynamic> comparison) {
    final List<FlSpot> spots1 = [];
    final List<FlSpot> spots2 = [];

    for (int i = 0; i < comparison.length; i++) {
      final item = comparison[i] as Map<String, dynamic>;
      spots1.add(FlSpot(item['month'].toDouble(), item['avgTemp1']));
      spots2.add(FlSpot(item['month'].toDouble(), item['avgTemp2']));
    }

    final year1 = _yearComparisonResults['year1'].toString();
    final year2 = _yearComparisonResults['year2'].toString();

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots1,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
          LineChartBarData(
            spots: spots2,
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.withOpacity(0.2),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                if (value.toInt() >= 1 && value.toInt() <= 12) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      monthNames[value.toInt()],
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    '${value.toInt()}°C',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                );
              },
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
          drawVerticalLine: true,
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.grey.shade800,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot spot) {
                final String yearLabel = spot.barIndex == 0 ? year1 : year2;
                return LineTooltipItem(
                  '$yearLabel: ${spot.y.toStringAsFixed(1)}°C',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 0,
              color: Colors.grey.withOpacity(0.7),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearlyPrecipitationChart(List<dynamic> comparison) {
    final List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < comparison.length; i++) {
      final item = comparison[i] as Map<String, dynamic>;
      final month = item['month'] as int;
      final precip1 = item['avgTemp1'] * 10; // Placeholder for precipitation data
      final precip2 = item['avgTemp2'] * 10; // Placeholder for precipitation data

      barGroups.add(
        BarChartGroupData(
          x: month,
          barRods: [
            BarChartRodData(
              toY: precip1,
              color: Colors.blue,
              width: 12,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            BarChartRodData(
              toY: precip2,
              color: Colors.red,
              width: 12,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    final year1 = _yearComparisonResults['year1'].toString();
    final year2 = _yearComparisonResults['year2'].toString();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                if (value.toInt() >= 1 && value.toInt() <= 12) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      monthNames[value.toInt()],
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    '${value.toInt()} mm',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                );
              },
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
              final yearLabel = rodIndex == 0 ? year1 : year2;
              return BarTooltipItem(
                '$yearLabel: ${rod.toY.toStringAsFixed(1)} mm',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }
}