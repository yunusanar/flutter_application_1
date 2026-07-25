import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';
import '../models/customer_product.dart';
import '../models/app_models.dart';

class ProductService {
  // 1. KATALOG ÜRÜNLERİNİ GETİR (Senin istediğin fonksiyon)
  Future<List<CustomerProduct>> getCatalogProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/Products'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CustomerProduct.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Hata: $e");
      return [];
    }
  }

  // 2. MÜŞTERİNİN CİHAZLARINI GETİR
  Future<List<CustomerProduct>> getMyProducts(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/CustomerProducts/user/$userId'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CustomerProduct.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Cihazları getirme hatası: $e");
      return [];
    }
  }

  // 3. YENİ CİHAZ KAYDET
  Future<bool> addCustomerProduct(
    int userId,
    int productId,
    String seriNo,
    DateTime kurulumTarihi,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/CustomerProducts'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "productId": productId,
          "seriNumarasi": seriNo,
          "kurulumTarihi": kurulumTarihi.toIso8601String(),
          "garantiBitisTarihi": kurulumTarihi
              .add(Duration(days: 730))
              .toIso8601String(),
        }),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Ekleme hatası: $e");
      return false;
    }
  }

  // Markaları çekmek için
  // Markaları çekmek için
  Future<List<Brand>> fetchBrands() async {
    // baseUrl tanımlı olduğundan emin ol
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/Products/brands'),
    );

    if (response.statusCode == 200) {
      // Listeyi dynamic olarak alıp modele çeviriyoruz
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Brand.fromJson(data)).toList();
    } else {
      throw Exception('Markalar yüklenemedi');
    }
  }

  // Ürünleri çekmek için
  Future<List<ProductItem>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/Products/all'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => ProductItem.fromJson(data)).toList();
    } else {
      throw Exception('Ürünler yüklenemedi');
    }
  }
}
