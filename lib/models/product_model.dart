// lib/models/product_model.dart
class Product {
  final int id;
  final String kodeBarang;
  final String namaBarang;
  final String description;
  final double harga;
  final int diskon;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.kodeBarang,
    required this.namaBarang,
    required this.description,
    required this.harga,
    required this.diskon,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      kodeBarang: json['kode_barang'] ?? '',
      namaBarang: json['nama_barang'] ?? '',
      description: json['deskripsi'] ?? '',
      harga: double.tryParse(json['harga'].toString()) ?? 0.0,
      diskon: int.tryParse(json['diskon'].toString()) ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode_barang': kodeBarang,
      'nama_barang': namaBarang,
      'deskripsi': description,
      'harga': harga,
      'diskon': diskon,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
