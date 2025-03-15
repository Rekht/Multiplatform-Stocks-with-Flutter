import 'package:flutter/material.dart';
import 'package:sahamuas/utils/app_colors.dart';
import 'package:sahamuas/screens/pengaturan.dart';
import 'package:sahamuas/screens/bantuan.dart';
import 'package:sahamuas/screens/profile_page.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Informasi Akun'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Pengaturan'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PengaturanScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Bantuan'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BantuanScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
