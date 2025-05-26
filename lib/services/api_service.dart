// lib/services/api_service.dart
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

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
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting products: $e');
      throw Exception('Gagal memuat produk: ${e.toString()}');
    }
  }

  // Get product by ID
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
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting product: $e');
      throw Exception('Gagal memuat produk: ${e.toString()}');
    }
  }

  // Create product
  Future<Product> createProduct(Product product) async {
    try {
      print('Memulai request create ke $baseUrl/products');
      // Use toJsonForCreate() to exclude id and created_at
      final requestBody = product.toJsonForCreate();
      print('Request body: ${json.encode(requestBody)}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/products'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 15));

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Product.fromJson(data['data']);
      } else {
        final errorData = json.decode(response.body);
        print('Error details: $errorData');
        throw Exception(
          'Failed to create product: ${response.statusCode} - ${errorData['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('Error creating product: $e');
      throw Exception('Gagal membuat produk: ${e.toString()}');
    }
  }

  // Update product
  Future<Product> updateProduct(Product product) async {
    try {
      print('Memulai request update ke $baseUrl/products/${product.id}');
      // Use toJsonForUpdate() to exclude created_at but include proper fields
      final requestBody = product.toJsonForUpdate();
      print('Request body: ${json.encode(requestBody)}');

      final response = await http
          .put(
            Uri.parse('$baseUrl/products/${product.id}'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 15));

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Product.fromJson(data['data']);
      } else {
        final errorData = json.decode(response.body);
        print('Error details: $errorData');
        throw Exception(
          'Failed to update product: ${response.statusCode} - ${errorData['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('Error updating product: $e');
      throw Exception('Gagal memperbarui produk: ${e.toString()}');
    }
  }

  // Delete product
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
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting product: $e');
      throw Exception('Gagal menghapus produk: ${e.toString()}');
    }
  }
}
