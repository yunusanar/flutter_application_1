import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/auth_service.dart';

class AddDeviceScreen extends StatefulWidget {
  final int userId;
  const AddDeviceScreen({super.key, required this.userId});

  @override
  _AddDeviceScreenState createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _serialController = TextEditingController();

  List<Brand> _brands = [];
  List<ProductItem> _allProducts = [];
  List<ProductItem> _filteredProducts = [];

  Brand? _selectedBrand;
  ProductItem? _selectedProduct;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // API'den Marka ve Tüm Ürünleri Çekiyoruz
  void _loadInitialData() async {
    try {
      final brands = await _authService.fetchBrands();
      final products = await _authService.fetchProducts();
      setState(() {
        _brands = brands;
        _allProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Veriler yüklenemedi: $e")));
    }
  }

  void _handleSave() async {
    if (_selectedProduct == null || _serialController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun!")),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Backend'deki yeni metodumuzu çağırıyoruz
    bool success = await _authService.saveCustomerProduct(
      widget.userId,
      _selectedProduct!.id,
      _serialController.text,
    );

    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cihaz eklendi ve Kurulum Talebi oluşturuldu!"),
        ),
      );
      Navigator.pop(
        context,
        true,
      ); // Geri dön ve listeyi yenilemesi için sinyal ver
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kayıt sırasında bir hata oluştu.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Cihaz Kaydı")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // 1. MARKA SEÇİMİ
                  DropdownButtonFormField<Brand>(
                    decoration: const InputDecoration(
                      labelText: "Marka Seçin",
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedBrand,
                    items: _brands
                        .map(
                          (b) => DropdownMenuItem(
                            value: b,
                            child: Text(b.brandName),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedBrand = val;
                        _selectedProduct =
                            null; // Marka değişince model sıfırlanır
                        // Ürünleri markaya göre filtrele
                        _filteredProducts = _allProducts
                            .where((p) => p.brandId == val?.id)
                            .toList();
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  // 2. MODEL SEÇİMİ (Filtrelenmiş listeden)
                  DropdownButtonFormField<ProductItem>(
                    decoration: const InputDecoration(
                      labelText: "Model Seçin",
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedProduct,
                    items: _filteredProducts
                        .map(
                          (p) =>
                              DropdownMenuItem(value: p, child: Text(p.model)),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedProduct = val),
                    disabledHint: const Text("Önce marka seçin"),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _serialController,
                    decoration: const InputDecoration(
                      labelText: "Seri Numarası",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _handleSave,
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("KAYDET VE KURULUM İSTE"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
