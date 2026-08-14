import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http; 

class StudentDetailController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  late String studentId;
  var studentName = "".obs;
  var studentAge = "".obs; 
  String role = 'teacher'; 
  
  final activityNameC = TextEditingController();
  final notesC = TextEditingController();
  
  var selectedTab = 0.obs; 
  var selectedMotorikType = 'Halus'.obs;
  var inputScore = 75.0.obs; 
  var isLoading = false.obs;

  var inputMode = 'manual'.obs;
  var aiStatusResult = "".obs;
  var isAiAnalyzed = false.obs;

  var fineMotorScore = 0.0.obs; 
  var grossMotorScore = 0.0.obs; 
  var fineMotorSum = 0.0.obs;   
  var grossMotorSum = 0.0.obs;  
  var currentStatus = "-".obs;

  var activeTeacherName = "Guru Kelas".obs;

  var assessmentHistory = <Map<String, dynamic>>[].obs;     
  var recommendationHistory = <Map<String, dynamic>>[].obs; 

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      studentId = args['id'] ?? args['studentId'] ?? ""; 
      studentName.value = args['name'] ?? "";
      studentAge.value = args['age'] ?? "5 Tahun";
      currentStatus.value = args['status'] ?? "-";
      role = args['role'] ?? 'teacher';
      
      if (studentId.isNotEmpty) {
        monitorStudentData();      
        monitorRecommendations();  
      }
    }

    fetchActiveTeacherName();
  }

  // ===========================================================================
  // FILTER ROLE: PASTIKAN YANG MENYIMPAN ADALAH AKUN GURU, BUKAN ORANG TUA
  // ===========================================================================
  void fetchActiveTeacherName() async {
    try {
      User? user = auth.currentUser;
      if (user != null) {
        var doc = await firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          String roleUser = (doc.data()!['role'] ?? '').toString().toLowerCase();
          bool isParent = roleUser == 'parent' || roleUser == 'ortu' || roleUser == 'orang_tua';

          // Jika yang login BUKAN orang tua, ambil namanya
          if (!isParent) {
            String nama = doc.data()!['name'] ?? 
                          doc.data()!['nama'] ?? 
                          doc.data()!['nama_lengkap'] ?? 
                          user.displayName ?? 
                          "Guru Kelas";
            if (nama.trim().isNotEmpty) {
              activeTeacherName.value = nama;
            }
          } else {
            activeTeacherName.value = "Guru Kelas";
          }
        }
      }
    } catch (e) {
      debugPrint("Gagal ambil nama guru: $e");
    }
  }

  String _getCurrentTeacherName() {
    return activeTeacherName.value;
  }

  void monitorStudentData() {
    firestore.collection('students').doc(studentId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data();
        
        List<dynamic> rawHistory = data?['riwayat'] ?? [];
        
        List<Map<String, dynamic>> history = rawHistory.map((e) {
          var map = Map<String, dynamic>.from(e);
          String rawStatus = (map['status'] ?? "").toString().trim();
          double score = (map['score'] ?? 0).toDouble();
          
          if (rawStatus.isEmpty || 
              rawStatus == "-" || 
              rawStatus.toLowerCase().contains("belum dinilai")) {
            map['status'] = _getPAUDScaleLabel(score);
          } else {
            map['status'] = _expandStatusName(rawStatus);
          }

          if (map['teacher_name'] == null || 
              map['teacher_name'].toString().isEmpty || 
              map['teacher_name'] == "Guru Kelas") {
            map['teacher_name'] = _getCurrentTeacherName();
          }

          return map;
        }).toList();
        
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
          currentStatus.value = _expandStatusName(data!['status']);
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

  void hitungNilaiAIOtomatis({bool langsungSimpan = false}) async {
    if (activityNameC.text.isEmpty) {
      Get.snackbar("Gagal", "Silakan pilih minimal 1 kegiatan stimulasi.", backgroundColor: Colors.orange.shade100, snackPosition: SnackPosition.TOP);
      return;
    }
    if (notesC.text.trim().isEmpty) {
      Get.snackbar("Gagal", "Silakan isi deskripsi anekdot terlebih dahulu.", backgroundColor: Colors.orange.shade100, snackPosition: SnackPosition.TOP);
      return;
    }

    try {
      isLoading.value = true;
      String teksObservasi = notesC.text.trim();

      final response = await http.post(
        Uri.parse("https://motorikkids.my.id/predict"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"teks": teksObservasi}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        String rawStatusNLP = data['data']?['prediksi_status'] ?? 
                              data['data']?['status'] ?? 
                              data['prediksi_status'] ?? 
                              data['status'] ?? 
                              "";

        String kategoriNLP = data['data']?['prediksi_kategori'] ?? 
                             data['data']?['kategori'] ?? 
                             selectedMotorikType.value; 

        if (kategoriNLP == "Tidak Ditemukan" || 
            kategoriNLP == "Kategori Tidak Ditemukan" || 
            kategoriNLP == "Unknown" || 
            kategoriNLP.isEmpty) {
          isLoading.value = false;
          Get.snackbar(
            "Kategori Tidak Ditemukan ⚠️", 
            "Kalimat tidak mendeskripsikan aktivitas motorik secara spesifik. Tolong perjelas catatan observasi Anda.",
            backgroundColor: Colors.orange.shade100,
            colorText: Colors.orange.shade900,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 4),
          );
          return;
        }

        String statusNLP = (rawStatusNLP.isEmpty || rawStatusNLP.toLowerCase().contains("belum dinilai"))
            ? _getPAUDScaleLabel(inputScore.value)
            : rawStatusNLP;

        String fullStatus = _expandStatusName(statusNLP);
        double skorOtomatis = _konversiStatusKeSkor(fullStatus);
        
        inputScore.value = skorOtomatis;
        aiStatusResult.value = fullStatus;
        isAiAnalyzed.value = true;
        isLoading.value = false;

        if (langsungSimpan) {
          _saveToFirebase(
            newLog: {
              'type': selectedMotorikType.value,
              'activity': activityNameC.text,
              'notes': teksObservasi,
              'score': skorOtomatis,
              'status': fullStatus,
              'teacher_name': _getCurrentTeacherName(),
              'date': DateTime.now().toIso8601String(),
            }
          );
        } else {
          Get.snackbar(
            "Nilai Observasi Berhasil Muncul! ✨", 
            "Sistem menilai capaian Ananda: $fullStatus ($skorOtomatis poin).", 
            backgroundColor: Colors.green.shade600,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }

      } else {
        throw "Server Error: ${response.statusCode}";
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Gagal memproses data dengan AI: $e", backgroundColor: Colors.red.shade100, snackPosition: SnackPosition.TOP);
    }
  }

  String _expandStatusName(String rawStatus) {
    String s = rawStatus.toUpperCase();
    if (s.contains("BSB") || s.contains("SANGAT") || s.contains("BAIK")) {
      return "Berkembang Sangat Baik (BSB)";
    }
    if (s.contains("BSH") || s.contains("HARAPAN") || s.contains("SESUAI")) {
      return "Berkembang Sesuai Harapan (BSH)";
    }
    if (s.contains("MB") || s.contains("MULAI")) {
      return "Mulai Berkembang (MB)";
    }
    if (s.contains("BB") || s.contains("BELUM") || s.contains("PENDAMPINGAN")) {
      return "Belum Berkembang (BB)";
    }
    return rawStatus;
  }

  double _konversiStatusKeSkor(String status) {
    String s = status.toUpperCase();
    if (s.contains("BSB") || s.contains("SANGAT")) return 88.0;
    if (s.contains("BSH") || s.contains("HARAPAN")) return 68.0;
    if (s.contains("MB") || s.contains("MULAI")) return 40.0;
    return 18.0;
  }

  void simpanObservasiBaru() {
    if (activityNameC.text.isEmpty) {
      Get.snackbar("Gagal", "Silakan pilih minimal 1 kegiatan stimulasi.", backgroundColor: Colors.orange.shade100, snackPosition: SnackPosition.TOP);
      return;
    }
    if (notesC.text.trim().isEmpty) {
      Get.snackbar("Gagal", "Silakan lengkapi deskripsi observasi terlebih dahulu.", backgroundColor: Colors.orange.shade100, snackPosition: SnackPosition.TOP);
      return;
    }

    String status = aiStatusResult.value.isNotEmpty 
        ? aiStatusResult.value 
        : _getPAUDScaleLabel(inputScore.value);

    _saveToFirebase(
      newLog: {
        'type': selectedMotorikType.value,
        'activity': activityNameC.text,
        'notes': notesC.text.trim(),
        'score': inputScore.value,
        'status': _expandStatusName(status),
        'teacher_name': _getCurrentTeacherName(),
        'date': DateTime.now().toIso8601String(),
      }
    );
  }

  void updateAssessment(Map<String, dynamic> oldData) async {
    if (activityNameC.text.isNotEmpty) {
      String status = aiStatusResult.value.isNotEmpty 
          ? aiStatusResult.value 
          : _getPAUDScaleLabel(inputScore.value);

      Map<String, dynamic> newData = {
        'type': selectedMotorikType.value,
        'activity': activityNameC.text,
        'notes': notesC.text,
        'score': inputScore.value,
        'status': _expandStatusName(status),
        'teacher_name': oldData['teacher_name'] ?? _getCurrentTeacherName(),
        'date': oldData['date'], 
      };

      try {
        isLoading.value = true;
        var docRef = firestore.collection('students').doc(studentId);
        
        await docRef.update({'riwayat': FieldValue.arrayRemove([oldData])});
        await docRef.update({'riwayat': FieldValue.arrayUnion([newData])});

        await _recalculateGlobalStatus(docRef);

        isLoading.value = false;

        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        _clearForm();

        Get.snackbar(
          "Sukses! 🎉", 
          "Data observasi berhasil diperbarui.", 
          backgroundColor: Colors.green.shade600, 
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

      } catch (e) {
        isLoading.value = false;
        Get.snackbar("Error", "Gagal update: $e", backgroundColor: Colors.red.shade100, snackPosition: SnackPosition.TOP);
      }
    }
  }

  void deleteAssessment(Map<String, dynamic> itemToDelete) async {
    try {
      isLoading.value = true;
      var docRef = firestore.collection('students').doc(studentId);

      await docRef.update({
        'riwayat': FieldValue.arrayRemove([itemToDelete])
      });

      await _recalculateGlobalStatus(docRef);

      isLoading.value = false;
      Get.snackbar(
        "Berhasil Dihapus! 🗑️", 
        "Catatan observasi Ananda berhasil dihapus.", 
        backgroundColor: Colors.green.shade600, 
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error", 
        "Gagal menghapus catatan: $e", 
        backgroundColor: Colors.red.shade100, 
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void _saveToFirebase({required Map<String, dynamic> newLog}) async {
    try {
      var docRef = firestore.collection('students').doc(studentId);

      await docRef.update({
        'riwayat': FieldValue.arrayUnion([newLog]),
      });

      await _recalculateGlobalStatus(docRef);

      isLoading.value = false;

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      _clearForm();

      Get.snackbar(
        "Sukses! 🎉", 
        "Data observasi berhasil disimpan ke sistem.", 
        backgroundColor: Colors.green.shade600, 
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Gagal menyimpan ke Firebase: $e", backgroundColor: Colors.red.shade100, snackPosition: SnackPosition.TOP);
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
    inputMode.value = 'manual';
    aiStatusResult.value = "";
    isAiAnalyzed.value = false;
  }

  String _getPAUDScaleLabel(double score) {
    if (score >= 76) return "Berkembang Sangat Baik (BSB)";
    if (score >= 51) return "Berkembang Sesuai Harapan (BSH)";
    if (score >= 26) return "Mulai Berkembang (MB)";
    return "Belum Berkembang (BB)";
  }

  String formatDate(String isoString) {
    try {
      DateTime date = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return "-";
    }
  }

  int hitungUsiaBulan(String ageString) {
    int totalBulan = 40; 
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