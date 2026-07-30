import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/gradient_appbar.dart';
import '../services/request_service.dart'; // Yolunu kendi projene göre düzelt

class DailyRouteScreen extends StatefulWidget {
  const DailyRouteScreen({super.key});

  @override
  _DailyRouteScreenState createState() => _DailyRouteScreenState();
}

class _DailyRouteScreenState extends State<DailyRouteScreen> {
  final RequestService _requestService = RequestService();

  List<dynamic> bekleyenIsler = [];
  List<int> secilenIsIdleri = [];
  bool isLoading = true;

  DateTime _secilenTarih = DateTime.now();
  String _secilenEkip = 'Ekip 1';
  final List<String> _ekipler = ['Ekip 1', 'Ekip 2', 'Ekip 3', 'Ekip 4'];

  @override
  void initState() {
    super.initState();
    _bekleyenIsleriGetir();
  }

  Future<void> _bekleyenIsleriGetir() async {
    setState(() => isLoading = true);

    try {
      var tumIsler = await _requestService.getAllRequests();

      var filtrelenmis = tumIsler.where((isEmri) {
        var durum = isEmri['durum'] ?? "";
        var varisSaati = isEmri['estimatedArrivalTime'];
        return durum == "Beklemede" && varisSaati == null;
      }).toList();

      setState(() {
        bekleyenIsler = filtrelenmis;
      });
    } catch (e) {
      print("İşler çekilirken hata: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> _tarihSec(BuildContext context) async {
    final theme = Theme.of(context);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _secilenTarih,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: theme.colorScheme.primary, // Temanın Gece Mavisi rengi
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _secilenTarih) {
      setState(() {
        _secilenTarih = picked;
      });
    }
  }

  void _rotaOlustur() async {
    if (secilenIsIdleri.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen en az bir iş seçin!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    String formatliTarih =
        "${_secilenTarih.year}-${_secilenTarih.month.toString().padLeft(2, '0')}-${_secilenTarih.day.toString().padLeft(2, '0')}";

    List<String>? smsListesi = await _requestService.generateDailyRoute(
      secilenIsIdleri,
      formatliTarih,
      _secilenEkip,
    );

    setState(() => isLoading = false);

    if (smsListesi != null) {
      _simulasyonSonucunuGoster(smsListesi);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Rota oluşturulurken hata meydana geldi."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _simulasyonSonucunuGoster(List<String> smsListesi) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.sms,
                color: theme.colorScheme.secondary,
              ), // Turkuaz İkon
              const SizedBox(width: 10),
              const Text("SMS Simülasyonu"),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Aşağıdaki mesajlar müşterilere iletilmiş sayıldı:"),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: smsListesi.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          smsListesi[index],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              // Buton stili silindi, temanın varsayılan Turkuaz rengini alacak
              child: const Text("Tamamlandı"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String gosterilecekTarih =
        "${_secilenTarih.day.toString().padLeft(2, '0')}.${_secilenTarih.month.toString().padLeft(2, '0')}.${_secilenTarih.year}";

    return Scaffold(
      appBar: const GradientAppBar(title: 'Rota Oluştur'),
      body: Column(
        children: [
          // --- ÜST PANEL: TARİH VE EKİP SEÇİMİ ---
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Row(
              children: [
                // Tarih Seçici Buton
                Expanded(
                  child: InkWell(
                    onTap: () => _tarihSec(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                        ), // Gece mavisi hafif kenarlık
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            gosterilecekTarih,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Ekip Seçici Dropdown
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _secilenEkip,
                        isExpanded: true,
                        icon: Icon(
                          Icons.group,
                          color: theme.colorScheme.primary,
                        ),
                        items: _ekipler.map((String ekip) {
                          return DropdownMenuItem<String>(
                            value: ekip,
                            child: Text(
                              ekip,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? yeniDeger) {
                          if (yeniDeger != null) {
                            setState(() {
                              _secilenEkip = yeniDeger;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- ALT PANEL: BEKLEYEN İŞLER LİSTESİ ---
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : bekleyenIsler.isEmpty
                ? const Center(
                    child: Text(
                      "Rotaya eklenecek bekleyen iş bulunamadı.",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: bekleyenIsler.length,
                    itemBuilder: (context, index) {
                      var isItem = bekleyenIsler[index];
                      int id = isItem['id'] ?? 0;
                      String musteri =
                          isItem['musteriAdi'] ?? "Bilinmeyen Müşteri";
                      String adres = isItem['adres'] ?? "Adres Yok";
                      String cihaz = isItem['urun'] ?? "Cihaz Belirtilmemiş";

                      return Card(
                        // Gölge ve border özellikleri global temadan çekiliyor
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: CheckboxListTile(
                          activeColor: theme
                              .colorScheme
                              .secondary, // Seçilince Turkuaz olacak
                          title: Text(
                            "$musteri - $cihaz",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(adres),
                          value: secilenIsIdleri.contains(id),
                          onChanged: (bool? secildiMi) {
                            setState(() {
                              if (secildiMi == true) {
                                secilenIsIdleri.add(id);
                              } else {
                                secilenIsIdleri.remove(id);
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isLoading ? null : _rotaOlustur,
        label: const Text(
          "Seçili İşlerle Rota Oluştur",
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.map, color: Colors.white),
        backgroundColor:
            theme.colorScheme.secondary, // Temanın Turkuaz rengini alıyor
      ),
    );
  }
}
