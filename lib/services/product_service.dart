import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';
import '../models/customer_product.dart';

class ProductService {
  // Müşterinin Ürünlerini Getir (Gerçek)
  Future<List<CustomerProduct>> getMyProducts(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/CustomerProducts/User/$userId"),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => CustomerProduct.fromJson(item)).toList();
      }
    } catch (e) {
      print("Hata: $e");
    }
    return [];
  }

  // Katalog Ürünlerini Getir (Gerçek)
  Future<List<Map<String, dynamic>>> getCatalogProducts() async {
    try {
      // API'de Products tablosunu çeken endpoint olmalı.
      // Yoksa bile şimdilik manuel listeyi API'den gelmiş gibi döndürebiliriz veya
      // ProductsController varsa oradan çekebiliriz.
      // Şimdilik demo için manuel liste:
      return [
        {"id": 1, "ad": "Arçelik 2705 Çamaşır Makinesi"},
        {"id": 2, "ad": "Samsung DW60 Bulaşık Makinesi"},
        {"id": 3, "ad": "Bosch Serie 4 Fırın"},
        {"id": 4, "ad": "Daikin Sensira Klima"},
        {"id": 5, "ad": "LG Oled TV 55 İnç"},
      ];
    } catch (e) {
      return [];
    }
  }

  // --- GERÇEK KAYIT FONKSİYONU ---
  Future<bool> addCustomerProduct(
    int userId,
    int productId,
    String seriNo,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/CustomerProducts"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "productId": productId,
          "seriNumarasi": seriNo,
          // Tarihler backend'de otomatik atanacak
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Kayıt Başarısız: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Bağlantı Hatası: $e");
      return false;
    }
  }
}
