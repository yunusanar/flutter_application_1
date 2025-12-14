import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';
import '../models/login_request.dart';

class AuthService {
  // bool yerine 'dynamic' döndürüyoruz (Başarılıysa User nesnesi, değilse null)
  Future<dynamic> login(String email, String password) async {
    var url = Uri.parse('${ApiConstants.baseUrl}/Users/login');
    var requestBody = LoginRequest(email: email, sifre: password).toJson();

    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Başarılı! Sunucudan gelen tüm kullanıcı bilgisini (ID dahil) döndür
        return jsonDecode(response.body);
      } else {
        return null; // Başarısız
      }
    } catch (e) {
      print("Hata: $e");
      return null;
    }
  }
}
