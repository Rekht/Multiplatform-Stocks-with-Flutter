import 'package:flutter/material.dart';
import 'package:sahamuas/api/api_service.dart';
import 'package:sahamuas/model/harga_saham.dart' as hs;
import 'package:sahamuas/model/history.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:sahamuas/utils/app_colors.dart';

class StockDetailScreen extends StatefulWidget {
  final String symbol;
  const StockDetailScreen({Key? key, required this.symbol}) : super(key: key);

  @override
  _StockDetailScreenState createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  late ApiService _apiService;
  late Future<hs.StockPriceData> _stockPriceFuture;
  late Future<StockHistoryData> _stockHistoryFuture;
  String _selectedPeriod = '1M';
  List<String> _periods = ['1W', '1M', '3M', '6M', '1Y', '3Y', '5Y'];

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _stockPriceFuture = _apiService.fetchStockPrice(widget.symbol);
    _updateHistoryData();
  }

  void _updateHistoryData() {
    DateTime endDate = DateTime.now();
    DateTime startDate;
    switch (_selectedPeriod) {
      case '1W':
        startDate = endDate.subtract(Duration(days: 7));
        break;
      case '1M':
        startDate = endDate.subtract(Duration(days: 30));
        break;
      case '3M':
        startDate = endDate.subtract(Duration(days: 90));
        break;
      case '6M':
        startDate = endDate.subtract(Duration(days: 180));
        break;
      case '1Y':
        startDate = endDate.subtract(Duration(days: 365));
        break;
      case '3Y':
        startDate = endDate.subtract(Duration(days: 365 * 3));
        break;
      case '5Y':
        startDate = endDate.subtract(Duration(days: 365 * 5));
        break;
      default:
        startDate = endDate.subtract(Duration(days: 30));
    }
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
    _stockHistoryFuture = _apiService.fetchStockHistory(
        widget.symbol, formattedStartDate, formattedEndDate);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Saham ${widget.symbol}',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStockPrice(),
            _buildStockHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildStockPrice() {
    return FutureBuilder<hs.StockPriceData>(
      future: _stockPriceFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        } else if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        } else if (snapshot.hasData) {
          final stock = snapshot.data!.results[0];
          return Card(
            margin: EdgeInsets.all(16),
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.company.name,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Rp ${NumberFormat('#,##0').format(stock.close)}',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        stock.change >= 0
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: stock.change >= 0
                            ? AppColors.positive
                            : AppColors.negative,
                      ),
                      Text(
                        '${stock.change} (${stock.changePct.toStringAsFixed(2)}%)',
                        style: TextStyle(
                          color: stock.change >= 0
                              ? AppColors.positive
                              : AppColors.negative,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildPriceInfoRow('Pembukaan', stock.open.toDouble()),
                  _buildPriceInfoRow('Tertinggi', stock.high.toDouble()),
                  _buildPriceInfoRow('Terendah', stock.low.toDouble()),
                  _buildPriceInfoRow('Volume', stock.volume.toDouble(),
                      isVolume: true),
                ],
              ),
            ),
          );
        } else {
          return _buildErrorWidget('No data found');
        }
      },
    );
  }

  Widget _buildPriceInfoRow(String label, double value,
      {bool isVolume = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.subText)),
          Text(
            isVolume
                ? NumberFormat('#,##0').format(value)
                : 'Rp ${NumberFormat('#,##0.00').format(value)}',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: AppColors.text),
          ),
        ],
      ),
    );
  }

  Widget _buildStockHistory() {
    return FutureBuilder<StockHistoryData>(
      future: _stockHistoryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        } else if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        } else if (snapshot.hasData && snapshot.data!.results.isNotEmpty) {
          return Card(
            margin: EdgeInsets.all(16),
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Histori Harga',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text),
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 300,
                    child: LineChart(
                      _buildLineChartData(snapshot.data!.results),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildPeriodButtons(),
                ],
              ),
            ),
          );
        } else {
          return _buildErrorWidget('No data found or empty data');
        }
      },
    );
  }

  LineChartData _buildLineChartData(List<StockHistory> historyData) {
    if (historyData.isEmpty) {
      return LineChartData(); // Return empty chart data if no historical data
    }

    List<FlSpot> spots = [];
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (int i = 0; i < historyData.length; i++) {
      spots.add(FlSpot(i.toDouble(), historyData[i].close));
      if (historyData[i].close < minY) minY = historyData[i].close;
      if (historyData[i].close > maxY) maxY = historyData[i].close;
    }

    Color lineColor =
        spots.first.y < spots.last.y ? AppColors.positive : AppColors.negative;

    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTitlesWidget: (value, meta) {
              if (historyData.length < 5) {
                if (value.toInt() == 0 ||
                    value.toInt() == historyData.length - 1) {
                  return Text(
                    DateFormat('MMM dd').format(
                        DateTime.parse(historyData[value.toInt()].date)),
                    style: TextStyle(color: AppColors.subText, fontSize: 10),
                  );
                }
              } else if (value.toInt() % (historyData.length ~/ 5) == 0) {
                return Text(
                  DateFormat('MMM dd')
                      .format(DateTime.parse(historyData[value.toInt()].date)),
                  style: TextStyle(color: AppColors.subText, fontSize: 10),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(
                NumberFormat('#,##0').format(value),
                style: TextStyle(color: AppColors.subText, fontSize: 10),
              );
            },
            reservedSize: 40,
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: historyData.length.toDouble() - 1,
      minY: minY * 0.95,
      maxY: maxY * 1.05,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: lineColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: lineColor.withOpacity(0.2),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final flSpot = barSpot;
              return LineTooltipItem(
                '${DateFormat('MMM dd, yyyy').format(DateTime.parse(historyData[flSpot.x.toInt()].date))}\n${NumberFormat('#,##0.00').format(flSpot.y)}',
                const TextStyle(color: Colors.white),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildPeriodButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _periods.map((period) => _buildPeriodButton(period)).toList(),
      ),
    );
  }

  Widget _buildPeriodButton(String period) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        child: Text(period),
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedPeriod == period
              ? AppColors.primary
              : AppColors.background,
          foregroundColor:
              _selectedPeriod == period ? Colors.white : AppColors.text,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: () {
          setState(() {
            _selectedPeriod = period;
            _updateHistoryData();
          });
        },
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Text(
        'Error: $error',
        style: TextStyle(color: AppColors.negative),
      ),
    );
  }
}
