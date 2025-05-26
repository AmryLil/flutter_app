// lib/models/product_model.dart
class Product {
  final int id;
  final String kodeBarang;
  final String namaBarang;
  final String description;
  final int jumlah; // Added field for backend compatibility
  final double harga;
  final int diskon;
  final String? imageUrl;

  Product({
    required this.id,
    required this.kodeBarang,
    required this.namaBarang,
    required this.description,
    required this.jumlah, // Added required jumlah
    required this.harga,
    required this.diskon,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      kodeBarang: json['kode_barang'] ?? '',
      namaBarang: json['nama_barang'] ?? '',
      description: json['deskripsi'] ?? '',
      jumlah:
          int.tryParse(json['jumlah'].toString()) ?? 0, // Added jumlah parsing
      harga: double.tryParse(json['harga'].toString()) ?? 0.0,
      diskon: int.tryParse(json['diskon'].toString()) ?? 0,
      imageUrl: "", // Changed from 'imageUrl' to 'image_url'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode_barang': kodeBarang,
      'nama_barang': namaBarang,
      'deskripsi': description,
      'jumlah': jumlah, // Added jumlah
      'harga': harga,
      'diskon': diskon,
      'image_url': imageUrl, // Changed from 'imageUrl' to 'image_url'
    };
  }

  // Method specifically for creating new products (excludes id and created_at)
  Map<String, dynamic> toJsonForCreate() {
    return {
      'kode_barang': kodeBarang,
      'nama_barang': namaBarang,
      'jumlah': jumlah, // Added jumlah
      'harga': harga,
      'diskon': diskon,
      'image_url': imageUrl ?? '', // Changed from 'imageUrl' to 'image_url'
    };
  }

  // Method specifically for updating products (excludes created_at but includes id)
  Map<String, dynamic> toJsonForUpdate() {
    return {
      'kode_barang': kodeBarang,
      'nama_barang': namaBarang,
      'jumlah': jumlah, // Added jumlah
      'harga': harga,
      'diskon': diskon,
      'image_url': imageUrl ?? '', // Changed from 'imageUrl' to 'image_url'
    };
  }
}
