// lib/screens/product_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../models/product_model.dart';
import '../../services/api_service.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({Key? key, this.product}) : super(key: key);

  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _kodeBarangController;
  late TextEditingController _namaBarangController;
  late TextEditingController _descriptionController;
  late TextEditingController _jumlahController;
  late TextEditingController _hargaController;
  late TextEditingController _diskonController;
  late TextEditingController _imageUrlController;

  File? _selectedImage;
  Uint8List? _webImageBytes; // For web platform
  String? _selectedImageName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _kodeBarangController = TextEditingController(
      text: widget.product?.kodeBarang ?? '',
    );
    _namaBarangController = TextEditingController(
      text: widget.product?.namaBarang ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _jumlahController = TextEditingController(
      text: widget.product != null ? widget.product!.jumlah.toString() : '0',
    );
    _hargaController = TextEditingController(
      text: widget.product != null ? widget.product!.harga.toString() : '',
    );
    _diskonController = TextEditingController(
      text: widget.product != null ? widget.product!.diskon.toString() : '0',
    );
    _imageUrlController = TextEditingController(
      text: widget.product?.imageUrl ?? '',
    );
  }

  @override
  void dispose() {
    _kodeBarangController.dispose();
    _namaBarangController.dispose();
    _descriptionController.dispose();
    _jumlahController.dispose();
    _hargaController.dispose();
    _diskonController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        if (kIsWeb) {
          // For web platform
          final bytes = await image.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
            _selectedImageName = image.name;
            _selectedImage = null;
            _imageUrlController.text = image.name; // Set name untuk display
          });
        } else {
          // For mobile platforms
          setState(() {
            _selectedImage = File(image.path);
            _webImageBytes = null;
            _selectedImageName = image.name;
            _imageUrlController.text = image.path;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        if (kIsWeb) {
          // For web platform
          final bytes = await image.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
            _selectedImageName = image.name;
            _selectedImage = null;
            _imageUrlController.text = image.name;
          });
        } else {
          // For mobile platforms
          setState(() {
            _selectedImage = File(image.path);
            _webImageBytes = null;
            _selectedImageName = image.name;
            _imageUrlController.text = image.path;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error taking photo: $e')));
      }
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Gambar'),
          content: const Text('Pilih sumber gambar produk'),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Kamera'),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
              icon: const Icon(Icons.photo_library),
              label: const Text('Galeri'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk upload gambar ke server (implementasi tergantung API)
  Future<String> _uploadImage() async {
    try {
      if (kIsWeb && _webImageBytes != null) {
        // TODO: Implementasi upload untuk web dengan bytes
        // Contoh: return await _apiService.uploadImageBytes(_webImageBytes!, _selectedImageName!);

        // Untuk sementara, return nama file
        return _selectedImageName ?? 'uploaded_image.jpg';
      } else if (!kIsWeb && _selectedImage != null) {
        // TODO: Implementasi upload untuk mobile dengan file
        // Contoh: return await _apiService.uploadImageFile(_selectedImage!);

        // Untuk sementara, return path
        return _selectedImage!.path;
      }

      return '';
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final kodeBarang = _kodeBarangController.text;
      final namaBarang = _namaBarangController.text;
      final description = _descriptionController.text;
      final jumlah = int.parse(_jumlahController.text);
      final harga = double.parse(_hargaController.text);
      final diskon = int.parse(_diskonController.text);

      // Use existing imageUrl if no new image is selected and we're updating
      String imageUrl = '';
      if (widget.product != null &&
          _selectedImage == null &&
          _webImageBytes == null) {
        imageUrl = widget.product!.imageUrl ?? '';
      } else if (_imageUrlController.text.isNotEmpty &&
          Uri.tryParse(_imageUrlController.text)?.isAbsolute == true &&
          _selectedImage == null &&
          _webImageBytes == null) {
        // Use manually entered URL if it's valid and no file is selected
        imageUrl = _imageUrlController.text;
      }

      if (widget.product == null) {
        // Creating a new product
        final newProduct = Product(
          kodeBarang: kodeBarang,
          namaBarang: namaBarang,
          description: description,
          jumlah: jumlah,
          harga: harga,
          diskon: diskon,
          imageUrl:
              imageUrl.isNotEmpty
                  ? imageUrl
                  : "https://via.placeholder.com/300x300?text=No+Image",
        );

        // Pass the selected image files to the API service
        await _apiService.createProduct(
          newProduct,
          imageFile: _selectedImage,
          imageBytes: _webImageBytes,
          fileName: _selectedImageName,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk berhasil dibuat')),
          );
          Navigator.pop(context, true);
        }
      } else {
        // Updating existing product
        final updatedProduct = Product(
          kodeBarang: kodeBarang,
          namaBarang: namaBarang,
          description: description,
          jumlah: jumlah,
          harga: harga,
          diskon: diskon,
          imageUrl:
              imageUrl.isNotEmpty
                  ? imageUrl
                  : (widget.product?.imageUrl?.isNotEmpty == true
                      ? widget.product!.imageUrl
                      : "https://via.placeholder.com/300x300?text=No+Image"),
        );

        // Pass the selected image files to the API service
        await _apiService.updateProduct(
          updatedProduct,
          imageFile: _selectedImage,
          imageBytes: _webImageBytes,
          fileName: _selectedImageName,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk berhasil diperbarui')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildImagePreview() {
    // Web platform - use memory image
    if (kIsWeb && _webImageBytes != null) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(_webImageBytes!, fit: BoxFit.cover),
        ),
      );
    }
    // Mobile platform - use file image
    else if (!kIsWeb && _selectedImage != null) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(_selectedImage!, fit: BoxFit.cover),
        ),
      );
    }
    // Network image from URL
    else if (_imageUrlController.text.isNotEmpty &&
        !_imageUrlController.text.startsWith('/') &&
        Uri.tryParse(_imageUrlController.text)?.isAbsolute == true) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            _imageUrlController.text,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 50, color: Colors.grey),
                    Text('Gagal memuat gambar'),
                  ],
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      );
    }
    // No image placeholder
    else {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[100],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, size: 50, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Tidak ada gambar dipilih',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreating = widget.product == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isCreating ? 'Tambah Produk Baru' : 'Edit Produk'),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image section
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Gambar Produk',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildImagePreview(),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _showImagePickerDialog,
                                      icon: const Icon(Icons.camera_alt),
                                      label: const Text('Pilih Gambar'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (_selectedImage != null ||
                                      _webImageBytes != null ||
                                      (_imageUrlController.text.isNotEmpty))
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _selectedImage = null;
                                          _webImageBytes = null;
                                          _selectedImageName = null;
                                          _imageUrlController.clear();
                                        });
                                      },
                                      icon: const Icon(Icons.delete),
                                      label: const Text('Hapus'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _imageUrlController,
                                decoration: const InputDecoration(
                                  labelText: 'URL Gambar (Opsional)',
                                  border: OutlineInputBorder(),
                                  hintText:
                                      'Masukkan URL gambar atau pilih gambar di atas',
                                  prefixIcon: Icon(Icons.link),
                                ),
                                validator: (value) {
                                  // Validasi URL jika diisi
                                  if (value != null && value.isNotEmpty) {
                                    // Allow local file paths starting with '/'
                                    if (value.startsWith('/')) {
                                      return null;
                                    }
                                    // Allow image names if an image is selected
                                    if ((_selectedImage != null ||
                                            _webImageBytes != null) &&
                                        !value.contains('://')) {
                                      return null;
                                    }
                                    final uri = Uri.tryParse(value);
                                    if (uri == null || !uri.isAbsolute) {
                                      return 'Format URL tidak valid';
                                    }
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  // Clear selected image if URL is manually entered
                                  if (value?.isNotEmpty == true &&
                                      !value!.startsWith('/')) {
                                    setState(() {
                                      _selectedImage = null;
                                      _webImageBytes = null;
                                      _selectedImageName = null;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Existing form fields
                      TextFormField(
                        controller: _kodeBarangController,
                        decoration: const InputDecoration(
                          labelText: 'Kode Barang',
                          border: OutlineInputBorder(),
                          hintText: 'Masukkan kode barang',
                          prefixIcon: Icon(Icons.qr_code),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kode barang wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _namaBarangController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Barang',
                          border: OutlineInputBorder(),
                          hintText: 'Masukkan nama barang',
                          prefixIcon: Icon(Icons.inventory),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama barang wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          border: OutlineInputBorder(),
                          hintText: 'Masukkan deskripsi barang',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Deskripsi wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _jumlahController,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah Stok',
                          border: OutlineInputBorder(),
                          hintText: 'Masukkan jumlah stok barang',
                          prefixIcon: Icon(Icons.storage),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jumlah stok wajib diisi';
                          }
                          try {
                            final jumlah = int.parse(value);
                            if (jumlah < 0) {
                              return 'Jumlah stok tidak boleh negatif';
                            }
                          } catch (e) {
                            return 'Format jumlah tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _hargaController,
                        decoration: const InputDecoration(
                          labelText: 'Harga',
                          border: OutlineInputBorder(),
                          prefixText: 'Rp ',
                          hintText: 'Masukkan harga barang',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harga wajib diisi';
                          }
                          try {
                            final price = double.parse(value);
                            if (price <= 0) {
                              return 'Harga harus lebih dari 0';
                            }
                          } catch (e) {
                            return 'Format harga tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _diskonController,
                        decoration: const InputDecoration(
                          labelText: 'Diskon (%)',
                          border: OutlineInputBorder(),
                          hintText: 'Masukkan persentase diskon (0-100)',
                          suffixText: '%',
                          prefixIcon: Icon(Icons.discount),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Diskon wajib diisi (masukkan 0 jika tidak ada diskon)';
                          }
                          try {
                            final diskon = int.parse(value);
                            if (diskon < 0 || diskon > 100) {
                              return 'Diskon harus antara 0-100%';
                            }
                          } catch (e) {
                            return 'Format diskon tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _saveProduct,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          isCreating ? 'Tambah Produk' : 'Simpan Perubahan',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
