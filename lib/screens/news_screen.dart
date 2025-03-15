import 'package:flutter/material.dart';
import 'package:sahamuas/api/api_service.dart';
import 'package:sahamuas/model/berita.dart';
import 'package:sahamuas/utils/app_colors.dart';
import 'package:sahamuas/screens/news_detail_screen.dart';

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late ApiService _apiService;
  List<News> _daftarBerita = [];
  int _halamanSaatIni = 1;
  bool _sedangMemuat = false;
  bool _masihAdaLagi = true;
  ScrollController _pengontrolGulir = ScrollController();

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _muatBeritaLebihBanyak();
    _pengontrolGulir.addListener(() {
      if (_pengontrolGulir.position.pixels ==
          _pengontrolGulir.position.maxScrollExtent) {
        _muatBeritaLebihBanyak();
      }
    });
  }

  Future<void> _muatBeritaLebihBanyak() async {
    if (_sedangMemuat || !_masihAdaLagi) return;

    setState(() {
      _sedangMemuat = true;
    });

    try {
      final dataBerita =
          await _apiService.fetchNews(halaman: _halamanSaatIni.toString());
      setState(() {
        _daftarBerita.addAll(dataBerita.results);
        _halamanSaatIni++;
        _sedangMemuat = false;
        _masihAdaLagi = dataBerita.results.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _sedangMemuat = false;
      });
      print('Error saat memuat berita: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Berita', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
      ),
      body: ListView.builder(
        controller: _pengontrolGulir,
        itemCount: _daftarBerita.length + (_masihAdaLagi ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _daftarBerita.length) {
            final berita = _daftarBerita[index];
            return Card(
              margin: EdgeInsets.all(8),
              child: ListTile(
                leading: Image.network(berita.image,
                    width: 100, height: 100, fit: BoxFit.cover),
                title: Text(berita.title),
                subtitle: Text(berita.description),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetailScreen(berita: berita),
                    ),
                  );
                },
              ),
            );
          } else if (_masihAdaLagi) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Container();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _pengontrolGulir.dispose();
    super.dispose();
  }
}
