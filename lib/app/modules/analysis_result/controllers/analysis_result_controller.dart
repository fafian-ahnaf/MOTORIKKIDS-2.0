import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:motorikkids/app/modules/recommendation/views/recommendation_view.dart';

class AnalysisResultController extends GetxController {
  // --- Data Simulasi Hasil NLP ---
  // Data ini ceritanya didapat dari API Backend setelah diproses AI
  
  // 1. Ringkasan Otomatis (Generated Summary)
  var nlpSummary = "Anak menunjukkan peningkatan motorik kasar, namun koordinasi tangan dan keseimbangan tubuh masih perlu dilatih lebih lanjut agar lebih stabil.".obs;
  
  // 2. Klasifikasi Data (Classification)
  var scoreKasar = 75.obs;
  var scoreHalus = 60.obs;
  
  // 3. Status (Rule-based or AI classification)
  var status = "Perlu Stimulasi".obs;
  var statusColor = const Color(0xFFEEDB00).obs; // Warna Kuning sesuai gambar

  // 4. Rekomendasi Aktivitas (Recommendation System)
  var recommendationData = {
    "title": "Berjalan di Papan Titian",
    "goal": "Meningkatkan keseimbangan tubuh dan fokus",
    "method": "Anak berjalan di papan atau garis lurus tanpa jatuh, tangan direntangkan untuk menjaga keseimbangan.",
    "duration": "5-10 menit",
    "location": "Sekolah / Halaman Rumah"
  }.obs;

  // --- Fungsi Navigasi ---

  // Pindah ke Halaman Rekomendasi
  void goToRecommendation() {
    Get.to(() => const RecommendationView());
  }

  // Simpan Data dan Kembali
  void saveAndFinish() {
    // Logika simpan ke database (Firebase/API) bisa ditaruh di sini
    Get.back(); 
    Get.snackbar(
      "Tersimpan", 
      "Data analisa berhasil disimpan ke riwayat perkembangan", 
      backgroundColor: Colors.green, 
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM
    );
  }
}