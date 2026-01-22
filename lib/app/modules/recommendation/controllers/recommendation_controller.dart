import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart'; // Jangan lupa import ini
import 'package:get/get.dart';
import '../../../services/ai_service.dart';

class RecommendationController extends GetxController {
  final AIService _aiService = AIService();
  FirebaseFirestore firestore = FirebaseFirestore.instance; // Instance Firestore
  
  var recommendationData = <String, String>{}.obs;
  var isLoading = true.obs;

  late String _currentAge;
  late double _currentFineScore;
  late double _currentGrossScore;
  String? studentId; // Tambahkan variable ini

  static Map<String, String>? _cachedData;
  static String? _cachedKey;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    
    _currentAge = args['age'] ?? "5 Tahun";
    _currentFineScore = args['fineScore'] ?? 0.0;
    _currentGrossScore = args['grossScore'] ?? 0.0;
    studentId = args['studentId']; // Tangkap ID Siswa

    String key = "$_currentAge-$_currentFineScore-$_currentGrossScore";

    if (_cachedData != null && _cachedKey == key) {
      recommendationData.value = _cachedData!;
      isLoading.value = false;
    } else {
      getNewRecommendation();
    }
  }

  void getNewRecommendation() async {
    isLoading.value = true;
    _cachedKey = "$_currentAge-$_currentFineScore-$_currentGrossScore";

    try {
      var result = await _aiService.getRecommendation(
        age: _currentAge,
        fineScore: _currentFineScore,
        grossScore: _currentGrossScore,
      );
      
      _cachedData = result;
      recommendationData.value = result;
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat rekomendasi: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // FUNGSI BARU: SIMPAN KE FIREBASE
  void markAsDone() async {
    if (studentId != null && recommendationData.isNotEmpty) {
      try {
        await firestore
            .collection('students')
            .doc(studentId)
            .collection('recommendations') // Simpan di sub-collection baru
            .add({
          ...recommendationData, // Simpan semua data (title, desc, cara, dll)
          'date': DateTime.now().toIso8601String(), // Tanggal dibuat
          'isDone': true,
        });

        Get.back();
        Get.snackbar("Tersimpan", "Saran aktivitas berhasil disimpan ke riwayat siswa!", 
          backgroundColor: const Color(0xFF4CAF50), colorText: Get.theme.canvasColor); // Warna hijau
      } catch (e) {
        Get.snackbar("Gagal", "Gagal menyimpan data: $e");
      }
    } else {
      Get.back(); // Jika tidak ada ID, tutup saja
    }
  }
}