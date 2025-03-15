import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class PengaturanScreen extends StatefulWidget {
  @override
  _PengaturanScreenState createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  bool _notifikasiAktif = false;

  void checkNotificationPermission() async {
    final status = await Permission.notification.status;
    print('Notification permission status: $status');
  }

  @override
  void initState() {
    super.initState();
    _muatPengaturan();
    checkNotificationPermission(); // Tambahkan baris ini
  }

  Future<void> _muatPengaturan() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifikasiAktif = prefs.getBool('notifikasi_aktif') ?? false;
    });
  }

  Future<void> _simpanPengaturan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifikasi_aktif', _notifikasiAktif);
  }

  Future<void> _toggleNotifikasi(bool value) async {
    if (value) {
      PermissionStatus status = await Permission.notification.request();
      if (status.isGranted) {
        setState(() {
          _notifikasiAktif = true;
        });
        await _simpanPengaturan();
      } else {
        // Jika izin ditolak, tampilkan dialog
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('Izin Notifikasi Diperlukan'),
            content: Text(
                'Untuk menerima notifikasi, Anda perlu mengizinkan notifikasi di pengaturan perangkat.'),
            actions: <Widget>[
              TextButton(
                child: Text('Batal'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text('Buka Pengaturan'),
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
              ),
            ],
          ),
        );
      }
    } else {
      setState(() {
        _notifikasiAktif = false;
      });
      await _simpanPengaturan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Notifikasi'),
            subtitle:
                Text('Terima pemberitahuan tentang perubahan harga saham'),
            value: _notifikasiAktif,
            onChanged: (bool value) async {
              await _toggleNotifikasi(value);
              setState(() {}); // Memastikan UI diperbarui
            },
          ),
        ],
      ),
    );
  }
}
