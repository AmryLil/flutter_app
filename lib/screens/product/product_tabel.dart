// lib/screens/product_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_project/screens/product/product_detail_admin.dart';
import 'dart:async';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import 'product_detail.dart';
import 'product_form.dart';

class ProductTableScreen extends StatefulWidget {
  const ProductTableScreen({Key? key}) : super(key: key);

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductTableScreen> {
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

      if (p1.kodeBarang != p2.kodeBarang ||
          p1.namaBarang != p2.namaBarang ||
          p1.harga != p2.harga ||
          p1.imageUrl != p2.imageUrl) {
        return false;
      }
    }

    return true;
  }

  void _handleBuyProduct(Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Membeli ${product.namaBarang}'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildDataTable(List<Product> products) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          horizontalMargin: 20,
          headingRowHeight: 60,
          dataRowHeight: 70,
          headingRowColor: MaterialStateColor.resolveWith(
            (states) => Colors.indigo.shade50,
          ),
          columns: const [
            DataColumn(
              label: Text(
                'Nama Produk',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.indigo,
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Harga',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.indigo,
                  fontSize: 14,
                ),
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'Aksi',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.indigo,
                  fontSize: 14,
                ),
              ),
            ),
          ],
          rows:
              products.map((product) {
                return DataRow(
                  cells: [
                    DataCell(
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ProductDetailScreen(
                                    productId: product.kodeBarang,
                                  ),
                            ),
                          );
                        },
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(
                            product.namaBarang,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        'Rp ${product.harga.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProductDetailAdmin(
                                        productId: product.kodeBarang,
                                      ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.visibility_outlined,
                              size: 20,
                            ),
                            tooltip: 'Lihat Detail',
                            style: IconButton.styleFrom(
                              foregroundColor: Colors.blue,
                              backgroundColor: Colors.blue.shade50,
                              minimumSize: const Size(36, 36),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          ProductFormScreen(product: product),
                                ),
                              );
                              if (result == true) {
                                await _loadProducts();
                              }
                            },
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            tooltip: 'Edit',
                            style: IconButton.styleFrom(
                              foregroundColor: Colors.orange,
                              backgroundColor: Colors.orange.shade50,
                              minimumSize: const Size(36, 36),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () => _showDeleteConfirmation(product),
                            icon: const Icon(Icons.delete_outline, size: 20),
                            tooltip: 'Hapus',
                            style: IconButton.styleFrom(
                              foregroundColor: Colors.red,
                              backgroundColor: Colors.red.shade50,
                              minimumSize: const Size(36, 36),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Daftar Produk',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo.shade800,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.indigo.shade200,
                  Colors.indigo.shade100,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                ),
              )
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[400],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Terjadi kesalahan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_errorMessage',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadProducts,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : StreamBuilder<List<Product>>(
                stream: productStream,
                initialData: _products,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Tidak ada produk tersedia',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tambahkan produk baru dengan menekan tombol +',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final products = snapshot.data!;
                  return RefreshIndicator(
                    onRefresh: () async {
                      await _loadProducts();
                    },
                    color: Colors.indigo,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          _buildDataTable(products),
                          const SizedBox(height: 80), // Space for FAB
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProductFormScreen(),
              ),
            );
            if (result == true) {
              await _loadProducts();
            }
          },
          tooltip: 'Tambah Produk',
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showDeleteConfirmation(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red[400],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Hapus Produk',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus "${product.namaBarang}"?\n\nTindakan ini tidak dapat dibatalkan.',
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _apiService.deleteProduct(product.kodeBarang);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Produk berhasil dihapus'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  await _loadProducts();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus: $e'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
