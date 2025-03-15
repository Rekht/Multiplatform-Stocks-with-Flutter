import 'package:flutter/material.dart';
import 'package:sahamuas/api/api_service.dart';
import 'package:sahamuas/model/data_perusahaan.dart' as dp;
import 'package:sahamuas/model/harga_saham.dart' as hs;
import 'package:sahamuas/screens/detail_saham.dart';
import 'package:sahamuas/utils/app_colors.dart';

class AllStocksScreen extends StatefulWidget {
  const AllStocksScreen({Key? key}) : super(key: key);

  @override
  _AllStocksScreenState createState() => _AllStocksScreenState();
}

class _AllStocksScreenState extends State<AllStocksScreen> {
  late ApiService _apiService;
  late Future<List<dp.Company>> _companyFuture;
  List<dp.Company> _allCompanies = [];
  List<dp.Company> _displayedCompanies = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _companyFuture = _apiService.fetchCompanies();
    _companyFuture.then((companies) {
      setState(() {
        _allCompanies = companies;
        _displayedCompanies = companies;
      });
    });
  }

  void _filterCompanies(String query) {
    setState(() {
      if (query.isEmpty) {
        _displayedCompanies = _allCompanies;
      } else {
        _displayedCompanies = _allCompanies
            .where((company) =>
                company.name.toLowerCase().contains(query.toLowerCase()) ||
                company.symbol.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Semua Saham', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildStockList(),
          ),
        ],
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

  Widget _buildStockList() {
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
          return ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: _displayedCompanies.length,
            separatorBuilder: (context, index) =>
                Divider(color: Colors.grey[300], height: 1),
            itemBuilder: (context, index) {
              final company = _displayedCompanies[index];
              return FutureBuilder<hs.StockPriceData>(
                future: _apiService.fetchStockPrice(company.symbol),
                builder: (context, priceSnapshot) {
                  return _buildStockCard(
                      company, priceSnapshot.data?.results[0]);
                },
              );
            },
          );
        } else {
          return Center(
              child: Text('Tidak ada data ditemukan',
                  style: TextStyle(color: AppColors.subText)));
        }
      },
    );
  }

  Widget _buildStockCard(dp.Company company, hs.StockPrice? price) {
    return Container(
      height: 60,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(company.logo),
          backgroundColor: Colors.transparent,
          radius: 16,
        ),
        title: Text(
          company.symbol,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.text),
        ),
        subtitle: Text(
          company.name,
          style: TextStyle(color: AppColors.subText, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: price != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rp ${price.close.toStringAsFixed(0)}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.text),
                  ),
                  Text(
                    '${price.changePct >= 0 ? '+' : ''}${price.changePct.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: price.changePct >= 0
                          ? AppColors.positive
                          : AppColors.negative,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            : SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeWidth: 2,
                ),
              ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    StockDetailScreen(symbol: company.symbol)),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
