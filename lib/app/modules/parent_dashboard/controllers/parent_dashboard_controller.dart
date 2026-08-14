import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ParentDashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoading = true.obs;
  var parentName = "Bunda/Ayah".obs;
  
  var studentData = <String, dynamic>{}.obs;
  var studentId = "".obs;

  // --- PERBAIKAN 1: TAMBAHKAN LIST RIWAYAT AGAR BISA MUNCUL 2 CATATAN ---
  var assessmentHistory = <Map<String, dynamic>>[].obs;
  var latestObservation = <String, dynamic>{}.obs;

  final tokenC = TextEditingController();
  var isLinking = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  void loadDashboardData() async {
    try {
      isLoading.value = true;
      User? user = _auth.currentUser;
      
      if (user != null) {
        // 1. Ambil nama orang tua dari tabel users (dengan multi-fallback)
        var userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          var uData = userDoc.data()!;
          parentName.value = uData['nama_lengkap'] ?? 
                             uData['nama'] ?? 
                             uData['name'] ?? 
                             user.displayName ?? 
                             "Bunda/Ayah";
        } else {
          parentName.value = user.displayName ?? "Bunda/Ayah";
        }

        // 2. Cari langsung ke tabel students berdasarkan parent_id
        var studentQuery = await _firestore.collection('students')
            .where('parent_id', isEqualTo: user.uid)
            .limit(1)
            .get();

        if (studentQuery.docs.isNotEmpty) {
          var studentDoc = studentQuery.docs.first;
          var data = studentDoc.data();
          data['id'] = studentDoc.id;
          
          studentId.value = studentDoc.id;
          
          // Gunakan assignAll agar tampilan layar (UI) langsung ter-refresh
          studentData.assignAll(data); 

          // --- PERBAIKAN 2: PANGGIL FUNGSI RIWAYAT LENGKAP ---
          await _fetchAssessmentHistory(studentDoc.id);
        } else {
          // Jika kosong, pastikan layar menampilkan "Belum Terhubung"
          studentId.value = "";
          studentData.clear();
          assessmentHistory.clear();
          latestObservation.clear();
        }
      }
    } catch (e) {
      debugPrint("Error loading parent dashboard: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- PERBAIKAN 3: AMBIL DALAM BENTUK LIST AGAR KASAR & HALUS MUNCUL ---
  Future<void> _fetchAssessmentHistory(String sId) async {
    try {
      // A. Coba ambil dari subkoleksi 'riwayat' terlebih dahulu
      var subColSnapshot = await _firestore
          .collection('students')
          .doc(sId)
          .collection('riwayat')
          .orderBy('date', descending: true)
          .get();

      if (subColSnapshot.docs.isNotEmpty) {
        var historyList = subColSnapshot.docs.map((doc) {
          var data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();

        assessmentHistory.assignAll(historyList);
        latestObservation.assignAll(historyList.first);
      } else {
        // B. Fallback: Jika tersimpan di dalam array field 'riwayat'
        var doc = await _firestore.collection('students').doc(sId).get();
        if (doc.exists && doc.data()?['riwayat'] != null) {
          List<dynamic> historyArray = doc.data()!['riwayat'];
          if (historyArray.isNotEmpty) {
            List<Map<String, dynamic>> historyList = historyArray
                .map((e) => Map<String, dynamic>.from(e))
                .toList();

            historyList.sort((a, b) => (b['date'] ?? "").compareTo(a['date'] ?? ""));
            
            assessmentHistory.assignAll(historyList);
            latestObservation.assignAll(historyList.first);
          } else {
            assessmentHistory.clear();
            latestObservation.clear();
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching assessment history: $e");
    }
  }

  // --- FUNGSI MENGHUBUNGKAN TOKEN BARU DARI DASHBOARD ---
  void linkStudentToken() async {
    if (tokenC.text.trim().isEmpty) {
      Get.snackbar("Eits!", "Token tidak boleh kosong ya.", backgroundColor: Colors.orange.shade100);
      return;
    }

    try {
      isLinking.value = true;
      User? user = _auth.currentUser;
      if (user == null) return;

      var snapshot = await _firestore.collection('students')
          .where('token_ortu', isEqualTo: tokenC.text.trim())
          .get();

      if (snapshot.docs.isEmpty) {
        Get.snackbar("Gagal", "Token tidak ditemukan. Pastikan ketikan sesuai dari Guru.", backgroundColor: Colors.red.shade100);
        return;
      }

      var studentDoc = snapshot.docs.first;
      var dataAnak = studentDoc.data();

      if (dataAnak['parent_id'] != null && 
          dataAnak['parent_id'].toString().isNotEmpty && 
          dataAnak['parent_id'] != user.uid) {
        Get.snackbar("Gagal", "Token ini sudah digunakan oleh akun orang tua lain.", backgroundColor: Colors.orange.shade100);
        return;
      }

      await _firestore.collection('students').doc(studentDoc.id).update({'parent_id': user.uid});

      tokenC.clear();
      Get.back(); // Tutup Dialog
      
      Get.snackbar("Berhasil! 🎉", "Akun berhasil dihubungkan dengan data Ananda.", backgroundColor: Colors.green.shade100);
      
      // Muat ulang data dashboard
      loadDashboardData();

    } catch (e) {
      Get.snackbar("Error", "Gagal menghubungkan token: $e", backgroundColor: Colors.red.shade100);
    } finally {
      isLinking.value = false;
    }
  }

  String getSalam() {
    var hour = DateTime.now().hour;
    if (hour < 11) return "Selamat Pagi";
    if (hour < 15) return "Selamat Siang";
    if (hour < 18) return "Selamat Sore";
    return "Selamat Malam";
  }

  @override
  void onClose() {
    tokenC.dispose();
    super.onClose();
  }
}