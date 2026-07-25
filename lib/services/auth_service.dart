/* import 'dart:convert';
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
 */

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';
import '../models/login_request.dart';
import '../models/app_models.dart'; // Brand ve ProductItem burada tanımlı olmalı

class AuthService {
  // Login fonksiyonun (Mevcut haliyle kalsın, sadece URL'yi düzelttik)
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
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print("Hata: $e");
      return null;
    }
  }

  // --- YENİ EKLENEN METOTLAR ---

  // Tüm Markaları Getir
  Future<List<Brand>> fetchBrands() async {
    // Backend'de yazdığımız route: /api/Products/brands
    final url = Uri.parse('${ApiConstants.baseUrl}/Products/brands');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Brand.fromJson(data)).toList();
      } else {
        throw Exception('Markalar yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Marka servisi hatası: $e');
    }
  }

  // Tüm Ürün Modellerini Getir
  Future<List<ProductItem>> fetchProducts() async {
    // Backend'de yazdığımız route: /api/Products/all
    final url = Uri.parse('${ApiConstants.baseUrl}/Products/all');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => ProductItem.fromJson(data)).toList();
      } else {
        throw Exception('Ürünler yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ürün servisi hatası: $e');
    }
  }

  // Yeni Cihaz Kaydet ve Kurulum Talebi Oluştur
  Future<bool> saveCustomerProduct(
    int userId,
    int productId,
    String serialNumber,
  ) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/CustomerProducts',
    ); // Backend'deki Post metodu

    final body = jsonEncode({
      "userId": userId,
      "productId": productId,
      "seriNumarasi": serialNumber,
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Cihaz kaydetme hatası: $e");
      return false;
    }
  }
}
