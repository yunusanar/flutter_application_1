import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/daily_route_Screen.dart';
import 'package:flutter_application_1/theme/gradient_appbar.dart';
import 'package:url_launcher/url_launcher.dart'; // Harita paketi
import '../services/request_service.dart';
import '../services/part_service.dart';
import '../services/action_service.dart';
import '../models/spare_part.dart';
import 'login_screen.dart';
import 'request_detail_screen.dart';
import 'route_summaries_screen.dart';
import 'package:signature/signature.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class TechnicianScreen extends StatefulWidget {
  final String adSoyad;
  const TechnicianScreen({super.key, required this.adSoyad});

  @override
  _TechnicianScreenState createState() => _TechnicianScreenState();
}

class _TechnicianScreenState extends State<TechnicianScreen> {
  final RequestService _requestService = RequestService();
  final PartService _partService = PartService();
  final ActionService _actionService = ActionService();

  final TextEditingController _searchController = TextEditingController();
  String _aramaMetni = "";

  // --- HARİTA AÇMA FONKSİYONU ---
  Future<void> _haritayiAc(String adres) async {
    final Uri googleMapsUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(adres)}",
    );

    try {
      if (!await launchUrl(
        googleMapsUrl,
        mode: LaunchMode.externalApplication,
      )) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Harita uygulaması bulunamadı.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Harita açılırken hata oluştu: $e")),
      );
    }
  }

  // ------------------------------
  Future<void> _musteriyiAra(String telefonNumarasi) async {
    final Uri launchUri = Uri(scheme: 'tel', path: telefonNumarasi);
    try {
      if (!await launchUrl(launchUri)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Arama başlatılamadı."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _imzaAlVeGoreviTamamla(int isEmriId) {
    // İmza kontrolcüsünü oluşturuyoruz (Kalem kalınlığı ve rengi)
    final SignatureController signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Müşteri İmzası', style: TextStyle(fontSize: 18)),
          // 1. ÇÖZÜM BURASI: Column'u bir SizedBox içine alıp genişliği zorunlu kılıyoruz
          content: SizedBox(
            width: MediaQuery.of(
              context,
            ).size.width, // Ekranın alabileceği maksimum genişliği veriyoruz
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("İşlemi onaylamak için lütfen aşağıya imza atınız."),
                const SizedBox(height: 10),

                // 2. İMZA ALANI: Genişliği sınırlı tutuyoruz
                Container(
                  width: double
                      .infinity, // SizedBox'ın verdiği tüm genişliği kapla
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Signature(
                    controller: signatureController,
                    height: 200,
                    backgroundColor: Colors.grey[100]!,
                  ),
                ),

                const SizedBox(height: 10),
                // TEMİZLE BUTONU
                TextButton.icon(
                  onPressed: () => signatureController.clear(),
                  icon: const Icon(Icons.clear, color: Colors.red),
                  label: const Text(
                    "Temizle",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                if (signatureController.isNotEmpty) {
                  final Uint8List? signatureBytes = await signatureController
                      .toPngBytes();
                  if (signatureBytes != null) {
                    String base64Imza = base64Encode(signatureBytes);

                    await http.put(
                      Uri.parse(
                        'http://10.0.2.2:5227/api/ServiceRequests/$isEmriId/tamamla',
                      ),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode({
                        'yeniDurum': 'Tamamlandı',
                        'imzaBase64': base64Imza,
                      }),
                    );

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'İş başarıyla tamamlandı ve imza kaydedildi!',
                        ),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lütfen önce imza atınız!')),
                  );
                }
              },
              child: const Text(
                'Onayla ve Bitir',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // İş Emri ID'si ve Çekilen Fotoğrafın dosya yolunu eşleştirir
  Map<int, File> _isEmriFotograflari = {};
  final ImagePicker _picker = ImagePicker();
  Future<void> _fotografCek(int isEmriId) async {
    try {
      // Kamerayı açar (imageQuality ile boyutu küçültüyoruz ki interneti yormasın)
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      // Eğer kullanıcı fotoğraf çektiyse (geri tuşuna basıp çıkmadıysa)
      if (foto != null) {
        setState(() {
          _isEmriFotograflari[isEmriId] = File(foto.path);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Fotoğraf başarıyla eklendi!")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Hata Detayı: $e"),
            duration: const Duration(
              seconds: 5,
            ), // Okuyabilmen için süreyi uzattık
          ),
        );
      }
    }
  }

  // Barkodu doğrulanmış (kilidi açılmış) iş emirlerinin ID'lerini tutar
  final Set<int> _barkoduOnaylananIsler = {};
  void _barkodOnayDialogAc(int isEmriId) {
    TextEditingController barkodController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Cihaz Barkodu Gerekli",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Bu cihaza işlem yapabilmek için lütfen barkod numarasını okutun veya elle girin.",
              ),
              const SizedBox(height: 16),
              TextField(
                controller: barkodController,
                decoration: InputDecoration(
                  hintText: "Barkod No (Örn: SN-1008)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // Barkod Okuyucu İkonu
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.qr_code_scanner,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () async {
                      // İLERİDE BURAYA KAMERA PAKETİ EKLENECEK
                      // Örnek: String res = await FlutterBarcodeScanner.scanBarcode(...);
                      // barkodController.text = res;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Kamera entegrasyonu yakında eklenecek.",
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: () {
                if (barkodController.text.isNotEmpty) {
                  // Barkod girildiyse bu iş emrinin kilidini aç
                  setState(() {
                    _barkoduOnaylananIsler.add(isEmriId);
                  });
                  Navigator.pop(context); // Dialogu kapat
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Barkod doğrulandı, işlem kilidi açıldı!"),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Lütfen geçerli bir barkod girin!"),
                    ),
                  );
                }
              },
              child: const Text(
                "Onayla ve Başla",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _durumDegistir(int id, String suankiDurum) async {
    String yeniDurum = suankiDurum == "Beklemede" ? "Tamamlandı" : "Beklemede";
    bool sonuc = await _requestService.updateStatus(id, yeniDurum);
    if (sonuc) {
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Durum güncellendi!")));
    }
  }

  void _parcaEkleDialog(BuildContext context, int requestId) {
    SparePart? secilenParca;
    TextEditingController adetController = TextEditingController(text: "1");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Parça Kullan"),
          content: FutureBuilder<List<SparePart>>(
            future: _partService.getSpareParts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 50,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text("Stokta parça yok.");
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<SparePart>(
                    hint: const Text("Parça Seçiniz"),
                    isExpanded: true,
                    items: snapshot.data!
                        .map(
                          (parca) => DropdownMenuItem(
                            value: parca,
                            child: Text(
                              "${parca.parcaAdi} (Stok: ${parca.stok})",
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      secilenParca = val;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: adetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Adet"),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (secilenParca == null) return;
                int adet = int.tryParse(adetController.text) ?? 1;
                await _partService.addPartToRequest(
                  requestId,
                  secilenParca!.id,
                  adet,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Parça eklendi!"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text("KAYDET"),
            ),
          ],
        );
      },
    );
  }

  void _islemEkleDialog(BuildContext context, int requestId) {
    TextEditingController islemAdiController = TextEditingController();
    TextEditingController ucretController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("İşçilik Ekle"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: islemAdiController,
                decoration: const InputDecoration(
                  hintText: "Örn: Gaz Dolumu...",
                  labelText: "İşlem",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ucretController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "500",
                  labelText: "Ücret (TL)",
                  suffixText: "TL",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (islemAdiController.text.isEmpty) return;
                double ucret = double.tryParse(ucretController.text) ?? 0;
                await _actionService.addAction(
                  requestId,
                  islemAdiController.text,
                  ucret,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("İşlem eklendi!"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text("EKLE"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // --- 1. KISIM: YENİ APPBAR ---
      appBar: GradientAppBar(
        title: "Teknisyen: ${widget.adSoyad}", // Sadece düz metin verdik
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: "Geçmiş Rotalarım",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RouteSummariesScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16.0), // Kenarlardan biraz boşluk
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12), // Biraz daha yuvarlak
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  setState(() => _aramaMetni = value.toLowerCase()),
              style: const TextStyle(color: Colors.black, fontSize: 16),
              cursorColor: Colors.black,
              decoration: InputDecoration(
                hintText: "Müşteri Adı Ara...",
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _aramaMetni.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _aramaMetni = "");
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _requestService.getAllRequests(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Bekleyen iş yok."));
                }

                var isListesi = snapshot.data!.where((kayit) {
                  var musteri = (kayit['musteriAdi'] ?? "")
                      .toString()
                      .toLowerCase();
                  return musteri.contains(_aramaMetni);
                }).toList();

                if (isListesi.isEmpty) {
                  return const Center(child: Text("Kayıt bulunamadı."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: isListesi.length,
                  itemBuilder: (context, index) {
                    var isEmri = isListesi[index];
                    var musteri = isEmri['musteriAdi'] ?? "İsimsiz";
                    var adres = isEmri['adres'] ?? "Adres Yok";
                    var urun = isEmri['urun'] ?? "Cihaz Yok";
                    var kategori = isEmri['kategori'] ?? "Belirsiz";
                    var aciklama = isEmri['aciklama'] ?? "-";
                    var durum = isEmri['durum'] ?? "Beklemede";
                    int id = isEmri['id'] ?? 0;
                    bool tamamlandi = durum == "Tamamlandı";

                    var tahminiVaris = isEmri['estimatedArrivalTime'];

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12.0,
                        ), // Kartın köşeleriyle uyumlu
                        side: BorderSide(
                          color: const Color(
                            0xFF0D47A1,
                          ), // Çok Koyu Mavi (Blue shade 900)
                          width: 1.0, // İnce, zarif bir çizgi
                        ),
                      ),
                      // Eğer tamamlandıysa çok hafif yeşil, değilse temanın kendi beyazını alır
                      color: tamamlandi ? Colors.green.shade50 : null,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            ListTile(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RequestDetailScreen(talepData: isEmri),
                                ),
                              ).then((_) => setState(() {})),
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                tamamlandi
                                    ? Icons.check_circle
                                    : Icons.warning_amber_rounded,
                                color: tamamlandi
                                    ? Colors.green
                                    : colorScheme.secondary,
                                size: 40,
                              ),
                              title: Text(
                                "Ürün: $urun $kategori",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5),
                                  Text(
                                    "Müşteri: $musteri",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // --- ADRES, HARİTA VE ARAMA BUTONLARI YAN YANA ---
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Sol Taraf: Adres Metni
                                      Expanded(
                                        child: Text(
                                          "Adres: $adres",
                                          style: const TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),

                                      // Sağ Taraf: Aksiyon Butonları
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // 1. ARAMA BUTONU
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors
                                                  .green
                                                  .shade50, // Yeşilin çok açık tonu
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.phone,
                                                color: Colors.green.shade600,
                                              ),
                                              tooltip: "Müşteriyi Ara",
                                              onPressed: () {
                                                // API'den gelen telefon numarası
                                                String tel =
                                                    isEmri['telefon'] ??
                                                    "05000000000";
                                                // Kendi sayfana yazdığın fonksiyonu çağırıyoruz!
                                                _musteriyiAra(tel);
                                              },
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ), // İki buton arası boşluk
                                          // 2. HARİTA BUTONU
                                          Container(
                                            decoration: BoxDecoration(
                                              color: colorScheme.secondary
                                                  .withOpacity(
                                                    0.1,
                                                  ), // Temanın Turkuaz tonu
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.map,
                                                color: colorScheme.secondary,
                                              ),
                                              tooltip: "Haritada Göster",
                                              onPressed: () =>
                                                  _haritayiAc(adres),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  // ------------------------------------------------
                                  if (tahminiVaris != null && !tamamlandi)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8.0,
                                        bottom: 4.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.access_time_filled,
                                            size: 16,
                                            color: colorScheme
                                                .primary, // Gece Mavisi Saat
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Tahmini Varış: $tahminiVaris",
                                            style: TextStyle(
                                              color: colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Sorun: $aciklama",
                                    style: const TextStyle(
                                      color: Colors.red,
                                    ), // Hata/Sorun olduğu için kırmızı kaldı
                                  ),

                                  if (isEmri['aiYorum'] != null &&
                                      isEmri['aiYorum'].toString().isNotEmpty)
                                    ExpandableAiBox(
                                      aiYorum: isEmri['aiYorum'].toString(),
                                    ),

                                  // --- AI MODÜLÜ BİTİŞİ ---
                                ],
                              ),
                            ),
                            const Divider(),

                            // 1. DURUM: EĞER İŞ TAMAMLANDIYSA (Sadece Geri Al butonu görünür)
                            if (tamamlandi)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                  ),
                                  icon: const Icon(
                                    Icons.undo,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Geri Al",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    // İş tamamlanmış, tekrar açmak için eski durum değiştirme metodunu çağırıyoruz
                                    _durumDegistir(id, durum);
                                  },
                                ),
                              )
                            // 2. DURUM: İŞ TAMAMLANMADIYSA
                            else
                            // 2A: Barkod okutulmuşsa (İşlem butonları açılır)
                            if (_barkoduOnaylananIsler.contains(id))
                              Column(
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 4.0,
                                            ),
                                            child: ElevatedButton.icon(
                                              icon: const Icon(
                                                Icons.settings_input_component,
                                                size: 16,
                                              ),
                                              label: const Text(
                                                "Parça",
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              onPressed: () =>
                                                  _parcaEkleDialog(context, id),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 4.0,
                                            ),
                                            child: ElevatedButton.icon(
                                              icon: const Icon(
                                                Icons.handyman,
                                                size: 16,
                                              ),
                                              label: const Text(
                                                "İşçilik",
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              onPressed: () =>
                                                  _islemEkleDialog(context, id),
                                            ),
                                          ),
                                        ),
                                        // 3. YENİ EKLENEN FOTOĞRAF BUTONU
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 2.0,
                                            ),
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                // Eğer bu işe ait fotoğraf varsa butonun rengi hafif mavi olur
                                                backgroundColor:
                                                    _isEmriFotograflari
                                                        .containsKey(id)
                                                    ? colorScheme.primary
                                                          .withOpacity(0.1)
                                                    : null,
                                                foregroundColor:
                                                    _isEmriFotograflari
                                                        .containsKey(id)
                                                    ? colorScheme.primary
                                                    : null,
                                              ),
                                              icon: Icon(
                                                // Fotoğraf varsa tik işareti, yoksa kamera ikonu gösterir
                                                _isEmriFotograflari.containsKey(
                                                      id,
                                                    )
                                                    ? Icons.check_circle
                                                    : Icons.camera_alt,
                                                size: 16,
                                              ),
                                              label: const Text(
                                                "Foto",
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              onPressed: () => _fotografCek(id),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      icon: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        "İşi Tamamla",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () =>
                                          _imzaAlVeGoreviTamamla(id),
                                    ),
                                  ),
                                ],
                              )
                            // 2B: Barkod henüz okutulmamışsa (Sadece Kilit Butonu görünür)
                            else
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.secondary
                                        .withOpacity(0.1),
                                    foregroundColor: colorScheme.secondary,
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.qr_code_scanner),
                                  label: const Text(
                                    "İşleme Başlamak İçin Barkod Okut",
                                  ),
                                  onPressed: () => _barkodOnayDialogAc(id),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DailyRouteScreen()),
          ).then((_) {
            setState(() {});
          });
        },
        label: const Text("Rotayı Planla"),
        icon: const Icon(Icons.route),
        // Rengi global temadan alması için eski mavi kodlarını sildik
      ),
    );
  }
}

class ExpandableAiBox extends StatefulWidget {
  final String aiYorum;

  const ExpandableAiBox({super.key, required this.aiYorum});

  @override
  _ExpandableAiBoxState createState() => _ExpandableAiBoxState();
}

class _ExpandableAiBoxState extends State<ExpandableAiBox> {
  bool isExpanded = false; // Kutunun açık/kapalı durumunu tutar

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded; // Tıklanınca durumu tersine çevir
        });
      },
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.secondary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: colorScheme.secondary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.auto_awesome, color: colorScheme.secondary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "AI Ön Analiz & Öneri",
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Metin kısmı: Kapalıysa 2 satır gösterip sonuna '...' koyar, açıksa hepsini gösterir
                  Text(
                    widget.aiYorum,
                    maxLines: isExpanded ? null : 2,
                    overflow: isExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  // Eğer kapalıysa (kısa görünüyorsa) "Devamını oku" yazısı çıksın
                  if (!isExpanded)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "Tıklayarak tamamını gör...",
                        style: TextStyle(
                          color: colorScheme.secondary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
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
