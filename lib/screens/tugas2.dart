import 'package:flutter/material.dart';

class NilaiMahasiswaApp extends StatelessWidget {
  const NilaiMahasiswaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Nilai Mahasiswa',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const NilaiMahasiswaForm(),
    );
  }
}

class NilaiMahasiswaForm extends StatefulWidget {
  const NilaiMahasiswaForm({super.key});

  @override
  _NilaiMahasiswaFormState createState() => _NilaiMahasiswaFormState();
}

class _NilaiMahasiswaFormState extends State<NilaiMahasiswaForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nimController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController hadirController = TextEditingController();
  final TextEditingController tugasController = TextEditingController();
  final TextEditingController midController = TextEditingController();
  final TextEditingController finalController = TextEditingController();

  double? nilaiAkhir;
  String? nilaiHuruf;
  bool showResult = false;

  void hitungNilai() {
    if (_formKey.currentState!.validate()) {
      double hadir = double.parse(hadirController.text);
      double tugas = double.parse(tugasController.text);
      double mid = double.parse(midController.text);
      double finalExam = double.parse(finalController.text);

      double na =
          (hadir * 0.1) + (tugas * 0.2) + (mid * 0.3) + (finalExam * 0.4);
      String nh;

      if (na >= 85) {
        nh = "A";
      } else if (na >= 70) {
        nh = "B";
      } else if (na >= 55) {
        nh = "C";
      } else if (na >= 40) {
        nh = "D";
      } else {
        nh = "E";
      }

      setState(() {
        nilaiAkhir = na;
        nilaiHuruf = nh;
        showResult = true;
      });
    }
  }

  void resetForm() {
    nimController.clear();
    namaController.clear();
    hadirController.clear();
    tugasController.clear();
    midController.clear();
    finalController.clear();
    setState(() {
      showResult = false;
      nilaiAkhir = null;
      nilaiHuruf = null;
    });
  }

  String getKeterangan(String grade) {
    switch (grade) {
      case 'A':
        return 'Sangat Baik';
      case 'B':
        return 'Baik';
      case 'C':
        return 'Cukup';
      case 'D':
        return 'Kurang';
      case 'E':
        return 'Gagal';
      default:
        return '';
    }
  }

  Color getWarnaGrade(String grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      case 'E':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KALKULATOR NILAI MAHASISWA"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: resetForm,
            tooltip: 'Reset Form',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Data Mahasiswa
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Data Mahasiswa",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nimController,
                        decoration: const InputDecoration(
                          labelText: "NIM",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan NIM';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: namaController,
                        decoration: const InputDecoration(
                          labelText: "Nama Lengkap",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan Nama Lengkap';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Nilai
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Nilai",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      buildScoreField(
                        controller: hadirController,
                        label: "Kehadiran (10%)",
                      ),
                      const SizedBox(height: 10),
                      buildScoreField(
                        controller: tugasController,
                        label: "Tugas (20%)",
                      ),
                      const SizedBox(height: 10),
                      buildScoreField(
                        controller: midController,
                        label: "UTS (30%)",
                      ),
                      const SizedBox(height: 10),
                      buildScoreField(
                        controller: finalController,
                        label: "UAS (40%)",
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: hitungNilai,
                child: const Text("HITUNG NILAI"),
              ),

              if (showResult && nilaiAkhir != null && nilaiHuruf != null)
                buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildScoreField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Masukkan nilai';
        }
        try {
          double score = double.parse(value);
          if (score < 0 || score > 100) {
            return 'Nilai harus antara 0-100';
          }
        } catch (e) {
          return 'Masukkan angka yang valid';
        }
        return null;
      },
    );
  }

  Widget buildResultCard() {
    return Card(
      margin: const EdgeInsets.only(top: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "HASIL NILAI",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Mahasiswa:"),
                Text("${namaController.text} (${nimController.text})"),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Nilai Akhir:"),
                Text(nilaiAkhir!.toStringAsFixed(2)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Grade:"),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: getWarnaGrade(nilaiHuruf!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    nilaiHuruf!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Keterangan:"),
                Text(getKeterangan(nilaiHuruf!)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
