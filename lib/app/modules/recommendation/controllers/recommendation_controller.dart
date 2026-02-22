import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../services/ai_service.dart';

class RecommendationController extends GetxController {
  final AIService _aiService = AIService();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  var recommendationData = <String, String>{}.obs;
  var isLoading = true.obs;

  late String _currentAge;
  late double _currentFineScore;
  late double _currentGrossScore;
  
  String? studentId;
  String role = ''; // 💡 TAMBAHAN: Variabel untuk menyimpan role

  static Map<String, String>? _cachedData;
  static String? _cachedKey;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    
    _currentAge = args['age'] ?? "5 Tahun";
    _currentFineScore = args['fineScore'] ?? 0.0;
    _currentGrossScore = args['grossScore'] ?? 0.0;
    studentId = args['studentId']; 
    
    // Tangkap role dari argumen (dikirim dari Dashboard)
    role = args['role'] ?? ''; 

    // 💡 LOGIKA PERCABANGAN
    if (role == 'parent') {
      // Jika Orang Tua: Ambil data persis yang disave Guru
      fetchSavedRecommendation();
    } else {
      // Jika Guru: Generate baru pakai AI
      String key = "$_currentAge-$_currentFineScore-$_currentGrossScore";
      if (_cachedData != null && _cachedKey == key) {
        recommendationData.value = _cachedData!;
        isLoading.value = false;
      } else {
        getNewRecommendation();
      }
    }
  }

  // --- FUNGSI BARU KHUSUS ORANG TUA ---
  void fetchSavedRecommendation() async {
    isLoading.value = true;
    if (studentId != null) {
      try {
        // Ambil 1 rekomendasi terbaru dari sub-collection 'recommendations'
        var snapshot = await firestore
            .collection('students')
            .doc(studentId)
            .collection('recommendations')
            .orderBy('date', descending: true)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          var data = snapshot.docs.first.data();
          // Tampilkan data persis seperti yang disimpan Guru
          recommendationData.value = {
            "title": data['title']?.toString() ?? "",
            "desc": data['desc']?.toString() ?? "",
            "tujuan": data['tujuan']?.toString() ?? "",
            "cara": data['cara']?.toString() ?? "",
            "durasi": data['durasi']?.toString() ?? "",
            "lokasi": data['lokasi']?.toString() ?? "",
          };
        } else {
          // Jika Guru belum pernah meng-generate & menyimpan rekomendasi
          recommendationData.value = {
            "title": "Belum Ada Rekomendasi",
            "desc": "Guru belum membuat rekomendasi aktivitas motorik untuk Ananda saat ini.",
            "tujuan": "-",
            "cara": "-",
            "durasi": "-",
            "lokasi": "-",
          };
        }
      } catch (e) {
        Get.snackbar("Error", "Gagal mengambil data rekomendasi: $e");
      }
    }
    isLoading.value = false;
  }

  // --- FUNGSI LAMA KHUSUS GURU ---
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

  void markAsDone() async {
    if (studentId != null && recommendationData.isNotEmpty) {
      try {
        await firestore
            .collection('students')
            .doc(studentId)
            .collection('recommendations') 
            .add({
          ...recommendationData, 
          'date': DateTime.now().toIso8601String(), 
          'isDone': true,
        });

        Get.back();
        Get.snackbar("Tersimpan", "Saran aktivitas berhasil disimpan ke riwayat siswa!", 
          backgroundColor: const Color(0xFF4CAF50), colorText: Get.theme.canvasColor); 
      } catch (e) {
        Get.snackbar("Gagal", "Gagal menyimpan data: $e");
      }
    } else {
      Get.back(); 
    }
  }
}