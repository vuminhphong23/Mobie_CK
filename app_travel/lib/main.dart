import 'dart:io';
import 'package:app_travel/pages/clock.dart';
import 'package:app_travel/login/welcome_screen.dart';
import 'package:app_travel/pages/favorites_page.dart';
import 'package:app_travel/pages/list_best_favorite.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login/signin_screen.dart';
import 'models/interfaces.dart';
import 'pages/home_page.dart';
import 'pages/country.dart';
import 'pages/settings_page.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserInterface()),
      ],
      child: MyApp(),
    ),
  );
  Platform.isAndroid ?
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: 'AIzaSyC7_oH3hpSNwsF0d4JkV3jUD1rhvvX8jYE',  // current_key
          appId: '1:825549254388:android:51c423d32250080b18b8a1',  // mobilesdk_app_id
          messagingSenderId: '825549254388',  // project_number
          projectId: 'country-app-cb075'  // project_id
      )
  ) : await Firebase.initializeApp();



}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: Provider.of<UserInterface>(context).themeMode,
      routes: {
        "homePage": (context) => HomePage(),
        "settingsPage": (context) => SettingsPage(),
        'loginPage': (context) => SignInScreen(),
        "favoritesPage"  : (context) => FavoritePage(),

        // "orderDetail": (context) => ChiTietHoaDon(),
      },
      home: WelcomeScreen(),
    );
  }
}
