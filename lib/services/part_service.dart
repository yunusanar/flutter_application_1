import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';
import '../models/spare_part.dart';

class PartService {
  // 1. Tüm Yedek Parçaları Getir
  Future<List<SparePart>> getSpareParts() async {
    try {
      var url = Uri.parse('${ApiConstants.baseUrl}/SpareParts');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => SparePart.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Parça listesi çekilirken hata: $e");
      return [];
    }
  }

  // 2. Arızaya Parça Ekle (ve Stoktan Düş)
  Future<bool> addPartToRequest(int requestId, int partId, int adet) async {
    var url = Uri.parse('${ApiConstants.baseUrl}/ServiceSpareParts');

    // Backend'e gönderilecek paket
    var bodyData = {
      "serviceRequestId": requestId,
      "sparePartId": partId,
      "adet": adet,
    };

    print("GÖNDERİLEN VERİ: $bodyData"); // Konsolda bunu kontrol edeceğiz

    try {
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(bodyData),
      );

      // --- İŞTE BURASI HATAYI GÖSTERECEK ---
      if (response.statusCode == 200) {
        return true;
      } else {
        // Hata varsa konsola kırmızı kırmızı yazdırır
        print("❌ HATA DETAYI (${response.statusCode}): ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ BAĞLANTI HATASI: $e");
      return false;
    }
  }

  // Arızada kullanılan parçaları getir
  Future<List<dynamic>> getUsedParts(int requestId) async {
    try {
      var url = Uri.parse(
        '${ApiConstants.baseUrl}/ServiceSpareParts/$requestId',
      );
      var response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
