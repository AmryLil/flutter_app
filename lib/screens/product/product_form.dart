// lib/screens/product_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({Key? key, this.product}) : super(key: key);

  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late TextEditingController _kodeBarangController;
  late TextEditingController _namaBarangController;
  late TextEditingController _descriptionController;
  late TextEditingController _jumlahController; // Added jumlah controller
  late TextEditingController _hargaController;
  late TextEditingController _diskonController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _kodeBarangController = TextEditingController(
      text: widget.product?.kodeBarang ?? '',
    );
    _namaBarangController = TextEditingController(
      text: widget.product?.namaBarang ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _jumlahController = TextEditingController(
      text: widget.product != null ? widget.product!.jumlah.toString() : '0',
    );
    _hargaController = TextEditingController(
      text: widget.product != null ? widget.product!.harga.toString() : '',
    );
    _diskonController = TextEditingController(
      text: widget.product != null ? widget.product!.diskon.toString() : '0',
    );
  }

  @override
  void dispose() {
    _kodeBarangController.dispose();
    _namaBarangController.dispose();
    _descriptionController.dispose();
    _jumlahController.dispose(); // Added dispose for jumlah controller
    _hargaController.dispose();
    _diskonController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final kodeBarang = _kodeBarangController.text;
      final namaBarang = _namaBarangController.text;
      final description = _descriptionController.text;
      final jumlah = int.parse(_jumlahController.text); // Added jumlah parsing
      final harga = double.parse(_hargaController.text);
      final diskon = int.parse(_diskonController.text);

      if (widget.product == null) {
        // Creating a new product
        final newProduct = Product(
          id: 0, // Temporary ID, will be replaced by the API
          kodeBarang: kodeBarang,
          namaBarang: namaBarang,
          description: description,
          jumlah: jumlah, // Added jumlah
          harga: harga,
          diskon: diskon,
          imageUrl: "", // Empty string as requested
        );

        await _apiService.createProduct(newProduct);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk berhasil dibuat')),
          );
          Navigator.pop(context, true); // Return true to trigger refresh
        }
      } else {
        // Updating existing product
        final updatedProduct = Product(
          id: widget.product!.id,
          kodeBarang: kodeBarang,
          namaBarang: namaBarang,
          description: description,
          jumlah: jumlah, // Added jumlah
          harga: harga,
          diskon: diskon,
          imageUrl: "", // Preserve existing imageUrl or use empty string
        );

        await _apiService.updateProduct(updatedProduct);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk berhasil diperbarui')),
          );
          Navigator.pop(context, true); // Return true to trigger refresh
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreating = widget.product == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isCreating ? 'Tambah Produk Baru' : 'Edit Produk'),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _kodeBarangController,
                        decoration: const InputDecoration(
                          labelText: 'Kode Barang',
                          border: OutlineInputBorder(),
                          hintText: 'Masukkan kode barang',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kode barang wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _namaBarangController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Barang',
                          border: OutlineInputBorder(),
                          hintText: 'Masukkan nama barang',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama barang wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          border: OutlineInputBorder(),
                          hintText: 'Masukkan deskripsi barang',
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Deskripsi wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Added Jumlah field
                      TextFormField(
                        controller: _jumlahController,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah Stok',
                          border: OutlineInputBorder(),
                          hintText: 'Masukkan jumlah stok barang',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jumlah stok wajib diisi';
                          }
                          try {
                            final jumlah = int.parse(value);
                            if (jumlah < 0) {
                              return 'Jumlah stok tidak boleh negatif';
                            }
                          } catch (e) {
                            return 'Format jumlah tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _hargaController,
                        decoration: const InputDecoration(
                          labelText: 'Harga',
                          border: OutlineInputBorder(),
                          prefixText: 'Rp ',
                          hintText: 'Masukkan harga barang',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harga wajib diisi';
                          }
                          try {
                            final price = double.parse(value);
                            if (price <= 0) {
                              return 'Harga harus lebih dari 0';
                            }
                          } catch (e) {
                            return 'Format harga tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _diskonController,
                        decoration: const InputDecoration(
                          labelText: 'Diskon (%)',
                          border: OutlineInputBorder(),
                          hintText: 'Masukkan persentase diskon (0-100)',
                          suffixText: '%',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Diskon wajib diisi (masukkan 0 jika tidak ada diskon)';
                          }
                          try {
                            final diskon = int.parse(value);
                            if (diskon < 0 || diskon > 100) {
                              return 'Diskon harus antara 0-100%';
                            }
                          } catch (e) {
                            return 'Format diskon tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _saveProduct,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          isCreating ? 'Tambah Produk' : 'Simpan Perubahan',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
