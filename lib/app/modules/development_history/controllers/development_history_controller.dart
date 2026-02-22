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
    // Mengambil studentId yang dikirim dari Dashboard Orang Tua
    if (Get.arguments != null && Get.arguments['studentId'] != null) {
      studentId = Get.arguments['studentId'];
      fetchHistory();
    } else {
      isLoading.value = false;
    }
  }

  void fetchHistory() async {
    try {
      isLoading.value = true;
      
      // Mengambil dokumen siswa langsung dari koleksi 'students'
      var doc = await _firestore.collection('students').doc(studentId).get();

      if (doc.exists) {
        var data = doc.data();
        // Mengambil data dari field array 'riwayat'
        if (data != null && data['riwayat'] != null) {
          List<dynamic> rawHistory = data['riwayat'];
          
          // Konversi ke List Map dan urutkan berdasarkan tanggal terbaru
          var sortedList = rawHistory.map((e) => Map<String, dynamic>.from(e)).toList();
          sortedList.sort((a, b) => (b['date'] ?? "").compareTo(a['date'] ?? ""));
          
          assessmentList.value = sortedList;
        }
      }
    } catch (e) {
      print("Error fetch history: $e");
    } finally {
      isLoading.value = false;
    }
  }
}