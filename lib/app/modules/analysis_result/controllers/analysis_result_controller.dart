import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:motorikkids/app/modules/recommendation/views/recommendation_view.dart';

class AnalysisResultController extends GetxController {
  
  var isLoading = true.obs; 

  
  var inputTeks = "".obs;
  var status = "Memproses...".obs;
  var tingkatKeyakinan = 0.0.obs;
  var statusColor = Rx<Color>(Colors.grey);

  
  var recommendationData = {}.obs;

  @override
  void onInit() {
    super.onInit();
    

    final Map<String, dynamic> args = Get.arguments ?? {};
    String teksObservasi = args['teks'] ?? "Anak sudah mulai bisa melompat walau belum stabil.";
    inputTeks.value = teksObservasi;

    
    fetchPredictionFromFlask(teksObservasi);
  }

  
  Future<void> fetchPredictionFromFlask(String teks) async {
    try {
      isLoading.value = true;


      final String apiUrl = "http://172.16.10.245:5000/predict"; 
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"teks": teks}),
      ).timeout(const Duration(seconds: 15)); 

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['status'] == 'success') {
          
          status.value = responseData['data']['prediksi_status']; 
          tingkatKeyakinan.value = responseData['data']['tingkat_keyakinan'];

          
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