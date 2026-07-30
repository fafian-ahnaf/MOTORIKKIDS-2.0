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
  // VARIABEL KHUSUS FITUR ORANG TUA (CHECKLIST & FEEDBACK)
  // =========================================================
  var recommendationDocId = "".obs; 
  var isDoneByParent = false.obs;
  var parentFeedbackText = "".obs;
  final feedbackC = TextEditingController(); 

  // --- TAMBAHAN REVISI: VARIABEL RIWAYAT UNTUK ORANG TUA ---
  var assessmentHistory = <Map<String, dynamic>>[].obs;

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
      fetchAssessmentHistory(); // <-- Memanggil riwayat aktivitas untuk Orang Tua
    } else {
      getNewRecommendation(); 
    }
  }

  // --- MENGUBAH TEKS UMUR JADI BULAN (REGEX) ---
  int _hitungUsiaBulanPintar(String ageString) {
    int totalBulan = 40; 
    try {
      String str = ageString.toLowerCase();
      int tahun = 0;
      int bulan = 0;

      RegExp tahunRegex = RegExp(r'(\d+)\s*(tahun|thn)');
      var tahunMatch = tahunRegex.firstMatch(str);
      if (tahunMatch != null) tahun = int.parse(tahunMatch.group(1) ?? '0');

      RegExp bulanRegex = RegExp(r'(\d+)\s*(bulan|bln)');
      var bulanMatch = bulanRegex.firstMatch(str);
      if (bulanMatch != null) bulan = int.parse(bulanMatch.group(1) ?? '0');

      totalBulan = (tahun * 12) + bulan;
      return totalBulan == 0 ? 40 : totalBulan;
    } catch (e) {
      return 40;
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
      final String apiUrl = "https://motorikkids.my.id/predict";
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"teks": teksObservasi}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String statusNLP = data['data']['prediksi_status'] ?? "BSH"; 
        
        recommendationData.value = _generateDynamicRecommendation(statusNLP);
        
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

  Map<String, String> _generateDynamicRecommendation(String status) {
    int umurBulan = _hitungUsiaBulanPintar(_currentAge);
    String kategoriTerlemah = _currentFineScore <= _currentGrossScore ? "Halus" : "Kasar";

    String title = "";
    String desc = "";
    String tujuan = "";
    String cara = "";
    String durasi = "";
    String lokasi = kategoriTerlemah == "Kasar" ? "Halaman Rumah / Lapangan" : "Ruang Kelas / Meja Belajar";

    if (umurBulan >= 60 && umurBulan <= 72) {
      if (kategoriTerlemah == "Kasar") {
        if (status == "BB" || status == "MB") {
          title = "Langkah Gesit Pra-Sekolah 🏃";
          desc = "Kemampuan gerak Ananda perlu dorongan agar setara dengan teman seusianya.";
          tujuan = "Mengejar ketertinggalan motorik kasar 5 tahun.";
          cara = "Latih anak berdiri 1 kaki selama 11 detik. Ajari melompat jauh dan bermain halang rintang ringan secara rutin.";
          durasi = "20 Menit";
        } else {
          title = "Si Paling Tangkas! ⚽";
          desc = "Sangat optimal! Ananda sudah siap menerima tantangan fisik yang lebih kompleks.";
          tujuan = "Mempersiapkan kematangan fisik usia prasekolah.";
          cara = "Ajak anak bermain permainan aturan seperti sepak bola mini atau lompat tali untuk melatih ketangkasan.";
          durasi = "Bebas Aktif";
        }
      } else {
        if (status == "BB" || status == "MB") {
          title = "Fokus Jari Jemari ✍️";
          desc = "Kesiapan menulis Ananda masih perlu dilatih agar tidak kesulitan di SD nanti.";
          tujuan = "Meningkatkan kemampuan menulis dasar dan presisi.";
          cara = "Latih anak menggambar orang lengkap (6 bagian tubuh) dan menulis beberapa angka serta huruf.";
          durasi = "15 Menit";
        } else {
          title = "Penulis Hebat Masa Depan 🌟";
          desc = "Perkembangan motorik halus Ananda sangat mengesankan dan presisi.";
          tujuan = "Kemandirian menulis tingkat lanjut.";
          cara = "Latih ketepatan memegang pensil untuk menulis nama lengkapnya sendiri dan menggambar bentuk geometri kompleks.";
          durasi = "Bebas Terarah";
        }
      }
    } 
    else if (umurBulan > 48 && umurBulan < 60) {
      if (kategoriTerlemah == "Kasar") {
        if (status == "BB" || status == "MB") {
          title = "Ayo Melompat Lebih Jauh! 🦘";
          desc = "Tungkai Ananda butuh latihan ekstra untuk keseimbangan tubuhnya.";
          tujuan = "Meningkatkan kekuatan dan koordinasi tumpuan kaki.";
          cara = "Latih anak berdiri 1 kaki bergantian dan lompat jauh dengan kedua kaki bersamaan melewati garis batas.";
          durasi = "15-20 Menit";
        } else {
          title = "Penjelajah Kecil 🚀";
          desc = "Kelincahan Ananda sangat baik! Mari kita pertahankan perkembangannya.";
          tujuan = "Mengenalkan kemampuan gerak usia 5 tahun.";
          cara = "Lanjutkan stimulasi lomba balap karung kecil, bermain engklek, atau senam tari bersama.";
          durasi = "Bebas Aktif";
        }
      } else {
        if (status == "BB" || status == "MB") {
          title = "Berlatih Pola Ceria 🎨";
          desc = "Koordinasi mata dan tangan Ananda butuh pembiasaan lebih lanjut.";
          tujuan = "Mengejar ketertinggalan keluwesan jari.";
          cara = "Beri anak kertas & krayon. Latih anak menggambar garis silang (+) dan menumpuk 8 buah kubus.";
          durasi = "15 Menit";
        } else {
          title = "Seniman Cilik Kreatif ✨";
          desc = "Luar biasa, Ananda mampu mengontrol alat tulis dengan cukup baik di usianya.";
          tujuan = "Mengenalkan kontrol alat tulis tingkat lanjut.";
          cara = "Lanjutkan stimulasi memotong gambar dengan gunting anak dan mulai ajari menggambar bentuk kotak/segitiga.";
          durasi = "Bebas Terarah";
        }
      }
    } 
    else {
      if (kategoriTerlemah == "Kasar") {
        if (status == "BB" || status == "MB") {
          title = "Langkah Keseimbangan 🎈";
          desc = "Ananda perlu distimulasi lebih aktif agar percaya diri saat bergerak.";
          tujuan = "Mengejar ketertinggalan gerak kasar balita.";
          cara = "Ajak anak bermain 'lampu hijau-merah' untuk melatih keseimbangan, dan latih melompat sejauh mungkin tanpa jatuh.";
          durasi = "15 Menit";
        } else {
          title = "Lincah & Berani! 🌪️";
          desc = "Kemampuan gerak Ananda berkembang sesuai harapan.";
          tujuan = "Mempertahankan kemampuan sesuai usia.";
          cara = "Lanjutkan stimulasi melempar tangkap bola besar dan berdiri satu kaki tanpa bantuan selama 2 detik.";
          durasi = "Bebas Aktif";
        }
      } else {
        if (status == "BB" || status == "MB") {
          title = "Jari-Jari Pintar 🧱";
          desc = "Ananda butuh pengenalan lebih sering dengan benda-benda manipulatif.";
          tujuan = "Mengembangkan keluwesan genggaman.";
          cara = "Latih menggambar garis lurus atau lingkaran berulang kali, serta bermain puzzle gambar sederhana (3-4 potong).";
          durasi = "15 Menit";
        } else {
          title = "Cerdas Terampil 💡";
          desc = "Sangat baik! Jemari Ananda sudah cukup kuat untuk mulai belajar menulis kelak.";
          tujuan = "Mengenalkan kontrol alat tulis presisi.";
          cara = "Ajari cara memegang pensil yang benar (dynamic tripod) dan coba minta Ananda menggambar bentuk wajah manusia.";
          durasi = "Bebas Terarah";
        }
      }
    }

    return {
      "title": title,
      "desc": desc,
      "tujuan": tujuan,
      "cara": cara,
      "durasi": durasi,
      "lokasi": lokasi,
    };
  }

  // --- TAMBAHAN REVISI: FUNGSI TARIK DATA RIWAYAT ---
  void fetchAssessmentHistory() async {
    if (studentId == null) return;
    try {
      var snapshot = await firestore
          .collection('students')
          .doc(studentId)
          .collection('riwayat')
          .orderBy('date', descending: true)
          .limit(5) // Ambil 5 riwayat terakhir agar tidak terlalu panjang
          .get();

      assessmentHistory.assignAll(
        snapshot.docs.map((doc) {
          var data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList()
      );
    } catch (e) {
      debugPrint("Gagal mengambil riwayat: $e");
    }
  }

  // Format tanggal agar lebih rapi saat dibaca Orang Tua
  String formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return "-";
    try {
      DateTime date = DateTime.parse(isoDate).toLocal();
      List<String> months = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Ags", "Sep", "Okt", "Nov", "Des"];
      return "${date.day} ${months[date.month - 1]} ${date.year}";
    } catch (e) {
      return "-";
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
          
          recommendationDocId.value = doc.id;
          isDoneByParent.value = data['is_done'] ?? false;
          parentFeedbackText.value = data['parent_feedback'] ?? "";

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
          'is_done': false, 
          'parent_feedback': '', 
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