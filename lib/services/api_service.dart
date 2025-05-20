import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  // Replace with your API base URL - GUNAKAN URL API ANDA YANG BENAR DI SINI
  final String baseUrl =
      'http://127.0.0.1:8000/api'; // Untuk emulator Android ke localhost

  // Get all products
  Future<List<Product>> getProducts() async {
    try {
      print('Memulai request ke $baseUrl/products');
      final response = await http
          .get(
            Uri.parse('$baseUrl/products'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              // Add your auth token here if needed
              // 'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> productsJson = data['data'];
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load products: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error getting products: $e');
      throw Exception('Gagal memuat produk: ${e.toString()}');
    }
  }

  // Get a specific product by ID
  Future<Product> getProduct(int id) async {
    try {
      print('Memulai request ke $baseUrl/products/$id');
      final response = await http
          .get(
            Uri.parse('$baseUrl/products/$id'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Product.fromJson(data['data']);
      } else {
        throw Exception(
          'Failed to load product: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error getting product: $e');
      throw Exception('Gagal memuat produk: ${e.toString()}');
    }
  }

  // Create a new product
  Future<Product> createProduct(Product product) async {
    try {
      print('Memulai request create ke $baseUrl/products');
      print(
        'Request body: ${json.encode({'name': product.name, 'description': product.description, 'price': product.price})}',
      );

      final response = await http
          .post(
            Uri.parse('$baseUrl/products'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'name': product.name,
              'description': product.description,
              'price': product.price,
            }),
          )
          .timeout(const Duration(seconds: 15));

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Product.fromJson(data['data']);
      } else {
        throw Exception(
          'Failed to create product: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error creating product: $e');
      throw Exception('Gagal membuat produk: ${e.toString()}');
    }
  }

  // Update an existing product
  Future<Product> updateProduct(Product product) async {
    try {
      print('Memulai request update ke $baseUrl/products/${product.id}');
      print(
        'Request body: ${json.encode({'name': product.name, 'description': product.description, 'price': product.price})}',
      );

      final response = await http
          .put(
            Uri.parse('$baseUrl/products/${product.id}'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'name': product.name,
              'description': product.description,
              'price': product.price,
            }),
          )
          .timeout(const Duration(seconds: 15));

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Product.fromJson(data['data']);
      } else {
        throw Exception(
          'Failed to update product: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error updating product: $e');
      throw Exception('Gagal memperbarui produk: ${e.toString()}');
    }
  }

  // Delete a product
  Future<bool> deleteProduct(int id) async {
    try {
      print('Memulai request delete ke $baseUrl/products/$id');
      final response = await http
          .delete(
            Uri.parse('$baseUrl/products/$id'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          'Failed to delete product: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error deleting product: $e');
      throw Exception('Gagal menghapus produk: ${e.toString()}');
    }
  }
}
