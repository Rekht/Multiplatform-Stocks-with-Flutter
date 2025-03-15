import 'package:flutter/material.dart';
import 'package:sahamuas/utils/app_colors.dart';

class BantuanScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bantuan', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
      ),
      body: ListView(
        children: [
          ExpansionTile(
            title: Text('Cara Menggunakan Aplikasi'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Aplikasi ini memungkinkan Anda untuk melacak harga saham, membaca berita terkait, dan mengelola profil Anda. Gunakan menu navigasi di bagian bawah untuk beralih antara layar Saham, Berita, dan Profil.',
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Fitur Saham'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Di layar Saham, Anda dapat melihat daftar saham, mencari saham tertentu, dan melihat detail harga saham. Ketuk pada saham untuk melihat informasi lebih lanjut dan grafik harga historis.',
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Fitur Berita'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Layar Berita menampilkan artikel terbaru terkait pasar saham dan ekonomi. Ketuk pada artikel untuk membaca selengkapnya.',
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Pengaturan Akun'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Di layar Profil, Anda dapat mengakses pengaturan akun, notifikasi.',
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Kontak Dukungan'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Jika Anda memiliki pertanyaan atau masalah lebih lanjut, silakan hubungi tim dukungan kami di support@sahamuas.com atau telepon ke 021-1234567.',
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Tidak Dapat Membantu'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Maaf, Saya menyerah',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
