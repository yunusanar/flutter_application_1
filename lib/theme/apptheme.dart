import 'package:flutter/material.dart';

/// ---------------------------------------------------------------
/// SERVİS TAKİP — RENK & STİL SİSTEMİ
/// ---------------------------------------------------------------
/// Kimlik: "Elektrik / Voltaj" — teknik servis uygulaması için
/// koyu lacivert zemin + canlı elektrik-mavisi vurgu.
/// Durum renkleri (uyarı/başarı/hata) uygulamanızda zaten var olan
/// mantığa göre resmileştirildi: turuncu = arıza bekliyor,
/// yeşil = tamamlandı, kırmızı = kritik sorun.
/// ---------------------------------------------------------------
class AppColors {
  AppColors._();

  // Marka
  static const Color navyDeep = Color(0xFF0B132B); // Ana lacivert
  static const Color navyMid = Color(0xFF16264D); // Gradyan ara tonu
  static const Color electricBlue = Color(0xFF00B4D8); // Vurgu / voltaj
  static const Color electricBlueLight = Color(0xFF48CAE4);

  // Durum renkleri
  static const Color warning = Color(0xFFFF8C42); // Sorun bekliyor
  static const Color warningBg = Color(0xFFFFF1E6);
  static const Color success = Color(0xFF27AE60); // Tamamlandı
  static const Color successBg = Color(0xFFE8F8EF);
  static const Color danger = Color(0xFFE63946); // Kritik / DENEME etiketi
  static const Color dangerBg = Color(0xFFFDEAEC);

  // Nötr
  static const Color background = Color(0xFFF4F7F9);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1B1F27);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E9EF);

  /// AppBar'da kullanılan imza gradyanı — koyu lacivertten
  /// elektrik mavisine köşegen geçiş.
  static const LinearGradient appBarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navyDeep, navyMid, Color(0xFF0E4C6E)],
    stops: [0.0, 0.55, 1.0],
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      fontFamily:
          'Inter', // pubspec'e eklerseniz devreye girer, yoksa sistem fontu kullanılır

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.navyDeep,
        primary: AppColors.navyDeep,
        secondary: AppColors.electricBlue,
        error: AppColors.danger,
        surface: AppColors.surface,
        surfaceTint: Colors.transparent,
      ),

      scaffoldBackgroundColor: AppColors.background,

      // --- KART TASARIMI ---
      cardTheme: CardThemeData(
        elevation: 3,
        shadowColor: AppColors.navyDeep.withOpacity(0.10),
        color: AppColors.surface,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.divider, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // --- APPBAR (düz renk fallback; gradyan için GradientAppBar kullanın) ---
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navyDeep,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // --- BUTONLAR ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.electricBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.electricBlue.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0.3,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navyDeep,
          side: BorderSide(color: AppColors.divider, width: 1.4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      // --- INPUT / TEXTFIELD ---
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.electricBlue, width: 2),
        ),
        labelStyle: TextStyle(color: AppColors.textSecondary),
      ),

      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(color: AppColors.textSecondary),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
    );
  }
}

/// ---------------------------------------------------------------
/// Durum rozeti — kart üzerinde "sonunda / calismiyor / DENEME" gibi
/// Sorun etiketlerini tutarlı biçimde göstermek için.
/// ---------------------------------------------------------------
enum JobStatus { pending, success, critical }

class StatusStyle {
  final Color bg;
  final Color fg;
  final IconData icon;
  const StatusStyle(this.bg, this.fg, this.icon);
}

StatusStyle statusStyleFor(JobStatus status) {
  switch (status) {
    case JobStatus.pending:
      return const StatusStyle(
        AppColors.warningBg,
        AppColors.warning,
        Icons.warning_amber_rounded,
      );
    case JobStatus.success:
      return const StatusStyle(
        AppColors.successBg,
        AppColors.success,
        Icons.check_circle_rounded,
      );
    case JobStatus.critical:
      return const StatusStyle(
        AppColors.dangerBg,
        AppColors.danger,
        Icons.error_rounded,
      );
  }
}
