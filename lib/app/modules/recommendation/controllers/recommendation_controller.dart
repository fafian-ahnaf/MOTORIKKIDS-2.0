import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http; // Tambahkan package http

class RecommendationController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  var recommendationData = <String, String>{}.obs;
  var isLoading = true.obs;

  late String _currentAge;
  late double _currentFineScore;
  late double _currentGrossScore;
  
  String? studentId;
  String role = ''; 

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    
    _currentAge = args['age'] ?? "5 Tahun";
    _currentFineScore = args['fineScore'] ?? 0.0;
    _currentGrossScore = args['grossScore'] ?? 0.0;
    studentId = args['studentId']; 
    role = args['role'] ?? ''; 

    if (role == 'parent') {
      fetchSavedRecommendation();
    } else {
      getNewRecommendation(); // Sekarang akan memanggil Flask API
    }
  }

  // --- FUNGSI PEMBANTU: KONVERSI SKOR KE TEKS OBSERVASI ---
  String _generateObservationText(double fine, double gross) {
    String fineStatus = fine >= 75 ? "sudah baik" : "perlu dilatih lagi";
    String grossStatus = gross >= 75 ? "sudah sangat aktif" : "masih kaku";
    
    return "Anak berusia $_currentAge dengan kemampuan motorik halus yang $fineStatus dan kemampuan motorik kasar yang $grossStatus.";
  }

  // --- MODIFIKASI: FUNGSI GURU (PAKAI API FLASK) ---
  void getNewRecommendation() async {
    isLoading.value = true;
    
    try {
      // 1. Siapkan teks observasi berdasarkan skor
      String teksObservasi = _generateObservationText(_currentFineScore, _currentGrossScore);

      // 2. Tembak API Flask (Ganti IP sesuai IPv4 laptop Anda)
      final String apiUrl = "http://192.168.X.X:5000/predict"; 
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"teks": teksObservasi}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String statusNLP = data['data']['prediksi_status']; // BB, MB, BSH, atau BSB

        // 3. Map status dari NLP ke data rekomendasi (Activity Content)
        recommendationData.value = _mapStatusToActivity(statusNLP);
      } else {
        throw "Server Error: ${response.statusCode}";
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal terhubung ke API IndoBERT: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- MAPPING STATUS KE ISI AKTIVITAS ---
  Map<String, String> _mapStatusToActivity(String status) {
    if (status == "BB") {
      return {
        "title": "Stimulasi Dasar Otot",
        "desc": "Ananda memerlukan bantuan penuh untuk memulai gerakan.",
        "tujuan": "Meningkatkan kesadaran gerak tubuh.",
        "cara": "Lakukan peregangan ringan dan bimbing tangan anak untuk menggenggam benda.",
        "durasi": "10 Menit",
        "lokasi": "Dalam Ruangan",
      };
    } else if (status == "MB") {
      return {
        "title": "Latihan Koordinasi Ringan",
        "desc": "Ananda mulai mencoba melakukan gerakan secara mandiri.",
        "tujuan": "Melatih kekuatan genggaman dan tumpuan kaki.",
        "cara": "Ajak anak menyusun 3 balok atau menendang bola diam.",
        "durasi": "15 Menit",
        "lokasi": "Halaman Rumah",
      };
    } else if (status == "BSH") {
      return {
        "title": "Aktivitas Motorik Terarah",
        "desc": "Kemampuan motorik sudah sesuai dengan tahapan usianya.",
        "tujuan": "Memantapkan keseimbangan dan fokus.",
        "cara": "Berjalan di atas garis lurus dan mewarnai bidang besar.",
        "durasi": "20 Menit",
        "lokasi": "Taman Bermain",
      };
    } else { // BSB
      return {
        "title": "Tantangan Ketangkasan",
        "desc": "Kemampuan motorik sangat baik dan melampaui rata-rata.",
        "tujuan": "Mengasah ketangkasan dan kreativitas gerak.",
        "cara": "Bersepeda roda tiga atau menggunting mengikuti pola berkelok.",
        "durasi": "30 Menit",
        "lokasi": "Area Terbuka",
      };
    }
  }

  // (Fungsi fetchSavedRecommendation dan markAsDone tetap sama seperti sebelumnya)
  void fetchSavedRecommendation() async { /* ... kode lama Anda ... */ }
  void markAsDone() async { /* ... kode lama Anda ... */ }
}