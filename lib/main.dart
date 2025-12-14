import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'utils/ssl_service.dart';
import 'dart:io';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Servis Takip',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Color(0xFF1565C0),
        scaffoldBackgroundColor: Color(0xFFF5F7FA),

        // --- 1. DÜZELTME: Sadeleştirilmiş Renk Şeması ---
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF1565C0)),

        // --- 2. DÜZELTME: Eski Sürümlere Uyumlu Kart Tasarımı ---
        cardTheme: CardThemeData(
          elevation: 4,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          // 'margin' ve 'shadowColor' kaldırıldı (Hata sebebi bunlardı)
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1565C0),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF1565C0), width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      home: LoginScreen(),
    );
  }
}
