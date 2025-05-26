// lib/screens/product_detail_screen.dart (Updated with dynamic discount logic)
import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../models/transaction_model.dart';
import '../../services/api_service.dart';
import '../../services/transaction_service.dart';
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
  final TransactionService _transactionService = TransactionService();
  late Future<Product> _productFuture;
  int _quantity = 1;
  bool _isProcessing = false;

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

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  // Calculate dynamic discount based on total price
  double _calculateDiscount(double totalPrice) {
    if (totalPrice > 500000) {
      return 10.0; // 10% discount for total > 500K
    } else if (totalPrice > 100000) {
      return 5.0; // 5% discount for total > 100K
    }
    return 0.0; // No discount
  }

  void _showTransactionModal(Product product) {
    final double hargaSatuan = product.harga;
    final double totalBeli = hargaSatuan * _quantity;

    // Calculate dynamic discount based on total price
    final double diskonPersen = _calculateDiscount(totalBeli);
    final double potonganDiskon = totalBeli * diskonPersen / 100;
    final double totalBayar = totalBeli - potonganDiskon;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Konfirmasi Pembelian',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed:
                              _isProcessing
                                  ? null
                                  : () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Info
                          Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child:
                                    product.imageUrl != null
                                        ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            product.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return const Icon(
                                                Icons.image_not_supported,
                                                size: 40,
                                                color: Colors.grey,
                                              );
                                            },
                                          ),
                                        )
                                        : const Icon(
                                          Icons.shopping_bag,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.namaBarang,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Kode: ${product.kodeBarang}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rp ${hargaSatuan.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Quantity
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Jumlah:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '$_quantity',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Price breakdown
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Harga satuan:'),
                                    Text(
                                      'Rp ${hargaSatuan.toStringAsFixed(0)}',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Jumlah:'),
                                    Text('$_quantity'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Total beli:'),
                                    Text('Rp ${totalBeli.toStringAsFixed(0)}'),
                                  ],
                                ),
                                if (diskonPersen > 0) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Diskon:'),
                                      Text(
                                        '${diskonPersen.toStringAsFixed(0)}%',
                                        style: const TextStyle(
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Potongan diskon:'),
                                      Text(
                                        '- Rp ${potonganDiskon.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total bayar:',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Rp ${totalBayar.toStringAsFixed(0)}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge?.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Show discount info if applicable
                          if (diskonPersen > 0) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.celebration,
                                    color: Colors.green[600],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      diskonPersen == 10
                                          ? 'Selamat! Anda mendapat diskon 10% karena pembelian di atas Rp 500.000'
                                          : 'Selamat! Anda mendapat diskon 5% karena pembelian di atas Rp 100.000',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // Bottom buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                _isProcessing
                                    ? null
                                    : () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed:
                                _isProcessing
                                    ? null
                                    : () => _processTransaction(
                                      product,
                                      hargaSatuan,
                                      totalBeli,
                                      totalBayar,
                                      diskonPersen,
                                      setModalState,
                                    ),
                            child:
                                _isProcessing
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : const Text('Konfirmasi Beli'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _processTransaction(
    Product product,
    double hargaSatuan,
    double totalBeli,
    double totalBayar,
    double diskonPersen,
    StateSetter setModalState,
  ) async {
    setModalState(() {
      _isProcessing = true;
    });

    try {
      // Create transaction object with dynamic discount
      final transaction = Transaction(
        id: 0, // Will be set by API
        productId: product.id,
        jumlah: _quantity,
        hargaSatuan: hargaSatuan,
        diskon: diskonPersen.toInt(), // Use calculated discount
        totalBeli: totalBeli,
        totalBayar: totalBayar,
      );

      // Call API
      final createdTransaction = await _transactionService.createTransaction(
        transaction,
      );

      // Close modal
      Navigator.pop(context);

      // Show success dialog
      _showSuccessDialog(product, createdTransaction);
    } catch (e) {
      // Show error dialog
      _showErrorDialog(e.toString());
    } finally {
      setModalState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSuccessDialog(Product product, Transaction transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          title: const Text('Transaksi Berhasil!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID Transaksi: #${transaction.id}'),
              const SizedBox(height: 4),
              Text('Produk: ${product.namaBarang}'),
              Text('Jumlah: ${transaction.jumlah}'),
              if (transaction.diskon > 0)
                Text('Diskon: ${transaction.diskon.toStringAsFixed(0)}%'),
              Text('Total: Rp ${transaction.totalBayar.toStringAsFixed(0)}'),
              const SizedBox(height: 8),
              const Text(
                'Terima kasih atas pembelian Anda!',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.error_outline, color: Colors.red, size: 48),
          title: const Text('Transaksi Gagal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Terjadi kesalahan saat memproses transaksi:'),
              const SizedBox(height: 8),
              Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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
            final double totalPrice = product.harga * _quantity;
            final double diskonPersen = _calculateDiscount(totalPrice);
            final double finalPrice = totalPrice * (100 - diskonPersen) / 100;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image
                        Container(
                          width: double.infinity,
                          height: 250,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              product.imageUrl != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      product.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return const Icon(
                                          Icons.image_not_supported,
                                          size: 80,
                                          color: Colors.grey,
                                        );
                                      },
                                    ),
                                  )
                                  : const Icon(
                                    Icons.shopping_bag,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                        ),
                        const SizedBox(height: 16),

                        // Product Info Card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.namaBarang,
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Kode: ${product.kodeBarang}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 16),

                                // Price section
                                Text(
                                  'Rp ${product.harga.toStringAsFixed(0)}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 16),
                                const Text(
                                  'Deskripsi:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(product.description),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),

                        // Discount info banner
                        if (diskonPersen > 0) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green[400]!,
                                  Colors.green[600]!,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.local_offer,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Diskon ${diskonPersen.toStringAsFixed(0)}% Aktif!',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        diskonPersen == 10
                                            ? 'Pembelian di atas Rp 500.000'
                                            : 'Pembelian di atas Rp 100.000',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Bottom section with quantity and buy button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Price preview with discount
                      if (diskonPersen > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total sebelum diskon:'),
                            Text(
                              'Rp ${totalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total setelah diskon ${diskonPersen.toStringAsFixed(0)}%:',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Rp ${finalPrice.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: Colors.green[600],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],

                      Row(
                        children: [
                          // Quantity selector
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: _decrementQuantity,
                                  icon: const Icon(Icons.remove),
                                  padding: const EdgeInsets.all(8),
                                  constraints: const BoxConstraints(
                                    minWidth: 40,
                                    minHeight: 40,
                                  ),
                                ),
                                Container(
                                  width: 50,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$_quantity',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _incrementQuantity,
                                  icon: const Icon(Icons.add),
                                  padding: const EdgeInsets.all(8),
                                  constraints: const BoxConstraints(
                                    minWidth: 40,
                                    minHeight: 40,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Buy button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showTransactionModal(product),
                              icon: const Icon(Icons.shopping_cart),
                              label: Text(
                                'Beli - Rp ${(diskonPersen > 0 ? finalPrice : totalPrice).toStringAsFixed(0)}',
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor:
                                    diskonPersen > 0 ? Colors.green[600] : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
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
