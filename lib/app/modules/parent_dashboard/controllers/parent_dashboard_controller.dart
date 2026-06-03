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

  var latestObservation = <String, dynamic>{}.obs;

  // --- VARIABEL UNTUK POP-UP TOKEN ---
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
        var userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          parentName.value = userDoc.data()?['nama_lengkap'] ?? "Bunda/Ayah";
          studentId.value = userDoc.data()?['linked_student_id'] ?? ""; 
        }

        if (studentId.value.isNotEmpty) {
          var studentDoc = await _firestore.collection('students').doc(studentId.value).get();
          if (studentDoc.exists) {
            var data = studentDoc.data()!;
            data['id'] = studentDoc.id;
            studentData.value = data;

            await _fetchLatestObservation(studentDoc.id);
          }
        }
      }
    } catch (e) {
      print("Error loading parent dashboard: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchLatestObservation(String sId) async {
    try {
      var subColSnapshot = await _firestore.collection('students')
          .doc(sId).collection('riwayat').orderBy('date', descending: true).limit(1).get();

      if (subColSnapshot.docs.isNotEmpty) {
        latestObservation.value = subColSnapshot.docs.first.data();
      } else {
        var doc = await _firestore.collection('students').doc(sId).get();
        if (doc.exists && doc.data()?['riwayat'] != null) {
          List<dynamic> historyArray = doc.data()!['riwayat'];
          if (historyArray.isNotEmpty) {
            historyArray.sort((a, b) => (b['date'] ?? "").compareTo(a['date'] ?? ""));
            latestObservation.value = Map<String, dynamic>.from(historyArray.first);
          }
        }
      }
    } catch (e) {
      print("Error fetching latest observation: $e");
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

      if (dataAnak['parent_id'] != null && dataAnak['parent_id'].toString().isNotEmpty && dataAnak['parent_id'] != user.uid) {
        Get.snackbar("Gagal", "Token ini sudah digunakan oleh akun orang tua lain.", backgroundColor: Colors.orange.shade100);
        return;
      }

      await _firestore.collection('users').doc(user.uid).update({'linked_student_id': studentDoc.id});
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