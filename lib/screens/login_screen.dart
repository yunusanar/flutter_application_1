import 'package:flutter/material.dart';
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // --- ESKİ PARLAK MAVİLER YERİNE YENİ GECE MAVİSİ TONLARI ---
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors
                        .white12, // Arka plana uyumlu şık bir transparanlık
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.build_circle_outlined,
                    size: 80,
                    color: Color(
                      0xFF14B8A6,
                    ), // --- YENİ TURKUAZ VURGU RENGİ ---
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: const Text(
                    "ÇÖZÜM ANKASTRE KUMTEL YETKİLİ SERVİSİ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Card(
                  elevation: 8,
                  // Shape (köşe yuvarlaklığı vb.) ayarları silindi, artık main.dart'tan geliyor
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: "E-Posta",
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Şifre",
                            prefixIcon: Icon(Icons.lock),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
