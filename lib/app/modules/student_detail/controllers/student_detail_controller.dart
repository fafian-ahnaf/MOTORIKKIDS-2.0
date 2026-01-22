import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StudentDetailController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Data Siswa
  late String studentId;
  var studentName = "".obs;
  var studentAge = "".obs; // Disimpan untuk dikirim ke AI nanti
  
  // Input Controllers (Form)
  final activityNameC = TextEditingController();
  final notesC = TextEditingController();
  
  // State UI
  var selectedTab = 0.obs; // 0 = Riwayat Nilai, 1 = Saran AI
  var selectedMotorikType = 'Halus'.obs;
  var inputScore = 75.0.obs; 
  var isLoading = false.obs;

  // --- OBSERVABLES DATA (REALTIME) ---
  
  // 1. Statistik Motorik
  var fineMotorScore = 0.0.obs; // Rata-rata (0.0 - 1.0) untuk Progress Bar
  var grossMotorScore = 0.0.obs; 
  var fineMotorSum = 0.0.obs;   // Total Poin (Angka) untuk Teks
  var grossMotorSum = 0.0.obs;  
  var currentStatus = "-".obs;

  // 2. List Data
  var assessmentHistory = <Map<String, dynamic>>[].obs;   // List Input Manual
  var recommendationHistory = <Map<String, dynamic>>[].obs; // List Saran AI Tersimpan

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      studentId = args['id'] ?? ""; 
      studentName.value = args['name'] ?? "";
      studentAge.value = args['age'] ?? "5 Tahun";
      currentStatus.value = args['status'] ?? "-";
      
      if (studentId.isNotEmpty) {
        monitorStudentData();      // Pantau Nilai & Status
        monitorRecommendations();  // Pantau Saran AI
      }
    }
  }

  // ==========================================================
  //      🔥 1. MONITOR NILAI & RIWAYAT MANUAL (ARRAY) 🔥
  // ==========================================================
  void monitorStudentData() {
    firestore.collection('students').doc(studentId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data();
        
        // A. Ambil & Sortir Riwayat
        List<dynamic> history = data?['riwayat'] ?? [];
        history.sort((a, b) => b['date'].compareTo(a['date'])); // Terbaru diatas
        assessmentHistory.value = history.map((e) => e as Map<String, dynamic>).toList();

        // B. Hitung Statistik (Total & Rata-rata)
        double totalFine = 0;
        double totalGross = 0;
        int countFine = 0;
        int countGross = 0;

        for (var item in history) {
          double score = (item['score'] ?? 0).toDouble();
          if (item['type'] == 'Halus') {
            totalFine += score;
            countFine++;
          } else {
            totalGross += score;
            countGross++;
          }
        }

        // Set Nilai Total (Untuk Teks: "150 Poin")
        fineMotorSum.value = totalFine;
        grossMotorSum.value = totalGross;

        // Set Nilai Rata-rata (Untuk Progress Bar: 0.0 - 1.0)
        // Jika belum ada data, set 0
        fineMotorScore.value = countFine == 0 ? 0.0 : (totalFine / countFine) / 100;
        grossMotorScore.value = countGross == 0 ? 0.0 : (totalGross / countGross) / 100;
        
        // C. Update Status Global (Jika ada perubahan dari database)
        if (data?['status'] != null) {
          currentStatus.value = data!['status'];
        }
      }
    });
  }

  // ==========================================================
  //      🤖 2. MONITOR RIWAYAT SARAN AI (SUB-COLLECTION) 🤖
  // ==========================================================
  void monitorRecommendations() {
    firestore
        .collection('students')
        .doc(studentId)
        .collection('recommendations')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      recommendationHistory.value = snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id; // Simpan ID dokumen
        return data;
      }).toList();
    });
  }

  // ==========================================================
  //      📝 3. CRUD: TAMBAH & UPDATE PENILAIAN 📝
  // ==========================================================
  
  // Tambah Data Baru
  void addAssessment() async {
    if (activityNameC.text.isNotEmpty && studentId.isNotEmpty) {
      _saveToFirebase(
        newLog: {
          'type': selectedMotorikType.value,
          'activity': activityNameC.text,
          'notes': notesC.text,
          'score': inputScore.value,
          'date': DateTime.now().toIso8601String(),
        },
      );
    } else {
       Get.snackbar("Gagal", "Nama Kegiatan wajib diisi", backgroundColor: Colors.orange);
    }
  }

  // Update Data Lama
  void updateAssessment(Map<String, dynamic> oldData) async {
    if (activityNameC.text.isNotEmpty) {
      Map<String, dynamic> newData = {
        'type': selectedMotorikType.value,
        'activity': activityNameC.text,
        'notes': notesC.text,
        'score': inputScore.value,
        'date': oldData['date'], // Pertahankan tanggal asli
      };

      try {
        isLoading.value = true;
        var docRef = firestore.collection('students').doc(studentId);
        
        // Hapus data lama dari Array, lalu masukkan data baru
        // (Firestore Array tidak bisa update index spesifik, jadi harus remove-add)
        await docRef.update({'riwayat': FieldValue.arrayRemove([oldData])});
        await docRef.update({'riwayat': FieldValue.arrayUnion([newData])});

        // Update status siswa berdasarkan nilai terbaru
        await _recalculateGlobalStatus(docRef);

        isLoading.value = false;
        Get.back(); // Tutup Dialog
        _clearForm();
        Get.snackbar("Sukses", "Data berhasil diubah!", backgroundColor: Colors.green, colorText: Colors.white);
      } catch (e) {
        isLoading.value = false;
        Get.snackbar("Error", "Gagal update: $e", backgroundColor: Colors.red);
      }
    }
  }

  // Helper Simpan ke Firebase
  void _saveToFirebase({required Map<String, dynamic> newLog}) async {
    try {
      isLoading.value = true;
      var docRef = firestore.collection('students').doc(studentId);

      // Masukkan ke Array 'riwayat'
      await docRef.update({
        'riwayat': FieldValue.arrayUnion([newLog]),
      });

      // Hitung ulang status
      await _recalculateGlobalStatus(docRef);

      isLoading.value = false;
      Get.back();
      _clearForm();
      Get.snackbar("Sukses", "Data berhasil disimpan!", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "$e", backgroundColor: Colors.red);
    }
  }

  // ==========================================================
  //      ⚙️ 4. HELPER FUNCTIONS ⚙️
  // ==========================================================

  // Update Status Siswa (Label di Depan)
  Future<void> _recalculateGlobalStatus(DocumentReference docRef) async {
    String newStatus = "Perlu Latihan";
    if (inputScore.value >= 85) newStatus = "Sangat Baik";
    else if (inputScore.value >= 70) newStatus = "Baik";
    else if (inputScore.value >= 55) newStatus = "Cukup";
    
    // Hanya update field 'status'
    await docRef.update({'status': newStatus});
  }

  void _clearForm() {
    activityNameC.clear();
    notesC.clear();
    inputScore.value = 75.0;
  }

  String getScoreLabel(double value) {
    if (value >= 85) return "Sangat Baik";
    if (value >= 70) return "Baik";
    if (value >= 55) return "Cukup";
    return "Kurang";
  }

  String formatDate(String isoString) {
    try {
      DateTime date = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return "-";
    }
  }
  
  @override
  void onClose() {
    activityNameC.dispose();
    notesC.dispose();
    super.onClose();
  }
}