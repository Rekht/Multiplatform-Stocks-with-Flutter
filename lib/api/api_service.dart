import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sahamuas/api/api_url.dart';
import 'package:sahamuas/model/data_perusahaan.dart' as dp;
import 'package:sahamuas/model/harga_saham.dart' as hs;
import 'package:sahamuas/model/history.dart';
import 'package:sahamuas/model/berita.dart';
import 'package:sahamuas/model/harga_tertinggi.dart';
import 'package:sahamuas/api/api_key.dart';

class ApiService {
  int currentApiKeyIndex = 0;

  String get currentApiKey => apiKeys[currentApiKeyIndex];

  void rotateApiKey() {
    currentApiKeyIndex = (currentApiKeyIndex + 1) % apiKeys.length;
  }

  Future<T> _executeWithRetry<T>(Future<T> Function() apiCall) async {
    for (int i = 0; i < apiKeys.length; i++) {
      try {
        return await apiCall();
      } catch (e) {
        print('API Error: $e');
        if (i < apiKeys.length - 1) {
          rotateApiKey();
          print('Switching to next API key: $currentApiKey');
        } else {
          rethrow;
        }
      }
    }
    throw Exception('All API keys exhausted');
  }

//

  Future<List<dp.Company>> fetchCompanies() async {
    return _executeWithRetry(() async {
      final response = await http
          .get(Uri.parse(apiURL('data_perusahaan', apiKey: currentApiKey)));

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var companyList = (jsonResponse['data']['results'] as List)
            .map((item) => dp.Company.fromJson(item))
            .toList();
        return companyList;
      } else {
        throw Exception('Failed to load companies');
      }
    });
  }

  Future<hs.StockPriceData> fetchStockPrice(String symbol) async {
    return _executeWithRetry(() async {
      final response = await http.get(Uri.parse(
          apiURL('harga_saham', emiten: symbol, apiKey: currentApiKey)));

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return hs.StockPriceData.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load stock price');
      }
    });
  }

  Future<List<TopGainer>> fetchTopGainers() async {
    return _executeWithRetry(() async {
      final response = await http
          .get(Uri.parse(apiURL('kenaikan_tertinggi', apiKey: currentApiKey)));

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var topGainerList = (jsonResponse['data']['results'] as List)
            .map((item) => TopGainer.fromJson(item))
            .toList();
        return topGainerList.take(5).toList();
      } else {
        throw Exception('Failed to load top gainers');
      }
    });
  }

  Future<NewsData> fetchNews({String halaman = '1'}) async {
    return _executeWithRetry(() async {
      final response = await http.get(
          Uri.parse(apiURL('berita', halaman: halaman, apiKey: currentApiKey)));

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return NewsData.fromJson(jsonResponse);
      } else {
        throw Exception('Gagal memuat berita');
      }
    });
  }

  Future<StockHistoryData> fetchStockHistory(
      String symbol, String startDate, String endDate) async {
    return _executeWithRetry(() async {
      final response = await http.get(Uri.parse(apiURL('histori',
          emiten: symbol,
          tanggal_awal: startDate,
          tanggal_akhir: endDate,
          apiKey: currentApiKey)));

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return StockHistoryData.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load stock history');
      }
    });
  }
}
