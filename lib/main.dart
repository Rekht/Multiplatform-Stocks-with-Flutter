import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sahamuas/screens/splash_screen.dart';
import 'package:sahamuas/main_screen.dart';
import 'package:sahamuas/firebase/login_page.dart';
import 'package:sahamuas/firebase/sign_up_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyDnHNcMZs93P-g-GCDep_yB-XhrGdpnSrA",
        appId: "1:462045708744:android:e4b57993417d1b469300fd",
        messagingSenderId: "462045708744",
        projectId: "mobile-programming-e0916",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WolfTrack',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => SplashScreen(
              child: LoginPage(),
            ),
        '/login': (context) => LoginPage(),
        '/signUp': (context) => SignUpPage(),
        '/home': (context) => MainScreen(),
      },
    );
  }
}
