import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../services/request_service.dart';
import '../models/customer_product.dart';
import 'login_screen.dart';
import 'my_requests_screen.dart';
import 'add_device_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  final String adSoyad;

  const HomeScreen({super.key, required this.userId, required this.adSoyad});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  final RequestService _requestService = RequestService();

  late Future<List<CustomerProduct>> _myProductsFuture;

  @override
  void initState() {
    super.initState();
    _yenile();
  }

  void _yenile() {
    setState(() {
      _myProductsFuture = _productService.getMyProducts(widget.userId);
    });
  }

  void _arizaBildirPenceresi(
    BuildContext context,
    int productId,
    String urunAdi,
  ) {
    TextEditingController aciklamaController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Arıza Bildir"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$urunAdi için sorunu anlatın:",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: aciklamaController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Sorun nedir? (Örn: Soğutmuyor)",
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors
                    .redAccent, // Uyarı/Hata aksiyonu olduğu için kırmızı bırakıldı
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (aciklamaController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Lütfen bir açıklama yazın.")),
                  );
                  return;
                }

                bool sonuc = await _requestService.createServiceRequest(
                  widget.userId,
                  productId,
                  aciklamaController.text,
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      sonuc
                          ? "Talep Başarıyla Gönderildi!"
                          : "Hata: Talep iletilemedi.",
                    ),
                    backgroundColor: sonuc ? Colors.green : Colors.red,
                  ),
                );

                if (sonuc) _yenile();
              },
              child: const Text("GÖNDER"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Temamızdaki renkleri alıyoruz (Gece mavisi ve Turkuaz)
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Merhaba,", style: TextStyle(fontSize: 12)),
            Text(
              widget.adSoyad,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // Eski sabit renkler silindi, artık main.dart'tan besleniyor
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0B132B), Color(0xFF1C2541), Color(0xFF3A506B)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyRequestsScreen(userId: widget.userId),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final sonuc = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddDeviceScreen(userId: widget.userId),
            ),
          );

          if (sonuc == true) {
            _yenile();
          }
        },
        label: const Text(
          "Yeni Cihaz Ekle",
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor:
            theme.colorScheme.secondary, // Temanın Canlı Turkuaz Rengi
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary, // Temanın Gece Mavisi Rengi
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.home_filled, color: Colors.white70),
                SizedBox(width: 10),
                Text(
                  "Cihazlarım",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<CustomerProduct>>(
              future: _myProductsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("Henüz kayıtlı bir cihazınız bulunmuyor."),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var urun = snapshot.data![index];
                    return Card(
                      // Özel margin ve shape ayarları korundu ancak gölge temadan geliyor
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                ),
                                child: Image.network(
                                  urun.resim,
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(
                                    width: 110,
                                    height: 110,
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.kitchen,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        urun.urunBaslik,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        urun.turu,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors
                                              .orange
                                              .shade50, // Garanti uyarısı için mantıklı bir renk
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          "Garanti: ${urun.garantiBitis}",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.orange.shade900,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "SN: ${urun.seriNo}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.redAccent, // Semantik Hata Rengi
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  onPressed: () {
                                    _arizaBildirPenceresi(
                                      context,
                                      urun.gercekUrunId,
                                      urun.urunBaslik,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.report_problem,
                                    size: 16,
                                  ),
                                  label: const Text("Arıza Bildir"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
