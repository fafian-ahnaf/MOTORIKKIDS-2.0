import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StudentDetailController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  late String studentId;
  var studentName = "".obs;
  var studentAge = "".obs; 
  
  final activityNameC = TextEditingController();
  final notesC = TextEditingController();
  
  var selectedTab = 0.obs; 
  var selectedMotorikType = 'Halus'.obs;
  var inputScore = 75.0.obs; 
  var isLoading = false.obs;

  var fineMotorScore = 0.0.obs; 
  var grossMotorScore = 0.0.obs; 
  var fineMotorSum = 0.0.obs;   
  var grossMotorSum = 0.0.obs;  
  var currentStatus = "-".obs;

  var assessmentHistory = <Map<String, dynamic>>[].obs;   
  var recommendationHistory = <Map<String, dynamic>>[].obs; 

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
        monitorStudentData();      
        monitorRecommendations();  
      }
    }
  }

  void monitorStudentData() {
    firestore.collection('students').doc(studentId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data();
        
        // --- PERBAIKAN ERROR LIST UNMODIFIABLE ---
        List<dynamic> rawHistory = data?['riwayat'] ?? [];
        
        // Kita ubah list mentah menjadi List baru yang bisa dimodifikasi/di-sort
        List<Map<String, dynamic>> history = rawHistory.map((e) => Map<String, dynamic>.from(e)).toList();
        
        // Barulah kita urutkan dengan aman (Terbaru di atas)
        history.sort((a, b) => (b['date'] ?? "").compareTo(a['date'] ?? "")); 
        
        assessmentHistory.value = history;
        // -----------------------------------------

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

        fineMotorSum.value = totalFine;
        grossMotorSum.value = totalGross;

        fineMotorScore.value = countFine == 0 ? 0.0 : (totalFine / countFine) / 100;
        grossMotorScore.value = countGross == 0 ? 0.0 : (totalGross / countGross) / 100;
        
        if (data?['status'] != null) {
          currentStatus.value = data!['status'];
        }
      }
    }, onError: (e) {
      debugPrint("Error memantau data: $e");
    });
  }

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
        data['id'] = doc.id; 
        return data;
      }).toList();
    });
  }

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

        await _recalculateGlobalStatus(docRef);

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

  void _saveToFirebase({required Map<String, dynamic> newLog}) async {
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