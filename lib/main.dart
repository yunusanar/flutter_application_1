import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/apptheme.dart';
import 'screens/login_screen.dart';
import 'utils/ssl_service.dart';
import 'dart:io';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Servis Takip',
      theme: AppTheme.theme,
      home: const LoginScreen(),
    );
  }
}
