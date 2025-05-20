import 'package:flutter/material.dart';

// Export class ini agar bisa digunakan di file lain
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Mahasiswa _profileData = Mahasiswa(
    nama: "Ulil Amry Al Qadri",
    nim: "222277",
    jurusan: "Teknik Informatika",
    angkatan: 2022,
    foto: "https://example.com/foto_ulil.jpg",
    email: "ulil.amry@email.com",
    instagram: "@ulil_amry",
    alamat: "Jl. Pendidikan No. 123, Makassar",
    noHP: "081234567890",
    ipk: 3.85,
  );

  bool _isEditing = false;
  late TextEditingController _namaController;
  late TextEditingController _emailController;
  late TextEditingController _instagramController;
  late TextEditingController _alamatController;
  late TextEditingController _noHPController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: _profileData.nama);
    _emailController = TextEditingController(text: _profileData.email);
    _instagramController = TextEditingController(text: _profileData.instagram);
    _alamatController = TextEditingController(text: _profileData.alamat);
    _noHPController = TextEditingController(text: _profileData.noHP);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _instagramController.dispose();
    _alamatController.dispose();
    _noHPController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Mahasiswa"),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // Simpan perubahan
                  _profileData.nama = _namaController.text;
                  _profileData.email = _emailController.text;
                  _profileData.instagram = _instagramController.text;
                  _profileData.alamat = _alamatController.text;
                  _profileData.noHP = _noHPController.text;

                  // Tampilkan snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Profil berhasil diperbarui"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(_profileData.foto),
                        onBackgroundImageError: (_, __) {},
                        child: const Icon(Icons.person, size: 80),
                      ),
                      if (_isEditing)
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              // Implementasi untuk mengubah foto profil
                            },
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _isEditing
                      ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: TextField(
                          controller: _namaController,
                          decoration: const InputDecoration(
                            labelText: "Nama Lengkap",
                            border: OutlineInputBorder(),
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                      : Text(
                        _profileData.nama,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  const SizedBox(height: 8),
                  Text(
                    "NIM: ${_profileData.nim}",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${_profileData.jurusan} (${_profileData.angkatan})",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: "Indeks Prestasi",
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildIPKWidget(
                        "IPK",
                        _profileData.ipk.toString(),
                        Colors.blue,
                      ),
                      _buildIPKWidget("SKS", "96", Colors.green),
                      _buildIPKWidget("Semester", "4", Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(
                    value: 0.67, // 4/6 semester
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Progress Studi: 67%",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: "Informasi Kontak",
              child: Column(
                children: [
                  _buildContactItem(
                    icon: Icons.email,
                    title: "Email",
                    controller: _emailController,
                    value: _profileData.email,
                    isEditing: _isEditing,
                  ),
                  const Divider(),
                  _buildContactItem(
                    icon: Icons.phone,
                    title: "No. Handphone",
                    controller: _noHPController,
                    value: _profileData.noHP,
                    isEditing: _isEditing,
                  ),
                  const Divider(),
                  _buildContactItem(
                    icon: Icons.home,
                    title: "Alamat",
                    controller: _alamatController,
                    value: _profileData.alamat,
                    isEditing: _isEditing,
                  ),
                  const Divider(),
                  _buildContactItem(
                    icon: Icons.photo_camera,
                    title: "Instagram",
                    controller: _instagramController,
                    value: _profileData.instagram,
                    isEditing: _isEditing,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: "Keamanan Akun",
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text("Ubah Password"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Implementasi untuk halaman ubah password
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text("Keamanan Dua Faktor"),
                    trailing: Switch(
                      value: false,
                      onChanged: (value) {
                        // Implementasi untuk mengaktifkan/menonaktifkan 2FA
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Implementasi untuk logout
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Keluar",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildIPKWidget(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              top: 16,
              right: 16,
              bottom: 8,
            ),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
    required TextEditingController controller,
    required bool isEditing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                isEditing
                    ? TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    )
                    : Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Kelas Mahasiswa yang diperluas dengan informasi tambahan
class Mahasiswa {
  String nama;
  final String nim;
  final String jurusan;
  final int angkatan;
  final String foto;
  String email;
  String instagram;
  String alamat;
  String noHP;
  double ipk;

  Mahasiswa({
    required this.nama,
    required this.nim,
    required this.jurusan,
    required this.angkatan,
    required this.foto,
    required this.email,
    required this.instagram,
    required this.alamat,
    required this.noHP,
    required this.ipk,
  });
}

// Cara menggunakan halaman profil
// Contoh navigasi dari halaman pencarian:
/*
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const ProfilePage()),
);
*/
