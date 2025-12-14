import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Harita için gerekli
import '../services/request_service.dart';
import '../services/part_service.dart';
import '../services/action_service.dart';
import '../models/spare_part.dart';
import 'login_screen.dart';
import 'request_detail_screen.dart';

class TechnicianScreen extends StatefulWidget {
  final String adSoyad;
  const TechnicianScreen({super.key, required this.adSoyad});

  @override
  _TechnicianScreenState createState() => _TechnicianScreenState();
}

class _TechnicianScreenState extends State<TechnicianScreen> {
  // Servisler
  final RequestService _requestService = RequestService();
  final PartService _partService = PartService();
  final ActionService _actionService = ActionService();

  // Arama Değişkenleri
  final TextEditingController _searchController = TextEditingController();
  String _aramaMetni = "";

  // --- HARİTA AÇMA FONKSİYONU ---
  Future<void> _haritayiAc(String adres) async {
    // Adresi URL formatına çevir
    final Uri googleMapsUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(adres)}",
    );

    try {
      if (!await launchUrl(
        googleMapsUrl,
        mode: LaunchMode.externalApplication,
      )) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Harita açılamadı.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
  }

  // --- DURUM GÜNCELLEME ---
  void _durumDegistir(int id, String suankiDurum) async {
    String yeniDurum = suankiDurum == "Beklemede" ? "Tamamlandı" : "Beklemede";
    bool sonuc = await _requestService.updateStatus(id, yeniDurum);
    if (sonuc) {
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("İş durumu güncellendi!")));
    }
  }

  // --- PARÇA EKLEME PENCERESİ ---
  void _parcaEkleDialog(BuildContext context, int requestId) {
    SparePart? secilenParca;
    TextEditingController adetController = TextEditingController(text: "1");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Parça Kullan"),
          content: FutureBuilder<List<SparePart>>(
            future: _partService.getSpareParts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: 50,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text("Stokta parça yok.");
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<SparePart>(
                    hint: Text("Parça Seçiniz"),
                    isExpanded: true,
                    items: snapshot.data!.map((parca) {
                      return DropdownMenuItem(
                        value: parca,
                        child: Text("${parca.parcaAdi} (Stok: ${parca.stok})"),
                      );
                    }).toList(),
                    onChanged: (val) {
                      secilenParca = val;
                    },
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: adetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Adet",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (secilenParca == null) return;
                int adet = int.tryParse(adetController.text) ?? 1;
                bool sonuc = await _partService.addPartToRequest(
                  requestId,
                  secilenParca!.id,
                  adet,
                );
                Navigator.pop(context);
                if (sonuc) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Parça eklendi!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Hata oluştu."),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text("KAYDET"),
            ),
          ],
        );
      },
    );
  }

  // --- İŞÇİLİK EKLEME PENCERESİ ---
  void _islemEkleDialog(BuildContext context, int requestId) {
    TextEditingController islemAdiController = TextEditingController();
    TextEditingController ucretController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("İşçilik / İşlem Ekle"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: islemAdiController,
                decoration: InputDecoration(
                  hintText: "Örn: Gaz Dolumu, Kurulum...",
                  labelText: "Yapılan İşlem",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: ucretController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Örn: 500",
                  labelText: "Ücret (TL)",
                  border: OutlineInputBorder(),
                  suffixText: "TL",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("İptal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () async {
                if (islemAdiController.text.isEmpty ||
                    ucretController.text.isEmpty) {
                  return;
                }
                double ucret = double.tryParse(ucretController.text) ?? 0;
                bool sonuc = await _actionService.addAction(
                  requestId,
                  islemAdiController.text,
                  ucret,
                );
                Navigator.pop(context);
                if (sonuc) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("İşlem başarıyla eklendi!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Hata oluştu."),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text("EKLE", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        // --- ARAMA KUTUSU (BEYAZ FON, SİYAH YAZI) ---
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _aramaMetni = value.toLowerCase();
              });
            },
            style: TextStyle(color: Colors.black, fontSize: 16),
            cursorColor: Colors.black,
            decoration: InputDecoration(
              hintText: "Müşteri Adı Ara...",
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              suffixIcon: _aramaMetni.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _aramaMetni = "";
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),

        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _requestService.getAllRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Bekleyen iş yok."));
          }

          // --- FİLTRELEME (Sadece Müşteri Adı) ---
          var isListesi = snapshot.data!.where((kayit) {
            var musteri = (kayit['musteriAdi'] ?? "").toString().toLowerCase();
            return musteri.contains(_aramaMetni);
          }).toList();
          // -------------------------------------

          if (isListesi.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Bu isimde müşteri bulunamadı."),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: isListesi.length,
            itemBuilder: (context, index) {
              var isEmri = isListesi[index];

              var musteri = isEmri['musteriAdi'] ?? "İsimsiz";
              var adres = isEmri['adres'] ?? "Adres Yok";
              var urun = isEmri['urun'] ?? "Cihaz Yok";
              var aciklama = isEmri['aciklama'] ?? "-";
              var durum = isEmri['durum'] ?? "Beklemede";
              int id = isEmri['id'] ?? 0;
              bool tamamlandi = durum == "Tamamlandı";

              // --- İKON SEÇİMİ (KURULUM MU ARIZA MI?) ---
              bool kurulumMu = aciklama.toString().toUpperCase().contains(
                "KURULUM",
              );

              IconData durumIkonu;
              Color ikonRengi;

              if (tamamlandi) {
                durumIkonu = Icons.check_circle;
                ikonRengi = Colors.green;
              } else if (kurulumMu) {
                durumIkonu = Icons.new_releases; // Kurulum için Mavi Rozet
                ikonRengi = Colors.blue;
              } else {
                durumIkonu = Icons.warning; // Arıza için Turuncu Ünlem
                ikonRengi = Colors.orange;
              }
              // -----------------------------------------

              return Card(
                color: tamamlandi ? Colors.green.shade50 : Colors.white,
                margin: EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RequestDetailScreen(talepData: isEmri),
                            ),
                          ).then((_) {
                            setState(() {}); // Dönüşte ekranı yenile
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        // Dinamik İkon Kullanımı
                        leading: Icon(durumIkonu, color: ikonRengi, size: 40),
                        title: Text(
                          urun,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            Text(
                              "Müşteri: $musteri",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),

                            // --- ADRES VE HARİTA BUTONU ---
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Adres: $adres",
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.map, color: Colors.blue),
                                    tooltip: "Haritada Göster",
                                    constraints:
                                        BoxConstraints(), // Sıkışık görünüm için
                                    padding: EdgeInsets.all(8),
                                    onPressed: () => _haritayiAc(adres),
                                  ),
                                ),
                              ],
                            ),

                            // -----------------------------
                            SizedBox(height: 5),
                            // Açıklama rengi: Kurulum ise Mavi, Arıza ise Kırmızı
                            Text(
                              "Talep: $aciklama",
                              style: TextStyle(
                                color: kurulumMu
                                    ? Colors.blue.shade800
                                    : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "(Detaylar için tıklayın)",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(),

                      tamamlandi
                          ? SizedBox()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.settings_input_component,
                                    size: 16,
                                  ),
                                  label: Text("Parça"),
                                  onPressed: () =>
                                      _parcaEkleDialog(context, id),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                  ),
                                  icon: Icon(Icons.handyman, size: 16),
                                  label: Text("İşçilik"),
                                  onPressed: () =>
                                      _islemEkleDialog(context, id),
                                ),
                              ],
                            ),

                      SizedBox(height: 5),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: tamamlandi
                                ? Colors.grey
                                : Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          icon: Icon(tamamlandi ? Icons.undo : Icons.check),
                          label: Text(tamamlandi ? "Geri Al" : "İşi Tamamla"),
                          onPressed: () => _durumDegistir(id, durum),
                        ),
                      ),
                    ],
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
