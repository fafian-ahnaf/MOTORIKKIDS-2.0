import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class TeacherDashboardController extends GetxController {
  // Instance Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Variabel Data (Observable/Realtime)
  var userName = "Memuat...".obs;
  var totalSiswa = 0.obs;
  var totalLaporan = 0.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  void loadDashboardData() async {
    try {
      isLoading.value = true;
      String uid = _auth.currentUser!.uid;

      // 1. Ambil Nama Guru dari Firestore
      var userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        userName.value = userDoc.data()?['nama_lengkap'] ?? "Ibu/Bapak Guru";
      }

      // 2. Hitung Total Siswa (Query Jumlah Dokumen)
      var siswaSnapshot = await _firestore.collection('students').count().get();
      totalSiswa.value = siswaSnapshot.count ?? 0;

      // 3. Hitung Total Laporan
      var laporanSnapshot = await _firestore.collection('reports').count().get();
      totalLaporan.value = laporanSnapshot.count ?? 0;

    } catch (e) {
      print("Error loading dashboard: $e");
      userName.value = "User Tidak Dikenal";
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    await _auth.signOut();
    Get.offAllNamed(Routes.WELCOME);
  }
}