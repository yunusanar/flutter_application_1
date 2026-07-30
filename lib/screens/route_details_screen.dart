import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/gradient_appbar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/request_service.dart';

class RouteDetailsScreen extends StatefulWidget {
  final String tarih;
  final String teamName; // YENİ EKLENDİ: Ekip Adı

  const RouteDetailsScreen({
    super.key,
    required this.tarih,
    required this.teamName, // Constructor'a eklendi
  });

  @override
  _RouteDetailsScreenState createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> {
  final RequestService _requestService = RequestService();
  List<dynamic> gunlukIsler = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _gununIsleriniGetir();
  }

  Future<void> _gununIsleriniGetir() async {
    // API'YE İSTEK ATARKEN ARTIK EKİP ADINI DA GÖNDERİYORUZ (Boş sayfa sorununun çözümü)
    var veriler = await _requestService.getRouteDetails(
      widget.tarih,
      widget.teamName,
    );
    setState(() {
      gunlukIsler = veriler;
      isLoading = false;
    });
  }

  // C#'tan gelen 2026-07-23T09:30:00 formatını 09:30 yapar
  String saatiFormatla(String? hamSaat) {
    if (hamSaat == null) return "Saat Yok";
    try {
      DateTime dt = DateTime.parse(hamSaat);
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Temamızdaki renkleri alıyoruz (Gece Mavisi ve Turkuaz)
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GradientAppBar(
        title: '${widget.tarih} Rotası - ${widget.teamName}',
      ), // Ekip adı başlığa eklendi
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : gunlukIsler.isEmpty
          ? const Center(
              child: Text(
                "Bu tarihte iş bulunamadı.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: gunlukIsler.length,
              itemBuilder: (context, index) {
                var isItem = gunlukIsler[index];
                String musteri = isItem['musteriAdi'] ?? "İsimsiz";
                String adres = isItem['adres'] ?? "Adres Yok";
                String saat = saatiFormatla(isItem['estimatedArrivalTime']);
                int sira = isItem['routeOrder'] ?? (index + 1);

                return Card(
                  // Şekil ve gölge özellikleri main.dart'taki CardTheme'den otomatik alınıyor
                  clipBehavior:
                      Clip.antiAlias, // Kenarlığın karta tam oturması için
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    // Sol tarafa çok şık bir turkuaz çizgi ekliyoruz
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: theme.colorScheme.secondary,
                          width: 4,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sol Taraf: Sıra ve Saat
                        Column(
                          children: [
                            CircleAvatar(
                              // Arka planı transparan turkuaz yapıyoruz
                              backgroundColor: theme.colorScheme.secondary
                                  .withOpacity(0.15),
                              radius: 18,
                              child: Text(
                                "$sira",
                                style: TextStyle(
                                  color: theme
                                      .colorScheme
                                      .secondary, // Turkuaz rakam
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              saat,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme
                                    .colorScheme
                                    .primary, // Gece mavisi saat
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        // Sağ Taraf: Müşteri Bilgileri
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                musteri,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                adres,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                  height: 1.3, // Satır arası boşluk
                                ),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _haritayiAc(adres);
                                  },
                                  icon: const Icon(Icons.map, size: 16),
                                  label: const Text("Navigasyon"),
                                  // Butonun rengi (mavi kodları silindiği için) main.dart'tan otomatik turkuaz gelecek
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

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
}
