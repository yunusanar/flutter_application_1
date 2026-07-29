import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/apptheme.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'technician_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen tüm alanları doldurun."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // API'den gelen cevap (JSON Map)
    var user = await _authService.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (user != null) {
      // --- YENİ NORMALİZE YAPIYA UYGUN VERİ ÇEKME ---
      // 1. RoleId üzerinden kontrol yapmak en güvenlisidir (1: Teknisyen, 2: Musteri)
      int roleId = user['roleId'] ?? 0;

      // 2. Eğer isimle kontrol yapılacaksa role nesnesinin içine bakılır
      var roleData = user['role'];
      String roleName = "";
      if (roleData != null && roleData is Map) {
        roleName = roleData['roleName'] ?? "";
      }

      String adSoyad = user['adSoyad'] ?? user['AdSoyad'] ?? "Kullanıcı";
      int id = user['id'] ?? user['Id'] ?? 0;

      // Yönlendirme mantığı: RoleId == 1 (Teknisyen)
      if (roleId == 1 || roleName.toLowerCase() == "teknisyen") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TechnicianScreen(adSoyad: adSoyad),
          ),
        );
      } else {
        // Müşteri ekranı (RoleId == 2)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userId: id, adSoyad: adSoyad),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Giriş Başarısız! E-posta veya şifre hatalı."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar'daki aynı gradyanı tüm ekrana yayıyoruz
      body: Stack(
        children: [
          // 1. KATMAN: Ana Arka Plan
          Container(
            decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
          ),

          // 2. KATMAN: Voltaj Çizgileri (Arka plan dekorasyonu)
          // Sağ üstte büyük, hafif bulanık bir parlamayla derinlik katıyoruz
          Positioned(
            top: -100,
            right: -80,
            child: Transform.rotate(
              angle: -0.5,
              child: Container(
                width: 60,
                height: 500,
                decoration: BoxDecoration(
                  color: AppColors.electricBlueLight.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.electricBlue.withOpacity(0.25),
                      blurRadius: 50,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Sol altta daha ince, destekleyici bir çizgi
          Positioned(
            bottom: -50,
            left: -50,
            child: Transform.rotate(
              angle: -0.5,
              child: Container(
                width: 20,
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.electricBlueLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.electricBlue.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. KATMAN: Giriş Formu (Cam efektiyle)
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- LOGO VE BAŞLIK ---
                    Icon(
                      Icons
                          .engineering_rounded, // Uygulama logonu buraya koyabilirsin
                      size: 80,
                      color: AppColors.electricBlueLight,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "SERVİS TAKİP",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Teknik Servis Yönetim Paneli",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // --- FORM KUTUSU (Glassmorphism Etkisi) ---
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(
                          0.08,
                        ), // Yarı şeffaf beyaz
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(
                            0.15,
                          ), // İnce şeffaf sınır
                        ),
                      ),
                      child: Column(
                        children: [
                          // E-posta Alanı
                          _buildTextField(
                            controller: _emailController,
                            hint: "E-posta",
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 16),
                          // Şifre Alanı
                          _buildTextField(
                            controller: _passwordController,
                            hint: "Şifre",
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 32),
                          // Giriş Butonu
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppColors.electricBlue, // Vurgu rengin
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shadowColor: AppColors.electricBlue.withOpacity(
                                  0.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _isLoading ? null : _login,
                              // Buton stili silindi. Rengini, boyutunu ve şeklini otomatik olarak main.dart'taki temadan alacak.
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors
                                            .white, // Turkuaz buton üstünde beyaz loading ikonu
                                      ),
                                    )
                                  : const Text("GİRİŞ YAP"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Text alanlarını temiz tutmak için yardımcı bir metot
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: AppColors.electricBlueLight),
        filled: true,
        fillColor: Colors.black.withOpacity(0.2), // Kutuların içi daha koyu
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none, // Kenarlık yok, sadece arkaplan
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.electricBlueLight.withOpacity(0.5),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
