import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motorikkids/app/services/nlp_service.dart';

class AssessmentFormController extends GetxController {
  final teksObservasi = TextEditingController();
  
  final isLoading = false.obs;
  final hasilPrediksi = "".obs;
  final skorKeyakinan = "".obs;

  // =========================================================
  // 1. REVISI KETUA PENGUJI: USIA, KOMPONEN & KATEGORI
  // =========================================================
  var selectedUsiaBulan = 48.obs; // Default usia 4 tahun (48 bulan)
  var selectedKomponen = "Berlari & Melompat".obs;
  var selectedKategori = "Motorik Kasar".obs;

  // Daftar komponen baku berdasarkan pedoman SDIDTK / KIA
  final List<Map<String, String>> daftarKomponen = [
    {"komponen": "Berlari & Melompat", "kategori": "Motorik Kasar"},
    {"komponen": "Keseimbangan (Berdiri 1 Kaki)", "kategori": "Motorik Kasar"},
    {"komponen": "Menangkap & Melempar Bola", "kategori": "Motorik Kasar"},
    {"komponen": "Naik Turun Tangga", "kategori": "Motorik Kasar"},
    {"komponen": "Menggunting & Menempel", "kategori": "Motorik Halus"},
    {"komponen": "Memegang Pensil / Menggambar", "kategori": "Motorik Halus"},
    {"komponen": "Menumpuk Balok / Kubus", "kategori": "Motorik Halus"},
    {"komponen": "Meronce & Melipat Kertas", "kategori": "Motorik Halus"},
  ];

  // Fungsi untuk mengubah kategori otomatis saat komponen dipilih
  void updateKomponen(String? value) {
    if (value != null) {
      selectedKomponen.value = value;
      final item = daftarKomponen.firstWhere((e) => e["komponen"] == value);
      selectedKategori.value = item["kategori"]!;
    }
  }

  // =========================================================
  // 2. FUNGSI ANALISIS & KIRIM KE INDOBERT
  // =========================================================
  void analisisData() async {
    if (teksObservasi.text.trim().isEmpty) {
      Get.snackbar(
        "Peringatan", 
        "Teks observasi tidak boleh kosong! Tuliskan deskripsi kemampuan anak.",
        backgroundColor: Colors.orange.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    
    // Gabungkan nama komponen dengan deskripsi agar konteks kalimat lebih jelas bagi model AI
    String kalimatLengkap = "${selectedKomponen.value}: ${teksObservasi.text.trim()}";

    // Panggil NLP Service IndoBERT
    final hasil = await NlpService.analisisMotorik(kalimatLengkap);
    
    isLoading.value = false;

    if (hasil != null) {
      hasilPrediksi.value = hasil['prediksi_status'] ?? "BSH";
      double skor = (hasil['tingkat_keyakinan'] ?? 0.0).toDouble();
      skorKeyakinan.value = "${(skor * 100).toStringAsFixed(1)}%";

      // =========================================================
      // 3. KIRIM SEMUA DATA KE HALAMAN HASIL ANALISIS
      // =========================================================
      // Pastikan nama rute sesuai dengan app_pages.dart Anda (misal: '/analysis-result')
      Get.toNamed(
        '/analysis-result', 
        arguments: {
          'teks': kalimatLengkap,
          'usia_bulan': selectedUsiaBulan.value,
          'kategori': selectedKategori.value,
          'komponen': selectedKomponen.value,
        },
      );
    } else {
      Get.snackbar(
        "Error", 
        "Gagal terhubung ke Server AI. Pastikan server Flask menyala.",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    teksObservasi.dispose(); 
    super.onClose();
  }
}