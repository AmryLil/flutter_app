// lib/models/product_model.dart
class Product {
  final String kodeBarang;
  final String namaBarang;
  final String description;
  final int jumlah; // Added field for backend compatibility
  final double harga;
  final int diskon;
  final String? imageUrl;

  Product({
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
      kodeBarang: json['kode_barang'] ?? '',
      namaBarang: json['nama_barang'] ?? '',
      description: json['deskripsi'] ?? '',
      jumlah:
          int.tryParse(json['jumlah'].toString()) ?? 0, // Added jumlah parsing
      harga: double.tryParse(json['harga'].toString()) ?? 0.0,
      diskon: int.tryParse(json['diskon'].toString()) ?? 0,
      imageUrl: json['image_url'] ?? null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
      'deskripsi': description, // Added missing description field
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
      'deskripsi': description, // Added missing description field
      'jumlah': jumlah, // Added jumlah
      'harga': harga,
      'diskon': diskon,
      'image_url': imageUrl ?? '', // Changed from 'imageUrl' to 'image_url'
    };
  }

  // Method copyWith untuk membuat copy dengan perubahan tertentu
  Product copyWith({
    String? kodeBarang,
    String? namaBarang,
    String? description,
    int? jumlah,
    double? harga,
    int? diskon,
    String? imageUrl,
  }) {
    return Product(
      kodeBarang: kodeBarang ?? this.kodeBarang,
      namaBarang: namaBarang ?? this.namaBarang,
      description: description ?? this.description,
      jumlah: jumlah ?? this.jumlah,
      harga: harga ?? this.harga,
      diskon: diskon ?? this.diskon,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  String toString() {
    return 'Product(kodeBarang: $kodeBarang, namaBarang: $namaBarang, description: $description, jumlah: $jumlah, harga: $harga, diskon: $diskon, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product &&
        other.kodeBarang == kodeBarang &&
        other.namaBarang == namaBarang &&
        other.description == description &&
        other.jumlah == jumlah &&
        other.harga == harga &&
        other.diskon == diskon &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode {
    return kodeBarang.hashCode ^
        namaBarang.hashCode ^
        description.hashCode ^
        jumlah.hashCode ^
        harga.hashCode ^
        diskon.hashCode ^
        imageUrl.hashCode;
  }
}
