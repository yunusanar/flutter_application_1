import 'package:flutter/material.dart';
import '../services/part_service.dart';
import '../services/action_service.dart';

class RequestDetailScreen extends StatefulWidget {
  final Map<String, dynamic> talepData;
  const RequestDetailScreen({super.key, required this.talepData});

  @override
  _RequestDetailScreenState createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  final PartService _partService = PartService();
  final ActionService _actionService = ActionService();

  List<dynamic> parcalar = [];
  List<dynamic> islemler = [];
  bool loading = true;
  double toplam = 0;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  void _yukle() async {
    int id = widget.talepData['id'];

    var p = await _partService.getUsedParts(id);
    var i = await _actionService.getActions(id);

    setState(() {
      parcalar = p;
      islemler = i;

      // --- DÜZELTME: 0 yerine 0.0 (Ondalıklı sayı desteği) ---
      double parcaToplami = p.fold(0.0, (sum, item) {
        var fiyat = item['fiyat'] ?? 0;
        return sum + (fiyat is int ? fiyat.toDouble() : fiyat);
      });

      double islemToplami = i.fold(0.0, (sum, item) {
        var ucret = item['ucret'] ?? 0;
        return sum + (ucret is int ? ucret.toDouble() : ucret);
      });
      // ------------------------------------------------------

      toplam = parcaToplami + islemToplami;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Talep Detayı"),
        backgroundColor: Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.info,
                        size: 40,
                        color: Color(0xFF1565C0),
                      ),
                      title: Text(
                        widget.talepData['urun'] ?? "Cihaz",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Müşteri: ${widget.talepData['musteriAdi']}\nDurum: ${widget.talepData['durum']}",
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.receipt_long, color: Colors.grey),
                      SizedBox(width: 10),
                      Text(
                        "Harcamalar & İşlemler",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  if (parcalar.isEmpty && islemler.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "Henüz maliyet girilmemiş.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),

                  ...parcalar.map(
                    (p) => ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.settings,
                        size: 18,
                        color: Colors.orange,
                      ),
                      title: Text(p['parcaAdi']),
                      trailing: Text(
                        "${p['fiyat']} TL",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  ...islemler.map(
                    (i) => ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.handyman,
                        size: 18,
                        color: Colors.blue,
                      ),
                      title: Text(i['islemAdi']),
                      trailing: Text(
                        "${i['ucret']} TL",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  Divider(thickness: 2),
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "TOPLAM TUTAR",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                        Text(
                          "${toplam.toStringAsFixed(2)} TL",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
