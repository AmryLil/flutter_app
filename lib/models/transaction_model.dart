import 'package:flutter_project/models/product_model.dart';

class Transaction {
  final int id;
  final int productId;
  final int jumlah;
  final double hargaSatuan;
  final int diskon;
  final double totalBeli;
  final double totalBayar;

  final Product? product;

  Transaction({
    required this.id,
    required this.productId,
    required this.jumlah,
    required this.hargaSatuan,
    required this.diskon,
    required this.totalBeli,
    required this.totalBayar,

    this.product,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      productId: json['product_id'],
      jumlah: json['jumlah'],
      hargaSatuan: double.tryParse(json['harga_satuan'].toString()) ?? 0.0,
      diskon: json['diskon'] ?? 0,
      totalBeli: double.tryParse(json['total_beli'].toString()) ?? 0.0,
      totalBayar: double.tryParse(json['total_bayar'].toString()) ?? 0.0,

      product:
          json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'jumlah': jumlah,
      'harga_satuan': hargaSatuan,
      'diskon': diskon,
      'total_beli': totalBeli,
      'total_bayar': totalBayar,
    };
  }
}
