import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http; 

class RecommendationController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  var recommendationData = <String, String>{}.obs;
  var isLoading = true.obs;

  late String _currentAge;
  late double _currentFineScore;
  late double _currentGrossScore;
  
  String? studentId;
  String role = ''; 

  // =========================================================
  // VARIABEL BARU KHUSUS FITUR ORANG TUA (CHECKLIST & FEEDBACK)
  // =========================================================
  var recommendationDocId = "".obs; 
  var isDoneByParent = false.obs;
  var parentFeedbackText = "".obs;
  final feedbackC = TextEditingController(); 

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    
    _currentAge = args['age'] ?? "5 Tahun";
    _currentFineScore = args['fineScore'] ?? 0.0;
    _currentGrossScore = args['grossScore'] ?? 0.0;
    studentId = args['studentId']; 
    role = args['role'] ?? ''; 

    if (role == 'parent') {
      fetchSavedRecommendation();
    } else {
      getNewRecommendation(); 
    }
  }

  String _generateObservationText(double fine, double gross) {
    String fineStatus = fine >= 75 ? "sudah baik" : "perlu dilatih lagi";
    String grossStatus = gross >= 75 ? "sudah sangat aktif" : "masih kaku";
    
    return "Anak berusia $_currentAge dengan kemampuan motorik halus yang $fineStatus dan kemampuan motorik kasar yang $grossStatus.";
  }

  void getNewRecommendation() async {
    isLoading.value = true;
    
    try {
      String teksObservasi = _generateObservationText(_currentFineScore, _currentGrossScore);
      final String apiUrl = "http://192.168.141.60:5000/predict";
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"teks": teksObservasi}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String statusNLP = data['data']['prediksi_status'] ?? "BSH"; 
        recommendationData.value = _mapStatusToActivity(statusNLP);
      } else {
        throw "Server Error: ${response.statusCode}";
      }
    } catch (e) {
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.snackbar("Kendala Koneksi", "Gagal terhubung ke API IndoBERT: $e", 
          backgroundColor: Colors.red.shade100);
      });
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, String> _mapStatusToActivity(String status) {
    if (status == "BB") {
      return {
        "title": "Bermain Penuh Kasih Sayang 🧸",
        "desc": "Ananda masih dalam tahap pengenalan gerak. Pendampingan penuh sangat diperlukan di tahap ini.",
        "tujuan": "Membangun rasa percaya diri dan kesadaran gerak tubuh Ananda.",
        "cara": "Sambil bernyanyi, pegang tangan Ananda dan bimbing perlahan untuk menggenggam benda atau merenggangkan otot.",
        "durasi": "10 Menit",
        "lokasi": "Dalam Ruangan yang Nyaman",
      };
    } else if (status == "MB") {
      return {
        "title": "Langkah Kecil Ceria! 🎈",
        "desc": "Hebat! Ananda sudah mulai berani mencoba. Mari kita beri dorongan agar ia makin mandiri.",
        "tujuan": "Melatih kekuatan genggaman dasar dan tumpuan kaki Ananda.",
        "cara": "Ajak Ananda menyusun 3 buah balok warna-warni, atau berlatih menendang bola yang diam.",
        "durasi": "15 Menit",
        "lokasi": "Halaman Rumah / Kelas",
      };
    } else if (status == "BSH") {
      return {
        "title": "Petualangan Si Aktif! 🚀",
        "desc": "Keren! Kemampuan motorik Ananda sudah sangat sesuai dengan usianya. Waktunya bermain lebih seru!",
        "tujuan": "Memantapkan keseimbangan, fokus, dan koordinasi mata-tangan.",
        "cara": "Buat garis lurus di lantai untuk dititi Ananda, atau ajak mewarnai gambar berukuran besar bersama.",
        "durasi": "20 Menit",
        "lokasi": "Taman Bermain / Luar Ruangan",
      };
    } else { 
      return {
        "title": "Tantangan Bintang Cilik! 🌟",
        "desc": "Luar biasa! Motorik Ananda berkembang sangat pesat dan melampaui rata-rata. Ia butuh permainan yang menantang.",
        "tujuan": "Mengasah ketangkasan tingkat lanjut dan kreativitas gerakan mandiri.",
        "cara": "Bersepeda roda tiga menghindari rintangan, atau menggunting kertas dengan pola garis berkelok/zig-zag.",
        "durasi": "30 Menit",
        "lokasi": "Area Terbuka / Lapangan Luas",
      };
    }
  }

  void fetchSavedRecommendation() async {
    isLoading.value = true;
    if (studentId != null) {
      try {
        var snapshot = await firestore
            .collection('students')
            .doc(studentId)
            .collection('recommendations')
            .orderBy('date', descending: true)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          var doc = snapshot.docs.first;
          var data = doc.data();
          
          // --- AMBIL DATA STATUS PENGERJAAN ORANG TUA ---
          recommendationDocId.value = doc.id;
          isDoneByParent.value = data['is_done'] ?? false;
          parentFeedbackText.value = data['parent_feedback'] ?? "";
          // ----------------------------------------------

          recommendationData.value = {
            "title": data['title']?.toString() ?? "",
            "desc": data['desc']?.toString() ?? "",
            "tujuan": data['tujuan']?.toString() ?? "",
            "cara": data['cara']?.toString() ?? "",
            "durasi": data['durasi']?.toString() ?? "",
            "lokasi": data['lokasi']?.toString() ?? "",
          };
        } else {
          recommendationData.value = {
            "title": "Belum Ada Saran Bermain 🍃",
            "desc": "Guru belum membuat rekomendasi aktivitas motorik untuk Ananda saat ini. Coba kembali lagi nanti ya!",
            "tujuan": "-",
            "cara": "-",
            "durasi": "-",
            "lokasi": "-",
          };
        }
      } catch (e) {
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.snackbar("Error", "Gagal mengambil data saran: $e");
        });
      }
    }
    isLoading.value = false;
  }

  // --- FUNGSI GURU: SIMPAN REKOMENDASI (Default is_done = false) ---
  void markAsDone() async {
    if (studentId != null && recommendationData.isNotEmpty) {
      try {
        await firestore
            .collection('students')
            .doc(studentId)
            .collection('recommendations') 
            .add({
          ...recommendationData, 
          'date': DateTime.now().toIso8601String(), 
          'is_done': false, // Menunggu dikerjakan oleh orang tua
          'parent_feedback': '', // Tempat kosong untuk ulasan orang tua
        });

        Get.back();
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.snackbar(
            "Hebat! 🎉", 
            "Saran aktivitas berhasil disimpan dan dikirim ke Orang Tua!", 
            backgroundColor: Colors.green.shade400, 
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP
          ); 
        });
      } catch (e) {
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.snackbar("Gagal", "Yaaah, gagal menyimpan data: $e");
        });
      }
    } else {
      Get.back(); 
    }
  }

  // --- FUNGSI ORANG TUA: TANDAI SELESAI & KIRIM CATATAN ---
  void submitParentFeedback() async {
    if (recommendationDocId.value.isNotEmpty && studentId != null) {
      try {
        isLoading.value = true;
        await firestore
            .collection('students')
            .doc(studentId)
            .collection('recommendations')
            .doc(recommendationDocId.value)
            .update({
          'is_done': true,
          'parent_feedback': feedbackC.text.trim(),
          'completed_at': DateTime.now().toIso8601String(),
        });
        
        // Update UI seketika tanpa harus reload
        isDoneByParent.value = true;
        parentFeedbackText.value = feedbackC.text.trim();
        
        Get.snackbar(
          "Terima Kasih! 🎉", 
          "Aktivitas telah ditandai selesai. Guru akan melihat catatan Anda.", 
          backgroundColor: Colors.green.shade500, 
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
      } catch (e) {
        Get.snackbar("Gagal", "Terjadi kesalahan saat mengirim: $e", backgroundColor: Colors.red.shade100);
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    feedbackC.dispose();
    super.onClose();
  }
}