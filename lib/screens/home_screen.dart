import 'package:flutter/material.dart';
import 'package:sahamuas/api/api_service.dart';
import 'package:sahamuas/model/data_perusahaan.dart' as dp;
import 'package:sahamuas/model/harga_saham.dart' as hs;
import 'package:sahamuas/model/harga_tertinggi.dart';
import 'package:sahamuas/model/history.dart';
import 'package:sahamuas/screens/all_stocks_screen.dart';
import 'package:sahamuas/utils/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:sahamuas/screens/detail_saham.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ApiService _apiService;
  late Future<List<dp.Company>> _companyFuture;
  late Future<List<TopGainer>> _topGainersFuture;
  List<dp.Company> _allCompanies = [];
  List<dp.Company> _displayedCompanies = [];
  TextEditingController _searchController = TextEditingController();
  Map<String, StockHistoryData> _stockHistoryCache = {};

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _companyFuture = _apiService.fetchCompanies();
    _topGainersFuture = _apiService.fetchTopGainers();
    _companyFuture.then((companies) {
      if (mounted) {
        setState(() {
          _allCompanies = companies;
          _displayedCompanies = companies.take(5).toList();
        });
      }
    });
  }

  void _filterCompanies(String query) {
    setState(() {
      if (query.isEmpty) {
        _displayedCompanies = _allCompanies.take(5).toList();
      } else {
        _displayedCompanies = _allCompanies
            .where((company) =>
                company.name.toLowerCase().contains(query.toLowerCase()) ||
                company.symbol.toLowerCase().contains(query.toLowerCase()))
            .take(5)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTopGainersChart(),
                    _buildStockContainer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.primary,
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Cari saham...',
          hintStyle: TextStyle(color: Colors.white70, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.white70, size: 20),
          filled: true,
          fillColor: Colors.white24,
          contentPadding: EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: _filterCompanies,
      ),
    );
  }

  Widget _buildTopGainersChart() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Rekomendasi Saham',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 160,
            child: FutureBuilder<List<TopGainer>>(
              future: _topGainersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final gainer = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  StockDetailScreen(symbol: gainer.symbol),
                            ),
                          );
                        },
                        child: Card(
                          margin: EdgeInsets.only(right: 16),
                          child: Container(
                            width: 180,
                            padding: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(gainer.symbol,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(gainer.company.name,
                                    style: TextStyle(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                Expanded(
                                  child: _buildStockChart(gainer.symbol),
                                ),
                                Text(
                                    'Rp ${NumberFormat('#,##0').format(gainer.close)}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text('${gainer.percent.toStringAsFixed(2)}%',
                                    style:
                                        TextStyle(color: AppColors.positive)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: Text('Tidak ada data'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockChart(String symbol) {
    if (_stockHistoryCache.containsKey(symbol)) {
      return _buildChartFromData(_stockHistoryCache[symbol]!);
    }

    return FutureBuilder<StockHistoryData>(
      future: _fetchAndCacheStockHistory(symbol),
      builder: (context, historicalSnapshot) {
        if (historicalSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (historicalSnapshot.hasError) {
          return Center(
              child: Text('Gagal memuat data historis',
                  style: TextStyle(fontSize: 10)));
        } else if (historicalSnapshot.hasData &&
            historicalSnapshot.data!.results.isNotEmpty) {
          return _buildChartFromData(historicalSnapshot.data!);
        } else {
          return Center(
              child: Text('Tidak ada data historis',
                  style: TextStyle(fontSize: 10)));
        }
      },
    );
  }

  Future<StockHistoryData> _fetchAndCacheStockHistory(String symbol) async {
    if (!_stockHistoryCache.containsKey(symbol)) {
      final data = await _apiService.fetchStockHistory(
        symbol,
        DateTime.now().subtract(Duration(days: 30)).toString().split(' ')[0],
        DateTime.now().toString().split(' ')[0],
      );
      _stockHistoryCache[symbol] = data;
    }
    return _stockHistoryCache[symbol]!;
  }

  Widget _buildChartFromData(StockHistoryData data) {
    final historicalData = data.results;
    historicalData.sort((a, b) => a.date.compareTo(b.date));
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: historicalData.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.close);
            }).toList(),
            isCurved: true,
            color: AppColors.positive,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
                show: true, color: AppColors.positive.withOpacity(0.1)),
          ),
        ],
        lineTouchData: LineTouchData(enabled: false),
      ),
    );
  }

  Widget _buildStockContainer() {
    return FutureBuilder<List<dp.Company>>(
      future: _companyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: TextStyle(color: AppColors.negative)));
        } else if (snapshot.hasData) {
          return Column(
            children: [
              Container(
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStockList(),
                    _buildShowAllButton(),
                  ],
                ),
              ),
            ],
          );
        } else {
          return Center(
              child: Text('Tidak ada data ditemukan',
                  style: TextStyle(color: AppColors.subText)));
        }
      },
    );
  }

  Widget _buildStockList() {
    if (_displayedCompanies.isEmpty) {
      return Center(child: Text('Tidak ada saham untuk ditampilkan'));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: _displayedCompanies.length,
      separatorBuilder: (context, index) => Divider(
        color: Colors.grey[300],
        height: 1,
        indent: 72, // Memberikan indent agar garis pemisah tidak mencapai ikon
        endIndent: 16,
      ),
      itemBuilder: (context, index) {
        final company = _displayedCompanies[index];
        return FutureBuilder<hs.StockPriceData>(
          future: _apiService.fetchStockPrice(company.symbol),
          builder: (context, priceSnapshot) {
            return _buildStockCard(company, priceSnapshot.data?.results[0]);
          },
        );
      },
    );
  }

  Widget _buildStockCard(dp.Company company, hs.StockPrice? price) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StockDetailScreen(symbol: company.symbol),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(company.logo),
              backgroundColor: Colors.transparent,
              radius: 20,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.symbol,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    company.name,
                    style: TextStyle(color: AppColors.subText, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            if (price != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rp ${NumberFormat('#,##0').format(price.close)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${price.changePct >= 0 ? '+' : ''}${price.changePct.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: price.changePct >= 0
                          ? AppColors.positive
                          : AppColors.negative,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeWidth: 2,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowAllButton() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AllStocksScreen()),
        );
      },
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Center(
          child: Text(
            'Tampilkan Semua',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
