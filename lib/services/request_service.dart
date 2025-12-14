import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';
import '../models/request_model.dart';

class RequestService {
  // Tüm İş Emirlerini Getir (Teknisyen İçin)
  Future<List<Map<String, dynamic>>> getAllRequests() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/ServiceRequests"),
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
    } catch (e) {
      print("Hata: $e");
    }
    return [];
  }

  // Müşterinin Kendi Talepleri
  Future<List<RequestModel>> getMyRequests(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/ServiceRequests/User/$userId"),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => RequestModel.fromJson(e)).toList();
      }
    } catch (e) {
      print("Hata: $e");
    }
    return [];
  }

  // Durum Güncelle (Teknisyen)
  Future<bool> updateStatus(int id, String status) async {
    try {
      final response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/ServiceRequests/$id/status"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(status),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- GERÇEK TALEP OLUŞTURMA ---
  Future<bool> createServiceRequest(
    int userId,
    int customerProductId,
    String description,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/ServiceRequests"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "customerProductId": customerProductId == 0
              ? null
              : customerProductId, // 0 ise null gönder (Genel talep)
          "aciklama": description,
          // Tarih ve Durum backend'de atanacak
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Hata: $e");
      return false;
    }
  }
}
