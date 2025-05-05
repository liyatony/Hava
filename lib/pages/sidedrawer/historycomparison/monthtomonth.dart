import 'package:flutter/material.dart';
import 'package:hava/services/weather_history_service.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class MonthToMonthComparison extends StatefulWidget {
  final WeatherHistoryService historyService;
  final String defaultLocation;

  const MonthToMonthComparison({
    Key? key,
    required this.historyService,
    required this.defaultLocation,
  }) : super(key: key);

  @override
  _MonthToMonthComparisonState createState() => _MonthToMonthComparisonState();
}

class _MonthToMonthComparisonState extends State<MonthToMonthComparison> {
  int _selectedMonth1 = DateTime.now().month;
  int _selectedYear1 = DateTime.now().year - 1;
  int _selectedMonth2 = DateTime.now().month;
  int _selectedYear2 = DateTime.now().year;
  List<HistoricalWeatherData> _monthData1 = [];
  List<HistoricalWeatherData> _monthData2 = [];
  bool _isLoadingMonthComparison = false;

  Future<void> _loadMonthComparison() async {
    setState(() {
      _isLoadingMonthComparison = true;
    });

    final data1 = await widget.historyService.getHistoricalDataForMonth(
      widget.defaultLocation,
      _selectedYear1,
      _selectedMonth1,
    );

    final data2 = await widget.historyService.getHistoricalDataForMonth(
      widget.defaultLocation,
      _selectedYear2,
      _selectedMonth2,
    );

    setState(() {
      _monthData1 = data1;
      _monthData2 = data2;
      _isLoadingMonthComparison = false;
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
              pw.Text('Month to Month Weather Comparison', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Month 1: ${DateFormat('MMM yyyy').format(DateTime(_selectedYear1, _selectedMonth1))}'),
              pw.Text('Month 2: ${DateFormat('MMM yyyy').format(DateTime(_selectedYear2, _selectedMonth2))}'),
              pw.SizedBox(height: 20),
              pw.Text('Temperature Comparison', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Avg Temp: ${_calculateAverage(_monthData1.map((d) => d.temp).toList()).toStringAsFixed(1)}°C vs ${_calculateAverage(_monthData2.map((d) => d.temp).toList()).toStringAsFixed(1)}°C'),
              pw.Text('Avg Max Temp: ${_calculateAverage(_monthData1.map((d) => d.tempMax).toList()).toStringAsFixed(1)}°C vs ${_calculateAverage(_monthData2.map((d) => d.tempMax).toList()).toStringAsFixed(1)}°C'),
              pw.Text('Avg Min Temp: ${_calculateAverage(_monthData1.map((d) => d.tempMin).toList()).toStringAsFixed(1)}°C vs ${_calculateAverage(_monthData2.map((d) => d.tempMin).toList()).toStringAsFixed(1)}°C'),
              pw.SizedBox(height: 20),
              pw.Text('Other Metrics', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text('Total Precipitation: ${_monthData1.map((d) => d.precip).reduce((a, b) => a + b).toStringAsFixed(1)} mm vs ${_monthData2.map((d) => d.precip).reduce((a, b) => a + b).toStringAsFixed(1)} mm'),
              pw.Text('Total Sunshine Hours: ${_monthData1.map((d) => d.sunshineHours).reduce((a, b) => a + b).toStringAsFixed(1)} hours vs ${_monthData2.map((d) => d.sunshineHours).reduce((a, b) => a + b).toStringAsFixed(1)} hours'),
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
                    "Select Months to Compare",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMonthYearSelector(
                          "First Month",
                          _selectedMonth1,
                          _selectedYear1,
                          (month, year) {
                            setState(() {
                              _selectedMonth1 = month;
                              _selectedYear1 = year;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMonthYearSelector(
                          "Second Month",
                          _selectedMonth2,
                          _selectedYear2,
                          (month, year) {
                            setState(() {
                              _selectedMonth2 = month;
                              _selectedYear2 = year;
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
                      onPressed: _loadMonthComparison,
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
          _isLoadingMonthComparison
              ? Center(
                  child: SpinKitFadingCircle(
                    color: Colors.purple,
                    size: 50.0,
                  ),
                )
              : _monthData1.isEmpty || _monthData2.isEmpty
                  ? const Center(
                      child: Text("Select months to compare weather data."),
                    )
                  : Column(
                      children: [
                        _buildMonthComparisonResults(),
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

  Widget _buildMonthYearSelector(
    String label,
    int selectedMonth,
    int selectedYear,
    Function(int, int) onChanged,
  ) {
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

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
            value: selectedMonth,
            decoration: const InputDecoration(
              labelText: "Month",
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: List.generate(12, (index) {
              return DropdownMenuItem(
                value: index + 1,
                child: Text(monthNames[index]),
              );
            }),
            onChanged: (value) {
              if (value != null) {
                onChanged(value, selectedYear);
              }
            },
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
                onChanged(selectedMonth, value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMonthComparisonResults() {
    final avgTemp1 = _calculateAverage(_monthData1.map((d) => d.temp).toList());
    final avgTemp2 = _calculateAverage(_monthData2.map((d) => d.temp).toList());

    final avgMaxTemp1 = _calculateAverage(_monthData1.map((d) => d.tempMax).toList());
    final avgMaxTemp2 = _calculateAverage(_monthData2.map((d) => d.tempMax).toList());

    final avgMinTemp1 = _calculateAverage(_monthData1.map((d) => d.tempMin).toList());
    final avgMinTemp2 = _calculateAverage(_monthData2.map((d) => d.tempMin).toList());

    final totalPrecip1 = _monthData1.map((d) => d.precip).reduce((a, b) => a + b);
    final totalPrecip2 = _monthData2.map((d) => d.precip).reduce((a, b) => a + b);

    final totalSunshineHours1 = _monthData1.map((d) => d.sunshineHours).reduce((a, b) => a + b);
    final totalSunshineHours2 = _monthData2.map((d) => d.sunshineHours).reduce((a, b) => a + b);

    final monthName1 = DateFormat('MMMM yyyy').format(DateTime(_selectedYear1, _selectedMonth1));
    final monthName2 = DateFormat('MMMM yyyy').format(DateTime(_selectedYear2, _selectedMonth2));

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
                  "Monthly Temperature Comparison",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: _buildMonthlyTemperatureChart(),
                ),
                const SizedBox(height: 16),
                Text(
                  "Monthly Averages Comparison",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                Table(
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
                    _buildTableHeaderRow(monthName1, monthName2),
                    _buildTableDataRow(
                      "Avg Temperature",
                      "${avgTemp1.toStringAsFixed(1)}°C",
                      "${avgTemp2.toStringAsFixed(1)}°C",
                      _buildDifferenceText(avgTemp2 - avgTemp1, '°C'),
                    ),
                    _buildTableDataRow(
                      "Avg Max Temperature",
                      "${avgMaxTemp1.toStringAsFixed(1)}°C",
                      "${avgMaxTemp2.toStringAsFixed(1)}°C",
                      _buildDifferenceText(avgMaxTemp2 - avgMaxTemp1, '°C'),
                    ),
                    _buildTableDataRow(
                      "Avg Min Temperature",
                      "${avgMinTemp1.toStringAsFixed(1)}°C",
                      "${avgMinTemp2.toStringAsFixed(1)}°C",
                      _buildDifferenceText(avgMinTemp2 - avgMinTemp1, '°C'),
                    ),
                    _buildTableDataRow(
                      "Total Precipitation",
                      "${totalPrecip1.toStringAsFixed(1)} mm",
                      "${totalPrecip2.toStringAsFixed(1)} mm",
                      _buildDifferenceText(totalPrecip2 - totalPrecip1, ' mm'),
                    ),
                    _buildTableDataRow(
                      "Total Sunshine Hours",
                      "${totalSunshineHours1.toStringAsFixed(1)} hours",
                      "${totalSunshineHours2.toStringAsFixed(1)} hours",
                      _buildDifferenceText(totalSunshineHours2 - totalSunshineHours1, ' hours'),
                    ),
                    _buildTableDataRow(
                      "Days with Data",
                      "${_monthData1.length} days",
                      "${_monthData2.length} days",
                      "",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyTemperatureChart() {
    final List<FlSpot> spots1 = [];
    final List<FlSpot> spots2 = [];

    final sortedData1 = [..._monthData1]..sort((a, b) => a.datetime.day.compareTo(b.datetime.day));
    final sortedData2 = [..._monthData2]..sort((a, b) => a.datetime.day.compareTo(b.datetime.day));

    for (int i = 0; i < sortedData1.length; i++) {
      spots1.add(FlSpot(sortedData1[i].datetime.day.toDouble(), sortedData1[i].temp));
    }

    for (int i = 0; i < sortedData2.length; i++) {
      spots2.add(FlSpot(sortedData2[i].datetime.day.toDouble(), sortedData2[i].temp));
    }

    final month1 = DateFormat('MMM yyyy').format(DateTime(_selectedYear1, _selectedMonth1));
    final month2 = DateFormat('MMM yyyy').format(DateTime(_selectedYear2, _selectedMonth2));

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots1,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
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
            dotData: FlDotData(show: false),
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
                if (value % 5 == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      value.toInt().toString(),
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
          horizontalInterval: 5,
          verticalInterval: 5,
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
                final String monthLabel = spot.barIndex == 0 ? month1 : month2;
                return LineTooltipItem(
                  '$monthLabel: ${spot.y.toStringAsFixed(1)}°C',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  double _calculateAverage(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  String _buildDifferenceText(double difference, String unit) {
    if (difference == 0) {
      return "No change";
    }

    final sign = difference > 0 ? "+" : "";
    final color = difference > 0 ? Colors.red : Colors.blue;

    return "$sign${difference.toStringAsFixed(1)}$unit";
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
}