// lib/screens/product_list_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import 'product_detail.dart';
import 'product_form.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ApiService _apiService = ApiService();
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Timer untuk polling data secara berkala
  Timer? _refreshTimer;

  // StreamController untuk update realtime
  final StreamController<List<Product>> _productStreamController =
      StreamController<List<Product>>.broadcast();
  Stream<List<Product>> get productStream => _productStreamController.stream;

  @override
  void initState() {
    super.initState();
    _loadProducts();

    // Setup timer untuk polling data setiap 5 detik
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _refreshProductsBackground();
    });
  }

  @override
  void dispose() {
    // Membersihkan timer dan stream controller saat widget di-dispose
    _refreshTimer?.cancel();
    _productStreamController.close();
    super.dispose();
  }

  // Mendapatkan data produk dan memperbarui stream
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _apiService.getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });

      // Update stream dengan data terbaru
      _productStreamController.add(products);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Refresh data di background tanpa menampilkan loading indicator
  Future<void> _refreshProductsBackground() async {
    try {
      final products = await _apiService.getProducts();

      // Hanya update jika data berubah
      if (_products.length != products.length ||
          !_compareProductLists(_products, products)) {
        setState(() {
          _products = products;
        });

        // Update stream dengan data terbaru
        _productStreamController.add(products);
      }
    } catch (e) {
      // Handle error silently in background updates
      debugPrint('Background refresh error: $e');
    }
  }

  // Membandingkan dua list produk
  bool _compareProductLists(List<Product> list1, List<Product> list2) {
    if (list1.length != list2.length) return false;

    for (int i = 0; i < list1.length; i++) {
      Product p1 = list1[i];
      Product p2 = list2[i];

      if (p1.id != p2.id ||
          p1.namaBarang != p2.namaBarang ||
          p1.harga != p2.harga ||
          p1.diskon != p2.diskon) {
        return false;
      }
    }

    return true;
  }

  double _getDiscountedPrice(Product product) {
    if (product.diskon > 0) {
      return product.harga * (100 - product.diskon) / 100;
    }
    return product.harga;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Produk')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Terjadi kesalahan:'),
                    Text('$_errorMessage'),
                    ElevatedButton(
                      onPressed: _loadProducts,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
              : StreamBuilder<List<Product>>(
                // Menggunakan stream untuk update realtime
                stream: productStream,
                initialData: _products,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada produk tersedia'),
                    );
                  }

                  final products = snapshot.data!;
                  return RefreshIndicator(
                    onRefresh: () async {
                      await _loadProducts();
                    },
                    child: ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final discountedPrice = _getDiscountedPrice(product);

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(product.namaBarang),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kode: ${product.kodeBarang}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    if (product.diskon > 0) ...[
                                      Text(
                                        'Rp ${product.harga.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Rp ${discountedPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          '${product.diskon}%',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ] else ...[
                                      Text(
                                        'Rp ${product.harga.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ProductFormScreen(
                                              product: product,
                                            ),
                                      ),
                                    );
                                    if (result == true) {
                                      await _loadProducts();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    _showDeleteConfirmation(product);
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProductDetailScreen(
                                        productId: product.id,
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductFormScreen()),
          );
          if (result == true) {
            await _loadProducts();
          }
        },
        tooltip: 'Tambah Produk',
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.amber),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showDeleteConfirmation(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Produk'),
          content: Text(
            'Apakah Anda yakin ingin menghapus "${product.namaBarang}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _apiService.deleteProduct(product.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Produk berhasil dihapus')),
                  );
                  await _loadProducts();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus: $e')),
                  );
                }
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
