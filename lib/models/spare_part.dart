class SparePart {
  final int id;
  final String parcaAdi;
  final double fiyat;
  final int stok;

  SparePart({
    required this.id,
    required this.parcaAdi,
    required this.fiyat,
    required this.stok,
  });

  factory SparePart.fromJson(Map<String, dynamic> json) {
    return SparePart(
      id: json['id'],
      parcaAdi: json['parcaAdi'],
      fiyat: (json['fiyat'] as num).toDouble(), // Decimal'i double'a çevir
      stok: json['stok'],
    );
  }
}
