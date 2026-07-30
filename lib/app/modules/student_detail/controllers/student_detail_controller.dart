import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http; 

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
        
        List<dynamic> rawHistory = data?['riwayat'] ?? [];
        
        List<Map<String, dynamic>> history = rawHistory.map((e) => Map<String, dynamic>.from(e)).toList();
        
        history.sort((a, b) => (b['date'] ?? "").compareTo(a['date'] ?? "")); 
        
        assessmentHistory.value = history;

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

  // =========================================================================
  // --- FUNGSI MENGHUBUNGKAN APLIKASI DENGAN AI INDOBERT (REVISI PENGUJI) ---
  // =========================================================================
  void prosesAnalisisAI() async {
    if (activityNameC.text.isEmpty) {
      Get.snackbar("Gagal", "Silakan isi nama kegiatan terlebih dahulu.", backgroundColor: Colors.orange.shade100);
      return;
    }

    try {
      isLoading.value = true;
      String teksObservasi = notesC.text.trim(); // Ambil teks dari input guru

      final response = await http.post(
        Uri.parse("https://motorikkids.my.id/predict"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"teks": teksObservasi}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        String statusNLP = data['data']['prediksi_status'] ?? "Belum Dinilai"; 
        String kategoriNLP = data['data']['prediksi_kategori'] ?? "Tidak Ditemukan"; 

        // --- PROTEKSI DOSEN PENGUJI: KATEGORI TIDAK DITEMUKAN ---
        if (kategoriNLP == "Tidak Ditemukan") {
          isLoading.value = false;
          Get.snackbar(
            "Gagal Dianalisis 🤔", 
            "Kalimat tidak mendeskripsikan aktivitas motorik halus atau kasar secara spesifik. Tolong perjelas catatan Anda.",
            backgroundColor: Colors.orange.shade200,
            duration: const Duration(seconds: 5),
          );
          return; // Hentikan eksekusi, biarkan popup tetap terbuka
        }

        // --- JIKA BERHASIL: SIMPAN KE FIREBASE MENGGUNAKAN DATA AI ---
        _saveToFirebase(
          newLog: {
            'type': kategoriNLP, // Disimpan otomatis berdasarkan tebakan kategori AI!
            'activity': activityNameC.text,
            'notes': teksObservasi,
            'score': inputScore.value,
            'status': statusNLP, // Disimpan otomatis berdasarkan tebakan status AI!
            'date': DateTime.now().toIso8601String(),
          }
        );

      } else {
        throw "Server Error: ${response.statusCode}";
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Gagal memproses data dengan AI: $e", backgroundColor: Colors.red.shade100);
    }
  }

  // --- FUNGSI UPDATE DATA (EDIT) ---
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
        Get.back(); // --- PERBAIKAN UX: TUTUP POPUP ---
        _clearForm();
        Get.snackbar("Sukses", "Data berhasil diubah!", backgroundColor: Colors.green, colorText: Colors.white);
      } catch (e) {
        isLoading.value = false;
        Get.snackbar("Error", "Gagal update: $e", backgroundColor: Colors.red);
      }
    }
  }

  // --- FUNGSI INTERNAL UNTUK MENYIMPAN RIWAYAT ---
  void _saveToFirebase({required Map<String, dynamic> newLog}) async {
    try {
      var docRef = firestore.collection('students').doc(studentId);

      await docRef.update({
        'riwayat': FieldValue.arrayUnion([newLog]),
      });

      await _recalculateGlobalStatus(docRef);

      isLoading.value = false;
      Get.back(); // --- PERBAIKAN UX: TUTUP POPUP ---
      _clearForm();
      Get.snackbar("Sukses! 🎉", "Data observasi berhasil disimpan.", backgroundColor: Colors.green.shade400, colorText: Colors.white);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Gagal menyimpan ke Firebase: $e", backgroundColor: Colors.red);
    }
  }
  
  Future<void> _recalculateGlobalStatus(DocumentReference docRef) async {
    String newStatus = "Belum Berkembang (BB)";
    if (inputScore.value >= 76) newStatus = "Berkembang Sangat Baik (BSB)";
    else if (inputScore.value >= 51) newStatus = "Berkembang Sesuai Harapan (BSH)";
    else if (inputScore.value >= 26) newStatus = "Mulai Berkembang (MB)";
    
    await docRef.update({'status': newStatus});
  }

  void _clearForm() {
    activityNameC.clear();
    notesC.clear();
    inputScore.value = 75.0;
  }

  String formatDate(String isoString) {
    try {
      DateTime date = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return "-";
    }
  }

  // =========================================================================
  // --- FUNGSI MENGUBAH TEKS JADI ANGKA BULAN (VERSI LEBIH PINTAR / REGEX) ---
  // =========================================================================
  int hitungUsiaBulan(String ageString) {
    int totalBulan = 40; // Default jika gagal
    try {
      String str = ageString.toLowerCase();
      int tahun = 0;
      int bulan = 0;

      RegExp tahunRegex = RegExp(r'(\d+)\s*(tahun|thn)');
      var tahunMatch = tahunRegex.firstMatch(str);
      if (tahunMatch != null) {
        tahun = int.parse(tahunMatch.group(1) ?? '0');
      }

      RegExp bulanRegex = RegExp(r'(\d+)\s*(bulan|bln)');
      var bulanMatch = bulanRegex.firstMatch(str);
      if (bulanMatch != null) {
        bulan = int.parse(bulanMatch.group(1) ?? '0');
      }

      totalBulan = (tahun * 12) + bulan;
      return totalBulan == 0 ? 40 : totalBulan;
    } catch (e) {
      return 40;
    }
  }
  
  @override
  void onClose() {
    activityNameC.dispose();
    notesC.dispose();
    super.onClose();
  }
}