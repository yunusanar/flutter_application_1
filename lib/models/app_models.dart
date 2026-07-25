// lib/models/app_models.dart

class Brand {
  final int id;
  final String brandName;

  Brand({required this.id, required this.brandName});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] ?? 0,
      brandName: json['brandName'] ?? json['BrandName'] ?? '',
    );
  }
}

class ProductItem {
  final int id;
  final String model;
  final int brandId;

  ProductItem({required this.id, required this.model, required this.brandId});

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: json['id'] ?? 0,
      model: json['model'] ?? json['Model'] ?? '',
      brandId: json['brandId'] ?? json['BrandId'] ?? 0,
    );
  }
}
