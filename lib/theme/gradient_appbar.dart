import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/apptheme.dart';

/// Dikkat çekici, gradyanlı AppBar.
/// Standart AppBar yerine bunu kullanın — arka planı ThemeData'nın
/// sağlayamadığı köşegen gradyanı ve ince "voltaj çizgisi" ile gelir.
///
/// Kullanım:
///   Scaffold(
///     appBar: const GradientAppBar(title: 'Servis Takip'),
///     ...
///   )
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
      child: AppBar(
        title: Text(title),
        centerTitle: centerTitle,
        leading: leading,
        actions: actions,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: Stack(
          children: [
            // İnce, köşegen "voltaj çizgisi" — imza detay
            Positioned(
              right: -20,
              top: -10,
              child: Transform.rotate(
                angle: -0.5,
                child: Container(
                  width: 3,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.electricBlueLight.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.electricBlue.withOpacity(0.6),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 34,
              top: -6,
              child: Transform.rotate(
                angle: -0.5,
                child: Container(
                  width: 2,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.electricBlueLight.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
