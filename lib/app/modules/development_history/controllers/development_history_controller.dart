import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DevelopmentHistoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = true.obs;
  var assessmentList = <Map<String, dynamic>>[].obs;
  String studentId = "";

  @override
  void onInit() {
    super.onInit();
    // Tangkap argumen studentId dengan aman
    if (Get.arguments != null) {
      studentId = Get.arguments['studentId'] ?? Get.arguments['id'] ?? "";
    }
    
    if (studentId.isNotEmpty) {
      fetchHistory();
    } else {
      isLoading.value = false;
      Get.snackbar("Info", "ID Siswa tidak ditemukan");
    }
  }

  void fetchHistory() async {
    try {
      isLoading.value = true;
      List<Map<String, dynamic>> combinedHistory = [];
      
      // 1. Ambil dari Array Lama
      var doc = await _firestore.collection('students').doc(studentId).get();
      if (doc.exists && doc.data() != null && doc.data()!.containsKey('riwayat')) {
        var rawHistory = doc.data()!['riwayat'];
        if (rawHistory is List) {
          combinedHistory.addAll(rawHistory.map((e) => Map<String, dynamic>.from(e)));
        }
      }

      // 2. Ambil dari Sub-koleksi
      var subColSnapshot = await _firestore.collection('students').doc(studentId).collection('riwayat').get();
      if (subColSnapshot.docs.isNotEmpty) {
        combinedHistory.addAll(subColSnapshot.docs.map((d) => d.data()));
      }

      // 3. Urutkan berdasarkan tanggal (Terbaru ke Terlama)
      combinedHistory.sort((a, b) => (b['date'] ?? "").toString().compareTo((a['date'] ?? "").toString()));
      
      assessmentList.assignAll(combinedHistory);
    } catch (e) {
      print("Error fetch history: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi kebal error tipe data
  double getChartValue(dynamic score) {
    if (score == null) return 0.0;
    
    String s = score.toString().toUpperCase();
    if (s.contains("BSB")) return 4.0;
    if (s.contains("BSH")) return 3.0;
    if (s.contains("MB")) return 2.0;
    if (s.contains("BB")) return 1.0;
    
    double? val = double.tryParse(score.toString());
    if (val != null) {
      if (val >= 76) return 4.0;
      if (val >= 51) return 3.0;
      if (val >= 26) return 2.0;
      return 1.0;
    }
    return 0.0;
  }
}