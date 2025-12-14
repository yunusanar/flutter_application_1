import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';

class ActionService {
  // İşlem/İşçilik Ekle
  Future<bool> addAction(int requestId, String islemAdi, double ucret) async {
    var url = Uri.parse('${ApiConstants.baseUrl}/ServiceActions');

    var bodyData = {
      "serviceRequestId": requestId,
      "islemAdi": islemAdi,
      "ucret": ucret,
    };

    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("İşlem ekleme hatası: $e");
      return false;
    }
  }

  // Yapılan işlemleri getir
  Future<List<dynamic>> getActions(int requestId) async {
    try {
      var url = Uri.parse('${ApiConstants.baseUrl}/ServiceActions/$requestId');
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
