import 'package:flutter/material.dart';

class PencarianMahasiswaPage extends StatefulWidget {
  const PencarianMahasiswaPage({Key? key}) : super(key: key);

  @override
  State<PencarianMahasiswaPage> createState() => _PencarianMahasiswaPageState();
}

class _PencarianMahasiswaPageState extends State<PencarianMahasiswaPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Mahasiswa> _daftarMahasiswa = [
    Mahasiswa(
      nama: "Ahmad Fauzi",
      nim: "2019010001",
      jurusan: "Teknik Informatika",
      angkatan: 2019,
      foto: "https://example.com/foto1.jpg",
    ),
    Mahasiswa(
      nama: "Siti Aisyah",
      nim: "2019020002",
      jurusan: "Sistem Informasi",
      angkatan: 2019,
      foto: "https://example.com/foto2.jpg",
    ),
    Mahasiswa(
      nama: "Budi Santoso",
      nim: "2020010003",
      jurusan: "Teknik Informatika",
      angkatan: 2020,
      foto: "https://example.com/foto3.jpg",
    ),
    Mahasiswa(
      nama: "Dewi Lestari",
      nim: "2020020004",
      jurusan: "Sistem Informasi",
      angkatan: 2020,
      foto: "https://example.com/foto4.jpg",
    ),
    Mahasiswa(
      nama: "Eko Prasetyo",
      nim: "2021010005",
      jurusan: "Teknik Informatika",
      angkatan: 2021,
      foto: "https://example.com/foto5.jpg",
    ),
    Mahasiswa(
      nama: "Fitriani",
      nim: "2021020006",
      jurusan: "Sistem Informasi",
      angkatan: 2021,
      foto: "https://example.com/foto6.jpg",
    ),
  ];

  List<Mahasiswa> _hasilPencarian = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _hasilPencarian = _daftarMahasiswa;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterMahasiswa(_searchController.text);
  }

  void _filterMahasiswa(String query) {
    List<Mahasiswa> hasilFilter = [];
    if (query.isEmpty) {
      hasilFilter = _daftarMahasiswa;
    } else {
      hasilFilter =
          _daftarMahasiswa
              .where(
                (mahasiswa) =>
                    mahasiswa.nama.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    mahasiswa.nim.toLowerCase().contains(query.toLowerCase()) ||
                    mahasiswa.jurusan.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    mahasiswa.angkatan.toString().contains(query),
              )
              .toList();
    }

    setState(() {
      _hasilPencarian = hasilFilter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: "Cari mahasiswa...",
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  autofocus: true,
                  onChanged: _filterMahasiswa,
                )
                : const Text("Pencarian Mahasiswa"),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _filterMahasiswa("");
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Cari Mahasiswa",
                hintText: "Masukkan Nama, NIM, Jurusan, atau Angkatan",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterMahasiswa("");
                          },
                        )
                        : null,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  "Filter Jurusan:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                FilterChip(
                  label: Text("Semua"),
                  selected: true,
                  onSelected: null,
                ),
                SizedBox(width: 8),
                FilterChip(
                  label: Text("Teknik Informatika"),
                  selected: false,
                  onSelected: null,
                ),
                SizedBox(width: 8),
                FilterChip(
                  label: Text("Sistem Informasi"),
                  selected: false,
                  onSelected: null,
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _hasilPencarian.isEmpty
                    ? const Center(
                      child: Text(
                        "Mahasiswa tidak ditemukan",
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _hasilPencarian.length,
                      itemBuilder: (context, index) {
                        final mahasiswa = _hasilPencarian[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(mahasiswa.foto),
                              onBackgroundImageError: (_, __) {},
                              child: const Icon(Icons.person),
                            ),
                            title: Text(
                              mahasiswa.nama,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("NIM: ${mahasiswa.nim}"),
                                Text("Jurusan: ${mahasiswa.jurusan}"),
                                Text("Angkatan: ${mahasiswa.angkatan}"),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.info),
                                          title: const Text("Detail Mahasiswa"),
                                          onTap: () {
                                            Navigator.pop(context);
                                            // Navigasi ke halaman detail mahasiswa
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.edit),
                                          title: const Text("Edit Data"),
                                          onTap: () {
                                            Navigator.pop(context);
                                            // Navigasi ke halaman edit mahasiswa
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          title: const Text(
                                            "Hapus Data",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                            // Tampilkan dialog konfirmasi hapus
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            onTap: () {
                              // Navigasi ke halaman detail mahasiswa
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman tambah mahasiswa
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Mahasiswa {
  final String nama;
  final String nim;
  final String jurusan;
  final int angkatan;
  final String foto;

  Mahasiswa({
    required this.nama,
    required this.nim,
    required this.jurusan,
    required this.angkatan,
    required this.foto,
  });
}
