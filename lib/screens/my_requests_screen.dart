import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/gradient_appbar.dart';
import '../services/request_service.dart';
import '../models/request_model.dart';
import 'request_detail_screen.dart';

class MyRequestsScreen extends StatefulWidget {
  final int userId;
  const MyRequestsScreen({super.key, required this.userId});
  @override
  _MyRequestsScreenState createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  final RequestService _requestService = RequestService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: "Taleplerim"),
      body: FutureBuilder<List<RequestModel>>(
        future: _requestService.getMyRequests(widget.userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.isEmpty) {
            return Center(child: Text("Kaydınız yok."));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var talep = snapshot.data![index];
              bool bitti = talep.durum == "Tamamlandı";
              return Card(
                child: ListTile(
                  onTap: () {
                    Map<String, dynamic> data = {
                      "id": talep.id,
                      "musteriAdi": "Siz",
                      "urun": talep.urunAdi,
                      "aciklama": talep.aciklama,
                      "durum": talep.durum,
                      "urunTuru": talep.urunTuru,
                    };

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RequestDetailScreen(talepData: data),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundColor: bitti
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    child: Icon(
                      bitti ? Icons.check : Icons.access_time,
                      color: bitti ? Colors.green : Colors.orange,
                    ),
                  ),
                  title: Text(
                    talep.urunAdi +
                        (talep.urunTuru != "Belirsiz"
                            ? " (${talep.urunTuru})"
                            : ""),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${talep.aciklama}\n${talep.tarih}",
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
