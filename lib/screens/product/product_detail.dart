// lib/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import 'product_form.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({Key? key, required this.productId})
    : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<Product> _productFuture;

  @override
  void initState() {
    super.initState();
    _refreshProduct();
  }

  void _refreshProduct() {
    setState(() {
      _productFuture = _apiService.getProduct(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        actions: [
          FutureBuilder<Product>(
            future: _productFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                ProductFormScreen(product: snapshot.data!),
                      ),
                    );
                    if (result == true) {
                      _refreshProduct();
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Terjadi kesalahan:'),
                  Text('${snapshot.error}'),
                  ElevatedButton(
                    onPressed: _refreshProduct,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Produk tidak ditemukan'));
          } else {
            final product = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.namaBarang,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Kode: ${product.kodeBarang}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                'Rp ${product.harga.toStringAsFixed(2)}',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (product.diskon > 0) ...[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${product.diskon}% OFF',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (product.diskon > 0) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Harga setelah diskon: Rp ${(product.harga * (100 - product.diskon) / 100).toStringAsFixed(2)}',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          const Text(
                            'Deskripsi:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(product.description),
                          const SizedBox(height: 16),
                          Text(
                            'Dibuat pada: ${_formatDateTime(product.createdAt)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
