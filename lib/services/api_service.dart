// lib/services/api_service.dart
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';
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
  Future<Product> getProduct(String id) async {
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

  // Upload image file to server
  Future<String> uploadImageFile(File imageFile) async {
    try {
      print('Uploading image file: ${imageFile.path}');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload-image'),
      );

      // Add headers
      request.headers.addAll({'Accept': 'application/json'});

      // Determine content type based on file extension
      String fileName = imageFile.path.split('/').last.toLowerCase();
      MediaType contentType;

      if (fileName.endsWith('.png')) {
        contentType = MediaType('image', 'png');
      } else if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
        contentType = MediaType('image', 'jpeg');
      } else if (fileName.endsWith('.gif')) {
        contentType = MediaType('image', 'gif');
      } else {
        contentType = MediaType('image', 'jpeg'); // default
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // Make sure this matches your backend expectation
          imageFile.path,
          contentType: contentType,
        ),
      );

      print('Sending multipart request...');
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      var response = await http.Response.fromStream(streamedResponse);

      print('Upload status code: ${response.statusCode}');
      print('Upload response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        // Check different possible response structures that might match your backend
        String imageUrl =
            data['url'] ??
            data['data']?['url'] ??
            data['image_url'] ??
            data['data']?['image_url'] ??
            data['file_url'] ??
            '';
        if (imageUrl.isEmpty) {
          throw Exception(
            'No image URL returned from server. Response: ${response.body}',
          );
        }
        return imageUrl;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          'Failed to upload image: ${response.statusCode} - ${errorData['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Gagal mengupload gambar: ${e.toString()}');
    }
  }

  // Upload image bytes to server (for web)
  Future<String> uploadImageBytes(Uint8List imageBytes, String fileName) async {
    try {
      print('Uploading image bytes: $fileName');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload-image'),
      );

      // Add headers
      request.headers.addAll({'Accept': 'application/json'});

      // Determine content type based on file extension
      MediaType contentType;
      String lowerFileName = fileName.toLowerCase();

      if (lowerFileName.endsWith('.png')) {
        contentType = MediaType('image', 'png');
      } else if (lowerFileName.endsWith('.jpg') ||
          lowerFileName.endsWith('.jpeg')) {
        contentType = MediaType('image', 'jpeg');
      } else if (lowerFileName.endsWith('.gif')) {
        contentType = MediaType('image', 'gif');
      } else {
        contentType = MediaType('image', 'jpeg'); // default
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'image', // Make sure this matches your backend expectation
          imageBytes,
          filename: fileName,
          contentType: contentType,
        ),
      );

      print('Sending multipart request...');
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      var response = await http.Response.fromStream(streamedResponse);

      print('Upload status code: ${response.statusCode}');
      print('Upload response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        // Check different possible response structures that might match your backend
        String imageUrl =
            data['url'] ??
            data['data']?['url'] ??
            data['image_url'] ??
            data['data']?['image_url'] ??
            data['file_url'] ??
            '';
        if (imageUrl.isEmpty) {
          throw Exception(
            'No image URL returned from server. Response: ${response.body}',
          );
        }
        return imageUrl;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          'Failed to upload image: ${response.statusCode} - ${errorData['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Gagal mengupload gambar: ${e.toString()}');
    }
  }

  // Create product with image upload
  Future<Product> createProduct(
    Product product, {
    File? imageFile,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    try {
      print('Creating product: ${product.namaBarang}');

      // Jika ada file gambar, gunakan multipart/form-data
      if (imageFile != null || (imageBytes != null && fileName != null)) {
        return await _createProductWithMultipart(
          product,
          imageFile: imageFile,
          imageBytes: imageBytes,
          fileName: fileName,
        );
      } else {
        // Jika tidak ada file, gunakan JSON biasa
        return await _createProductWithJson(product);
      }
    } catch (e) {
      print('Error creating product: $e');
      throw Exception('Gagal membuat produk: ${e.toString()}');
    }
  }

  // Update product with image upload
  Future<Product> updateProduct(
    Product product, {
    File? imageFile,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    try {
      print('Updating product: ${product.namaBarang}');

      // Jika ada file gambar, gunakan multipart/form-data
      if (imageFile != null || (imageBytes != null && fileName != null)) {
        return await _updateProductWithMultipart(
          product,
          imageFile: imageFile,
          imageBytes: imageBytes,
          fileName: fileName,
        );
      } else {
        // Jika tidak ada file, gunakan JSON biasa
        return await _updateProductWithJson(product);
      }
    } catch (e) {
      print('Error updating product: $e');
      throw Exception('Gagal memperbarui produk: ${e.toString()}');
    }
  }

  Future<Product> _createProductWithMultipart(
    Product product, {
    File? imageFile,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/products'));

    // Add headers
    request.headers.addAll({'Accept': 'application/json'});

    // Add product data as fields
    request.fields['nama_barang'] = product.namaBarang;
    request.fields['deskripsi'] = product.description;
    request.fields['jumlah'] = product.jumlah.toString();
    request.fields['harga'] = product.harga.toString();
    request.fields['diskon'] = product.diskon.toString();

    // Add image file
    if (imageFile != null) {
      String fileName = imageFile.path.split('/').last.toLowerCase();
      MediaType contentType = _getMediaType(fileName);

      request.files.add(
        await http.MultipartFile.fromPath(
          'image_url',
          imageFile.path,
          contentType: contentType,
        ),
      );
    } else if (imageBytes != null && fileName != null) {
      MediaType contentType = _getMediaType(fileName);

      request.files.add(
        http.MultipartFile.fromBytes(
          'image_url',
          imageBytes,
          filename: fileName,
          contentType: contentType,
        ),
      );
    }

    print('Sending multipart create request...');
    var streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
    );
    var response = await http.Response.fromStream(streamedResponse);

    print('Create status code: ${response.statusCode}');
    print('Create response body: ${response.body}');

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Product.fromJson(data['data']);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(
        'Failed to create product: ${response.statusCode} - ${errorData['message'] ?? 'Unknown error'}',
      );
    }
  }

  Future<Product> _updateProductWithMultipart(
    Product product, {
    File? imageFile,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    var request = http.MultipartRequest(
      'POST', // Laravel biasanya pakai POST untuk multipart update
      Uri.parse('$baseUrl/products/${product.kodeBarang}'),
    );

    // Add headers
    request.headers.addAll({'Accept': 'application/json'});

    // Add method override untuk PUT (Laravel requirement)
    request.fields['_method'] = 'PUT';

    // Add product data as fields
    request.fields['kode_barang'] = product.kodeBarang;
    request.fields['nama_barang'] = product.namaBarang;
    request.fields['deskripsi'] = product.description;
    request.fields['jumlah'] = product.jumlah.toString();
    request.fields['harga'] = product.harga.toString();
    request.fields['diskon'] = product.diskon.toString();

    // Add image file
    if (imageFile != null) {
      String fileName = imageFile.path.split('/').last.toLowerCase();
      MediaType contentType = _getMediaType(fileName);

      request.files.add(
        await http.MultipartFile.fromPath(
          'image_url',
          imageFile.path,
          contentType: contentType,
        ),
      );
    } else if (imageBytes != null && fileName != null) {
      MediaType contentType = _getMediaType(fileName);

      request.files.add(
        http.MultipartFile.fromBytes(
          'image_url',
          imageBytes,
          filename: fileName,
          contentType: contentType,
        ),
      );
    }

    print('Sending multipart update request...');
    var streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
    );
    var response = await http.Response.fromStream(streamedResponse);

    print('Update status code: ${response.statusCode}');
    print('Update response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Product.fromJson(data['data']);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(
        'Failed to update product: ${response.statusCode} - ${errorData['message'] ?? 'Unknown error'}',
      );
    }
  }

  Future<Product> _createProductWithJson(Product product) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/products'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode(product.toJsonForCreate()),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Product.fromJson(data['data']);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(
        'Failed to create product: ${response.statusCode} - ${errorData['message'] ?? 'Unknown error'}',
      );
    }
  }

  // Private method: Update product dengan JSON (tanpa file)
  Future<Product> _updateProductWithJson(Product product) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl/products/${product.kodeBarang}'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode(product.toJsonForUpdate()),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Product.fromJson(data['data']);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(
        'Failed to update product: ${response.statusCode} - ${errorData['message'] ?? 'Unknown error'}',
      );
    }
  }

  // Helper method untuk menentukan MediaType
  MediaType _getMediaType(String fileName) {
    String lowerFileName = fileName.toLowerCase();

    if (lowerFileName.endsWith('.png')) {
      return MediaType('image', 'png');
    } else if (lowerFileName.endsWith('.jpg') ||
        lowerFileName.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    } else if (lowerFileName.endsWith('.gif')) {
      return MediaType('image', 'gif');
    } else {
      return MediaType('image', 'jpeg'); // default
    }
  }

  // Create product without image (for backward compatibility)
  Future<Product> createProductSimple(Product product) async {
    return createProduct(product);
  }

  // Update product without image (for backward compatibility)
  Future<Product> updateProductSimple(Product product) async {
    return updateProduct(product);
  }

  // Delete product
  Future<bool> deleteProduct(String id) async {
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
