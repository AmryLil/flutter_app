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
          p1.imageUrl != p2.imageUrl) {
        return false;
      }
    }

    return true;
  }

  // Widget untuk menampilkan gambar produk dengan error handling
  Widget _buildProductImage(String? imageUrl, String productName) {
    if (imageUrl == null || imageUrl.isEmpty) {
      // Tampilkan placeholder jika tidak ada gambar
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.image_not_supported,
          size: 32,
          color: Colors.grey,
        ),
      );
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 60,
              height: 60,
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.broken_image,
                size: 32,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleBuyProduct(Product product) {
    // Handle buy product logic here
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Membeli ${product.namaBarang}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Produk'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Terjadi kesalahan:'),
                    Text('$_errorMessage'),
                    const SizedBox(height: 16),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Tidak ada produk tersedia'),
                        ],
                      ),
                    );
                  }

                  final products = snapshot.data!;
                  return RefreshIndicator(
                    onRefresh: () async {
                      await _loadProducts();
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio:
                                0.75, // Adjusted since no discount badge
                          ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
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
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header dengan gambar dan menu
                                  Row(
                                    children: [
                                      // Gambar produk
                                      _buildProductImage(
                                        product.imageUrl,
                                        product.namaBarang,
                                      ),
                                      const Spacer(),
                                      // Menu popup
                                      PopupMenuButton<String>(
                                        onSelected: (value) async {
                                          if (value == 'edit') {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        ProductFormScreen(
                                                          product: product,
                                                        ),
                                              ),
                                            );
                                            if (result == true) {
                                              await _loadProducts();
                                            }
                                          } else if (value == 'delete') {
                                            _showDeleteConfirmation(product);
                                          }
                                        },
                                        itemBuilder:
                                            (BuildContext context) => [
                                              const PopupMenuItem<String>(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit, size: 16),
                                                    SizedBox(width: 8),
                                                    Text('Edit'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.delete,
                                                      size: 16,
                                                      color: Colors.red,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Hapus',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Nama produk
                                  Text(
                                    product.namaBarang,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),

                                  // Kode produk
                                  Text(
                                    'Kode: ${product.kodeBarang}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  const Spacer(),

                                  // Harga
                                  Text(
                                    'Rp ${product.harga.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Tombol beli
                                ],
                              ),
                            ),
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
        child: const Icon(Icons.add, color: Colors.white),
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
