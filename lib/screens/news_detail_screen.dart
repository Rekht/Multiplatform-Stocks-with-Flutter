import 'package:flutter/material.dart';
import 'package:sahamuas/model/berita.dart';
import 'package:sahamuas/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class NewsDetailScreen extends StatelessWidget {
  final News berita;

  NewsDetailScreen({required this.berita});

  Future<void> _launchURL(BuildContext context, String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await url_launcher.canLaunchUrl(uri)) {
        await url_launcher.launchUrl(uri,
            mode: url_launcher.LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka URL: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Berita', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(berita.image,
                width: double.infinity, height: 200, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    berita.title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Dipublikasikan pada: ${berita.publishedAt}',
                    style: TextStyle(color: AppColors.subText),
                  ),
                  SizedBox(height: 16),
                  Text(berita.description),
                  SizedBox(height: 16),
                  ElevatedButton(
                    child: Text('Baca Selengkapnya'),
                    onPressed: () => _launchURL(context, berita.url),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
