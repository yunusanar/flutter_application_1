import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';
import '../models/request_model.dart'; // Yeni modeli eklemeyi unutmayın

class RequestService {
  // 1. TALEP OLUŞTURMA (Zaten Vardı)
  Future<bool> createServiceRequest(
    int userId,
    int productId,
    String aciklama,
  ) async {
    // ... (Eski kodlar aynen kalsın) ...
    var url = Uri.parse('${ApiConstants.baseUrl}/ServiceRequests');
    var bodyData = {
      "userId": userId,
      "productId": productId,
      "aciklama": aciklama,
      "durum": "Beklemede",
    };
    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyData),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 2. TALEPLERİMİ GETİR (Bunu Yeni Ekliyoruz)
  Future<List<RequestModel>> getMyRequests(int userId) async {
    var url = Uri.parse('${ApiConstants.baseUrl}/ServiceRequests/user/$userId');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => RequestModel.fromJson(item)).toList();
    } else {
      return []; // Hata varsa boş liste dön
    }
  }

  // TEKNİSYEN İÇİN: Tüm arızaları getir
  Future<List<Map<String, dynamic>>> getAllRequests() async {
    var url = Uri.parse('${ApiConstants.baseUrl}/ServiceRequests/all');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      // Gelen veriyi List<Map> olarak döndür (Basit yöntem)
      return body.cast<Map<String, dynamic>>();
    } else {
      return [];
    }
  }

  // TEKNİSYEN İÇİN: Durum Güncelleme (Bekliyor -> Tamamlandı)
  Future<bool> updateStatus(int id, String yeniDurum) async {
    var url = Uri.parse('${ApiConstants.baseUrl}/ServiceRequests/$id/durum');
    var response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(yeniDurum), // Sadece string gönderiyoruz
    );
    return response.statusCode == 200;
  }
  // request_service.dart içerisine eklenecek

  // Tarih ve ekip adını da alacak şekilde güncelliyoruz
  // Artık true/false yerine SMS listesini dönecek. Başarısız olursa null dönecek.
  Future<List<String>?> generateDailyRoute(
    List<int> selectedRequestIds,
    String selectedDate,
    String teamName,
  ) async {
    var url = Uri.parse(
      '${ApiConstants.baseUrl}/ServiceRequests/GenerateDailyRoute',
    );

    final Map<String, dynamic> requestBody = {
      "selectedRequestIds": selectedRequestIds,
      "selectedDate": selectedDate,
      "teamName": teamName,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Dönen JSON'u parse edip smsLogs dizisini alıyoruz
        var decoded = jsonDecode(response.body);
        List<dynamic> logs = decoded['smsLogs'] ?? [];
        return logs.map((e) => e.toString()).toList();
      } else {
        return null;
      }
    } catch (e) {
      print("Hata (generateDailyRoute): $e");
      return null;
    }
  }
  // request_service.dart içerisine eklenecek

  // Günlük özetleri getirir (Rotalarım ekranı için)
  Future<List<dynamic>> getRouteSummaries() async {
    var url = Uri.parse(
      '${ApiConstants.baseUrl}/ServiceRequests/GetRouteSummaries',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Hata (getRouteSummaries): $e");
    }
    return [];
  }

  // Belirli bir günün işlerini getirir (Rota Detay ekranı için)
  // Eski halinde sadece 'String date' alıyordu, artık 'String teamName' de alacak
  Future<List<Map<String, dynamic>>> getRouteDetails(
    String date,
    String teamName,
  ) async {
    // URL'nin sonuna teamName'i de ekliyoruz (C# API'nin beklediği format)
    var url = Uri.parse(
      '${ApiConstants.baseUrl}/ServiceRequests/GetRouteDetails/$date/$teamName',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      print("Hata (getRouteDetails): $e");
      return [];
    }
  }
}
