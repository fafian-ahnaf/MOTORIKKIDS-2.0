import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class DevelopmentHistoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoading = true.obs;
  var assessmentList = <Map<String, dynamic>>[].obs;
  String studentId = "";
  
  // --- VARIABEL UNTUK PDF ---
  var studentName = 'Ananda'.obs;
  var teacherName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      studentId = Get.arguments['studentId'] ?? Get.arguments['id'] ?? "";
      studentName.value = Get.arguments['studentName'] ?? Get.arguments['name'] ?? "Ananda"; 
    }

    fetchUserName();

    if (studentId.isNotEmpty) {
      fetchHistory();
    } else {
      isLoading.value = false;
      Get.snackbar("Info", "ID Siswa tidak ditemukan");
    }
  }

  void fetchUserName() async {
    try {
      if (_auth.currentUser != null) {
        String uid = _auth.currentUser!.uid;
        var userDoc = await _firestore.collection('users').doc(uid).get();
        
        if (userDoc.exists && userDoc.data() != null) {
          String role = userDoc.data()!['role']?.toString().toLowerCase() ?? '';
          
          if (role == 'teacher' || role == 'guru') {
            teacherName.value = userDoc.data()!['nama_lengkap'] ?? '';
          }
        }
      }
    } catch (e) {
      print("Error fetch user name: $e");
    }
  }

  void fetchHistory() async {
    try {
      isLoading.value = true;
      List<Map<String, dynamic>> combinedHistory = [];
      
      // Ambil data siswa
      var doc = await _firestore.collection('students').doc(studentId).get();
      
      if (doc.exists && doc.data() != null) {
        var studentData = doc.data()!;

        // 1. UPDATE NAMA ANAK
        if (studentName.value == 'Ananda') {
          studentName.value = studentData['name'] ?? studentData['nama_lengkap'] ?? 'Ananda';
        }

        // ================================================================
        // 2. PENCARIAN GURU OTOMATIS (DATA SUDAH SERAGAM)
        // ================================================================
        if (teacherName.value.isEmpty || teacherName.value == 'Guru Kelas') {
          String kelasSiswa = studentData['kelas']?.toString().trim() ?? ''; 

          if (kelasSiswa.isNotEmpty) {
            try {
              // Langsung cari menggunakan nama kelas asli dari anak tersebut
              var guruQuery = await _firestore.collection('users')
                  .where('role', isEqualTo: 'teacher')
                  .where('kelas', isEqualTo: kelasSiswa) 
                  .limit(1)
                  .get();
                  
              if (guruQuery.docs.isNotEmpty) {
                teacherName.value = guruQuery.docs.first.data()['nama_lengkap'] ?? 'Guru Kelas';
              } else {
                teacherName.value = 'Guru Kelas';
              }
            } catch (error) {
              print("Firebase Error: $error");
              teacherName.value = 'Guru Kelas';
            }
          } else {
            teacherName.value = 'Guru Kelas';
          }
        }

        // 3. AMBIL RIWAYAT ARRAY LAMA
        if (studentData.containsKey('riwayat')) {
          var rawHistory = studentData['riwayat'];
          if (rawHistory is List) {
            combinedHistory.addAll(rawHistory.map((e) => Map<String, dynamic>.from(e)));
          }
        }
      }

      // 4. AMBIL RIWAYAT DARI SUB-KOLEKSI
      var subColSnapshot = await _firestore.collection('students').doc(studentId).collection('riwayat').get();
      if (subColSnapshot.docs.isNotEmpty) {
        combinedHistory.addAll(subColSnapshot.docs.map((d) => d.data()));
      }

      // Urutkan berdasarkan tanggal (Terbaru ke Terlama)
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