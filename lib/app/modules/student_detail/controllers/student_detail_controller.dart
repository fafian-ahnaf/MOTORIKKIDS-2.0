import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StudentDetailController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  late String studentId;
  var studentName = "".obs;
  
  // Input Controllers
  final activityNameC = TextEditingController();
  final notesC = TextEditingController();
  
  var selectedMotorikType = 'Halus'.obs;
  var inputScore = 75.0.obs; 

  // Observables Realtime
  var fineMotorScore = 0.0.obs; // Rata-rata (0.0 - 1.0)
  var grossMotorScore = 0.0.obs; // Rata-rata (0.0 - 1.0)
  
  // --- NEW: TOTAL SCORE (PENJUMLAHAN) ---
  var fineMotorSum = 0.0.obs; // Total Poin Halus
  var grossMotorSum = 0.0.obs; // Total Poin Kasar
  
  var currentStatus = "-".obs;
  var isLoading = false.obs;

  // List Riwayat
  var assessmentHistory = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      studentId = args['id'] ?? ""; 
      studentName.value = args['name'] ?? "";
      currentStatus.value = args['status'] ?? "-";
      
      if (studentId.isNotEmpty) {
        monitorStudentData(); 
      }
    }
  }

  void monitorStudentData() {
    firestore.collection('students').doc(studentId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data();
        
        // 1. Ambil & Sort Riwayat
        List<dynamic> history = data?['riwayat'] ?? [];
        history.sort((a, b) => b['date'].compareTo(a['date']));
        assessmentHistory.value = history.map((e) => e as Map<String, dynamic>).toList();

        // 2. Hitung Total & Rata-rata
        double totalFine = 0;
        double totalGross = 0;
        int countFine = 0;
        int countGross = 0;

        for (var item in history) {
          double score = (item['score'] ?? 0).toDouble();
          if (item['type'] == 'Halus') {
            totalFine += score; // Dijumlahkan
            countFine++;
          } else {
            totalGross += score; // Dijumlahkan
            countGross++;
          }
        }

        // Simpan Total Poin (Untuk ditampilkan sebagai Jumlah)
        fineMotorSum.value = totalFine;
        grossMotorSum.value = totalGross;

        // Simpan Rata-rata Persentase (Untuk Progress Bar 0.0 - 1.0)
        fineMotorScore.value = countFine == 0 ? 0.0 : (totalFine / countFine) / 100;
        grossMotorScore.value = countGross == 0 ? 0.0 : (totalGross / countGross) / 100;
        
        if (data?['status'] != null) {
          currentStatus.value = data!['status'];
        }
      }
    });
  }

  // --- ADD & UPDATE LOGIC SAMA SEPERTI SEBELUMNYA ---
  
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
        isEdit: false,
      );
    } else {
       Get.snackbar("Gagal", "Nama Kegiatan kosong", backgroundColor: Colors.orange);
    }
  }

  void updateAssessment(Map<String, dynamic> oldData) async {
    if (activityNameC.text.isNotEmpty) {
      Map<String, dynamic> newData = {
        'type': selectedMotorikType.value,
        'activity': activityNameC.text,
        'notes': notesC.text,
        'score': inputScore.value,
        'date': oldData['date'], 
      };

      try {
        isLoading.value = true;
        var docRef = firestore.collection('students').doc(studentId);
        
        await docRef.update({'riwayat': FieldValue.arrayRemove([oldData])});
        await docRef.update({'riwayat': FieldValue.arrayUnion([newData])});

        _recalculateGlobalStatus(docRef);

        isLoading.value = false;
        Get.back();
        _clearForm();
        Get.snackbar("Sukses", "Data berhasil diubah!", backgroundColor: Colors.green, colorText: Colors.white);
      } catch (e) {
        isLoading.value = false;
        Get.snackbar("Error", "Gagal update: $e", backgroundColor: Colors.red);
      }
    }
  }

  void _saveToFirebase({required Map<String, dynamic> newLog, required bool isEdit}) async {
    try {
      isLoading.value = true;
      var docRef = firestore.collection('students').doc(studentId);

      await docRef.update({
        'riwayat': FieldValue.arrayUnion([newLog]),
      });

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

  Future<void> _recalculateGlobalStatus(DocumentReference docRef) async {
    String newStatus = "Perlu Latihan";
    if (inputScore.value >= 85) newStatus = "Sangat Baik";
    else if (inputScore.value >= 70) newStatus = "Baik";
    else if (inputScore.value >= 55) newStatus = "Cukup";
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