import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../services/request_service.dart';
import '../models/customer_product.dart';
import 'login_screen.dart';
import 'my_requests_screen.dart';

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

  // --- YENİ ÜRÜN VE KURULUM SİHİRBAZI ---
  void _yeniUrunEkleDialog() {
    int? secilenUrunId;
    TextEditingController seriNoController = TextEditingController();
    bool kurulumIstiyorum = true; // Varsayılan olarak kurulum isteği açık

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // Dialog içinde checkbox değişimi için StatefulBuilder şart
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.add_box, color: Color(0xFF1565C0)),
                  SizedBox(width: 10),
                  Text("Yeni Ürün Ekle"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Satın aldığınız ürünü seçin:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _productService.getCatalogProducts(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return LinearProgressIndicator();
                      return DropdownButtonFormField<int>(
                        isExpanded: true,
                        hint: Text("Ürün Modeli Seçiniz"),
                        items: snapshot.data!.map((urun) {
                          return DropdownMenuItem<int>(
                            value: urun['id'],
                            child: Text(
                              urun['ad'],
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setStateDialog(() => secilenUrunId = val);
                        },
                      );
                    },
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: seriNoController,
                    decoration: InputDecoration(
                      labelText: "Seri Numarası",
                      hintText: "Faturadaki SN no",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.qr_code),
                    ),
                  ),
                  SizedBox(height: 15),
                  // Kurulum İsteği Checkbox'ı
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: CheckboxListTile(
                      title: Text(
                        "Kurulum Talebi Oluştur",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      subtitle: Text(
                        "Teknisyen yönlendirilsin mi?",
                        style: TextStyle(fontSize: 12),
                      ),
                      value: kurulumIstiyorum,
                      activeColor: Color(0xFF1565C0),
                      onChanged: (val) {
                        setStateDialog(() => kurulumIstiyorum = val!);
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Vazgeç"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (secilenUrunId == null ||
                        seriNoController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Lütfen ürün ve seri no girin."),
                        ),
                      );
                      return;
                    }

                    // 1. Ürünü Müşteriye Kaydet
                    await _productService.addCustomerProduct(
                      widget.userId,
                      secilenUrunId!,
                      seriNoController.text,
                    );

                    // 2. Eğer istediyse Kurulum Talebi Aç
                    if (kurulumIstiyorum) {
                      // Burada "gercekUrunId" normalde veritabanından dönmeli ama biz simule ediyoruz.
                      // "0" gönderiyoruz, backend bunu yeni ürün olarak algılayabilir.
                      await _requestService.createServiceRequest(
                        widget.userId,
                        0,
                        "YENİ ÜRÜN KURULUM TALEBİ",
                      );
                    }

                    Navigator.pop(context);
                    setState(() {}); // Ekranı yenile

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          kurulumIstiyorum
                              ? "Ürün eklendi ve servis çağrıldı! 🚀"
                              : "Ürün envanterinize eklendi.",
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: Text("KAYDET"),
                ),
              ],
            );
          },
        );
      },
    );
  }
  // -------------------------------------

  void _arizaBildirPenceresi(
    BuildContext context,
    int gercekUrunId,
    String urunAdi,
  ) {
    TextEditingController aciklamaController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Arıza Bildir"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("$urunAdi için sorunu anlatın:"),
              SizedBox(height: 10),
              TextField(
                controller: aciklamaController,
                maxLines: 3,
                decoration: InputDecoration(hintText: "Sorun nedir?"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("İptal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () async {
                if (aciklamaController.text.isEmpty) return;
                bool sonuc = await _requestService.createServiceRequest(
                  widget.userId,
                  gercekUrunId,
                  aciklamaController.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(sonuc ? "Talep Gönderildi!" : "Hata oluştu."),
                    backgroundColor: sonuc ? Colors.green : Colors.red,
                  ),
                );
              },
              child: Text("GÖNDER"),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Merhaba,", style: TextStyle(fontSize: 12)),
            Text(
              widget.adSoyad,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyRequestsScreen(userId: widget.userId),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            ),
          ),
        ],
      ),

      // --- EKRANA EKLENEN YENİ BUTON (FAB) ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _yeniUrunEkleDialog,
        backgroundColor: Color(0xFF1565C0),
        icon: Icon(Icons.add_shopping_cart, color: Colors.white),
        label: Text("Yeni Ürün Ekle", style: TextStyle(color: Colors.white)),
      ),

      // --------------------------------------
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF1565C0),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
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
              future: _productService.getMyProducts(widget.userId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),
                        Text(
                          "Kayıtlı cihazınız yok.\n'Yeni Ürün Ekle' butonuyla başlayın.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var urun = snapshot.data![index];
                    return Card(
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                                child: Image.network(
                                  urun.resim,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey.shade200,
                                    child: Icon(Icons.broken_image),
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
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        urun.turu,
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      SizedBox(height: 5),
                                      Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade50,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          "Garanti: ${urun.garantiBitis}",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.orange.shade900,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                                  style: TextStyle(color: Colors.grey),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () => _arizaBildirPenceresi(
                                    context,
                                    urun.gercekUrunId,
                                    urun.urunBaslik,
                                  ),
                                  icon: Icon(Icons.build, size: 16),
                                  label: Text("Arıza Bildir"),
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
