import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:motorikkids/app/modules/recommendation/views/recommendation_view.dart';

class AnalysisResultController extends GetxController {
  // --- STATE LOADING ---
  var isLoading = true.obs; 

  // --- DATA REAKTIF ---
  var inputTeks = "".obs;
  var status = "Memproses...".obs;
  var tingkatKeyakinan = 0.0.obs;
  var statusColor = Rx<Color>(Colors.grey);

  // Rekomendasi (Karena API Flask hanya menebak status, kita buat logic saran di Flutter)
  var recommendationData = {}.obs;

  @override
  void onInit() {
    super.onInit();
    
    // 1. Tangkap argumen (teks observasi) dari halaman sebelumnya
    // Catatan: Pastikan di StudentDetailView Anda mengirim argumen 'teks'
    final Map<String, dynamic> args = Get.arguments ?? {};
    String teksObservasi = args['teks'] ?? "Anak sudah mulai bisa melompat walau belum stabil.";
    inputTeks.value = teksObservasi;

    // 2. Tembak ke API Flask Anda
    fetchPredictionFromFlask(teksObservasi);
  }

  // --- FUNGSI PEMANGGIL API FLASK ---
  Future<void> fetchPredictionFromFlask(String teks) async {
    try {
      isLoading.value = true;

      // PENTING: Ganti 192.168.X.X dengan IPv4 Address laptop Anda (cek lewat CMD -> ipconfig)
      // Jangan gunakan localhost atau 127.0.0.1 jika menggunakan HP Fisik
      final String apiUrl = "http://192.168.1.8:5000/predict"; 
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"teks": teks}),
      ).timeout(const Duration(seconds: 15)); // Timeout 15 detik

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['status'] == 'success') {
          // Tangkap hasil dari Flask
          status.value = responseData['data']['prediksi_status']; // Hasil: BB, MB, BSH, BSB
          tingkatKeyakinan.value = responseData['data']['tingkat_keyakinan'];

          // Atur warna dan rekomendasi berdasarkan label
          _generateRecommendationBasedOnStatus(status.value);
        } else {
          _setFallbackData("Gagal memproses data di server.");
        }
      } else {
        _setFallbackData("Error Server: ${response.statusCode}");
      }
    } catch (e) {
      _setFallbackData("Gagal terhubung ke API. Pastikan laptop & HP di WiFi yang sama. Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGIKA REKOMENDASI BERDASARKAN STATUS NLP ---
  void _generateRecommendationBasedOnStatus(String prediksi) {
    if (prediksi == "BB") { // Belum Berkembang
      statusColor.value = Colors.red.shade400;
      recommendationData.value = {
        "title": "Stimulasi Dasar Motorik",
        "goal": "Merangsang pergerakan dasar otot besar dan kecil",
        "method": "Bimbing anak secara fisik untuk melakukan gerakan sederhana seperti meremas bola spons atau berjalan dengan bantuan.",
        "duration": "10-15 menit rutin",
      };
    } else if (prediksi == "MB") { // Mulai Berkembang
      statusColor.value = const Color(0xFFEEDB00); // Kuning
      recommendationData.value = {
        "title": "Latihan Keseimbangan Ringan",
        "goal": "Meningkatkan koordinasi tubuh bertahap",
        "method": "Ajak anak menendang bola ke gawang kecil atau menyusun balok kayu ukuran sedang.",
        "duration": "15 menit",
      };
    } else if (prediksi == "BSH") { // Berkembang Sesuai Harapan
      statusColor.value = Colors.blue.shade400;
      recommendationData.value = {
        "title": "Aktivitas Motorik Terarah",
        "goal": "Mempertahankan dan menajamkan fokus",
        "method": "Bermain tangkap bola, melompat di atas garis, atau menggambar bentuk dasar.",
        "duration": "20 menit",
      };
    } else if (prediksi == "BSB") { // Berkembang Sangat Baik
      statusColor.value = Colors.green.shade500;
      recommendationData.value = {
        "title": "Tantangan Motorik Kompleks",
        "goal": "Meningkatkan kelincahan dan motorik halus tingkat lanjut",
        "method": "Berjalan di papan titian, bersepeda roda tiga, atau menggunting kertas mengikuti pola.",
        "duration": "Bebas/Fleksibel",
      };
    } else {
      _setFallbackData("Status tidak dikenali");
    }
  }

  void _setFallbackData(String errorMsg) {
    status.value = "Error";
    statusColor.value = Colors.grey;
    recommendationData.value = {
      "title": "Gagal Memuat Data",
      "goal": "-",
      "method": errorMsg,
      "duration": "-",
    };
  }

  // --- FUNGSI NAVIGASI ---
  void goToRecommendation() {
    Get.to(() => const RecommendationView());
  }

  void saveAndFinish() {
    Get.back(); 
    Get.snackbar(
      "Berhasil", 
      "Analisa $status disave ke database.", 
      backgroundColor: Colors.green, 
      colorText: Colors.white,
    );
  }
}