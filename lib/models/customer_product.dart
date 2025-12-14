class CustomerProduct {
  final int id;
  final int gercekUrunId; // <--- YENİ ALAN
  final String urunBaslik;
  final String turu;
  final String resim;
  final String seriNo;
  final String garantiBitis;

  CustomerProduct({
    required this.id,
    required this.gercekUrunId, // <--- Zorunlu yapın
    required this.urunBaslik,
    required this.turu,
    required this.resim,
    required this.seriNo,
    required this.garantiBitis,
  });

  factory CustomerProduct.fromJson(Map<String, dynamic> json) {
    return CustomerProduct(
      id: json['id'] ?? 0,
      gercekUrunId: json['gercekUrunId'] ?? 0, // <--- JSON'dan okuyun
      urunBaslik: json['urunBaslik'] ?? "İsimsiz Ürün",
      turu: json['turu'] ?? "Genel",
      resim: json['resim'] ?? "",
      seriNo: json['seriNo'] ?? "-",
      garantiBitis: json['garantiBitis'] ?? "Belirsiz",
    );
  }
}
