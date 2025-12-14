class RequestModel {
  final int id;
  final String urunAdi;
  final String aciklama;
  final String durum;
  final String tarih;

  RequestModel({
    required this.id,
    required this.urunAdi,
    required this.aciklama,
    required this.durum,
    required this.tarih,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id'] ?? 0,
      // Hem büyük harfli hem küçük harfli ihtimali kontrol et
      urunAdi: json['urunAdi'] ?? json['UrunAdi'] ?? "Ürün Adı Yok",
      aciklama: json['aciklama'] ?? json['Aciklama'] ?? "",
      durum: json['durum'] ?? json['Durum'] ?? "Beklemede",
      tarih: json['tarih'] ?? json['Tarih'] ?? "",
    );
  }
}
