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
    // Mendapatkan studentId dari argumen yang dikirim
    if (Get.arguments != null) {
      studentId = Get.arguments['studentId'] ?? Get.arguments['id'] ?? "";
      if (studentId.isNotEmpty) {
        fetchHistory();
      } else {
        isLoading.value = false;
      }
    }
  }

  void fetchHistory() async {
    try {
      isLoading.value = true;
      List<Map<String, dynamic>> combinedHistory = [];
      
      // 1. AMBIL DARI ARRAY (Data lama)
      var doc = await _firestore.collection('students').doc(studentId).get();
      if (doc.exists) {
        var data = doc.data();
        if (data != null && data['riwayat'] != null) {
          List<dynamic> rawHistory = data['riwayat'];
          combinedHistory.addAll(rawHistory.map((e) => Map<String, dynamic>.from(e)));
        }
      }

      // 2. AMBIL DARI SUB-KOLEKSI (Data AI Kelompok)
      var subColSnapshot = await _firestore.collection('students').doc(studentId).collection('riwayat').get();
      for (var subDoc in subColSnapshot.docs) {
        combinedHistory.add(subDoc.data());
      }

      // 3. URUTKAN BERDASARKAN TANGGAL (Terbaru ke terlama)
      combinedHistory.sort((a, b) => (b['date'] ?? "").compareTo(a['date'] ?? ""));
      
      assessmentList.assignAll(combinedHistory);
      
    } catch (e) {
      print("Error fetch history: $e");
    } finally {
      isLoading.value = false;
    }
  }

  double getChartValue(String status) {
    status = status.toUpperCase();
    if (status.contains("BSB")) return 4.0;
    if (status.contains("BSH")) return 3.0;
    if (status.contains("MB")) return 2.0;
    if (status.contains("BB")) return 1.0;
    return 0.0;
  }
}