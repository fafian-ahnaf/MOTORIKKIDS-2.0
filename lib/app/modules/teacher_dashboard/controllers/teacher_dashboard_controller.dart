import 'dart:convert'; 
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:http/http.dart' as http; 

// --- LIBRARY UNTUK FILE, PDF & SHARE ---
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TeacherDashboardController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  RxList<Map<String, dynamic>> studentsStream = <Map<String, dynamic>>[].obs;
  RxInt totalSiswa = 0.obs;
  RxBool isLoading = false.obs;
  
  RxString namaGuru = "Guru".obs;
  RxString panggilan = "".obs; 

  final nameC = TextEditingController();
  Rx<DateTime?> selectedBirthDate = Rx<DateTime?>(null); 
  RxString ageText = "".obs; 
  var selectedKelas = 'TK A'.obs;      
  var selectedGender = 'Laki-laki'.obs; 

  // ==========================================================
  // VARIABEL UNTUK FITUR HAPUS BANYAK (MULTI-DELETE) & OBSERVASI
  // ==========================================================
  RxBool isSelectionMode = false.obs;
  RxList<String> selectedIds = <String>[].obs;
  final observasiKelompokC = TextEditingController(); // <-- Input Observasi Kelompok

  @override
  void onInit() {
    super.onInit();
    loadProfile();
    
    User? user = auth.currentUser;
    if (user != null) {
      studentsStream.bindStream(
        firestore.collection('students')
          .where('teacherId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((query) {
            totalSiswa.value = query.docs.length; 
            List<Map<String, dynamic>> retVal = [];
            for (var element in query.docs) {
              var data = element.data();
              data['id'] = element.id; 
              retVal.add(data); 
            }
            return retVal;
          }),
      );
    }
  }

  void loadProfile() async {
    User? user = auth.currentUser;
    if (user != null) {
      try {
        var doc = await firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          var data = doc.data();
          String fetchedName = data?['nama_lengkap'] ?? "";
          if (fetchedName.isNotEmpty) namaGuru.value = fetchedName;

          String gender = data?['jenis_kelamin']?.toString() ?? "";
          if (gender.toLowerCase() == "laki-laki") {
            panggilan.value = "Pak";
          } else if (gender.toLowerCase() == "perempuan") {
            panggilan.value = "Bu";
          } else {
            panggilan.value = "Pak/Bu"; 
          }
        }
      } catch (e) {
        debugPrint("Error load profil: $e");
      }
    }
  }

  String getSalam() {
    var hour = DateTime.now().hour;
    if (hour < 11) return "Selamat Pagi";
    if (hour < 15) return "Selamat Siang";
    if (hour < 18) return "Selamat Sore";
    return "Selamat Malam";
  }

  String generateToken() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  void resetForm() {
    nameC.clear();
    selectedBirthDate.value = null;
    ageText.value = "";
    selectedKelas.value = 'TK A';
    selectedGender.value = 'Laki-laki';
  }

  void fillFormToEdit(Map<String, dynamic> data) {
    nameC.text = data['name'] ?? "";
    ageText.value = data['age'] ?? "";
    selectedKelas.value = data['kelas'] ?? "TK A";
    selectedGender.value = data['gender'] ?? "Laki-laki";
    if (data['birthDate'] != null) {
      try { selectedBirthDate.value = DateTime.parse(data['birthDate']); } catch (_) { selectedBirthDate.value = null; }
    } else { selectedBirthDate.value = null; }
  }

  // ==========================================================
  // FITUR HAPUS BANYAK (BULK DELETE)
  // ==========================================================
  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    selectedIds.clear(); 
  }

  void toggleSelectAll() {
    if (selectedIds.length == studentsStream.length) {
      selectedIds.clear(); 
    } else {
      selectedIds.assignAll(studentsStream.map((e) => e['id'].toString()).toList()); 
    }
  }

  void toggleStudentSelection(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
  }

  void deleteSelectedStudents() {
    if (selectedIds.isEmpty) return;

    Get.defaultDialog(
      title: "Hapus ${selectedIds.length} Anak?",
      middleText: "Yakin ingin menghapus semua data yang Anda centang? Data tidak bisa dikembalikan.",
      textConfirm: "Hapus Semua", 
      textCancel: "Batal",
      confirmTextColor: Colors.white, 
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back(); 
        isLoading.value = true;
        try {
          WriteBatch batch = firestore.batch();
          for (String id in selectedIds) {
            DocumentReference docRef = firestore.collection('students').doc(id);
            batch.delete(docRef);
          }
          await batch.commit();
          
          Get.snackbar("Sukses 🧹", "${selectedIds.length} Data siswa berhasil dihapus secara masal!", backgroundColor: Colors.green, colorText: Colors.white);
          toggleSelectionMode(); 
        } catch (e) {
          Get.snackbar("Error", "Gagal menghapus data: $e", backgroundColor: Colors.red, colorText: Colors.white);
        }
        isLoading.value = false;
      }
    );
  }

  // ==========================================================
  // FITUR BARU: OBSERVASI KELOMPOK (MULTI-SELECT NLP)
  // ==========================================================
  void submitGroupObservation() async {
    if (observasiKelompokC.text.trim().isEmpty) {
      Get.snackbar("Info", "Teks observasi tidak boleh kosong!", backgroundColor: Colors.orange.shade100);
      return;
    }

    try {
      isLoading.value = true;
      String teksObservasi = observasiKelompokC.text.trim();

      // 1. Tembak API IndoBERT (Satu kali saja untuk semua anak terpilih)
      final String apiUrl = "https://motorikkids.my.id/predict";
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"teks": teksObservasi}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String statusPrediksi = data['data']['prediksi_status'] ?? "BSH"; 

        // 2. Simpan hasil ke semua anak yang dicentang secara bersamaan (Batch)
        WriteBatch batch = firestore.batch();
        String tanggalSekarang = DateTime.now().toIso8601String();

        for (String id in selectedIds) {
          DocumentReference studentRef = firestore.collection('students').doc(id);
          batch.update(studentRef, {'status': statusPrediksi});

          DocumentReference riwayatRef = studentRef.collection('riwayat').doc();
          batch.set(riwayatRef, {
            'activity': 'Observasi Kelompok',
            'notes': teksObservasi,
            'score': statusPrediksi,
            'date': tanggalSekarang,
          });
        }

        await batch.commit();

        observasiKelompokC.clear();
        toggleSelectionMode(); 
        Get.back(); // Tutup pop-up

        Get.snackbar("Berhasil! 🎉", "Observasi kelompok berhasil diproses oleh IndoBERT dan disimpan ke ${selectedIds.length} anak.", 
          backgroundColor: Colors.green.shade400, colorText: Colors.white, duration: const Duration(seconds: 4));

      } else {
        throw "API Error: ${response.statusCode}";
      }
    } catch (e) {
      Get.snackbar("Gagal", "Terjadi kesalahan API IndoBERT: $e", backgroundColor: Colors.red.shade100);
    } finally {
      isLoading.value = false;
    }
  }

  void showGroupObservationDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Observasi Kelompok 👥", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.blue.shade800)),
              const SizedBox(height: 8),
              Text("Input observasi untuk ${selectedIds.length} anak sekaligus. AI akan memprosesnya otomatis.", style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              const SizedBox(height: 16),
              TextField(
                controller: observasiKelompokC,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Contoh: Anak-anak hari ini belajar melompat rintangan, namun masih ada yang sering terjatuh...",
                  filled: true, fillColor: Colors.blue.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              Obx(() => SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: isLoading.value ? null : () => submitGroupObservation(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: isLoading.value 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text("Proses data", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ))
            ],
          ),
        ),
      )
    );
  }

  // ==========================================================
  // FITUR 1: IMPORT CSV
  // ==========================================================
  void importCSV() async {
    try {
      const XTypeGroup csvTypeGroup = XTypeGroup(label: 'CSV Files', extensions: <String>['csv']);
      final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[csvTypeGroup]);

      if (file != null) {
        final int fileSizeInBytes = await file.length(); 
        final double fileSizeInMB = fileSizeInBytes / (1024 * 1024); 

        if (fileSizeInMB > 3.0) {
          Get.snackbar("File Terlalu Besar! ⚠️", "Maksimal 3 MB. File Anda ${fileSizeInMB.toStringAsFixed(2)} MB.", 
            backgroundColor: Colors.orange, colorText: Colors.white);
          return; 
        }

        isLoading.value = true;
        final String csvString = await file.readAsString();
        List<String> barisData = csvString.trim().split('\n');

        WriteBatch batch = firestore.batch();
        User? user = auth.currentUser;
        
        int countAdded = 0;
        int countSkipped = 0;

        Set<String> existingData = {};
        for (var s in studentsStream) {
          String existingName = (s['name'] ?? "").toString().trim().toLowerCase();
          String existingDateStr = (s['birthDate'] ?? "").toString();
          try {
            DateTime d = DateTime.parse(existingDateStr);
            existingData.add("${existingName}_${d.year}-${d.month}-${d.day}");
          } catch (_) {}
        }

        for (int i = 1; i < barisData.length; i++) {
          List<String> kolom = barisData[i].trim().split(RegExp(r'[,;]'));
          
          if (kolom.length < 4) continue; 

          String name = kolom[0].trim();
          String kelas = kolom[1].trim();
          String gender = kolom[2].trim();
          String birthDateStr = kolom[3].trim();

          DateTime birthDate;
          try { birthDate = DateTime.parse(birthDateStr); } catch (e) { continue; }

          String uniqueKey = "${name.toLowerCase()}_${birthDate.year}-${birthDate.month}-${birthDate.day}";
          if (existingData.contains(uniqueKey)) {
            countSkipped++; 
            continue; 
          }

          existingData.add(uniqueKey);
         
          DateTime today = DateTime.now();
          int years = today.year - birthDate.year;
          int months = today.month - birthDate.month;
          if (today.day < birthDate.day) months--;
          if (months < 0) { years--; months += 12; }
          String calculatedAge = (months > 0) ? "$years Thn $months Bln" : "$years Tahun";

          String tokenBaruCsv = generateToken(); 

          batch.set(firestore.collection('students').doc(), {
            'teacherId': user?.uid,
            'name': name, 
            'kelas': kelas, 
            'gender': gender,
            'birthDate': birthDate.toIso8601String(), 
            'age': calculatedAge,
            'status': 'Belum Dinilai', 
            'createdAt': DateTime.now().toIso8601String(),
            'token_ortu': tokenBaruCsv, 
          });
          countAdded++; 
        }

        if (countAdded > 0) {
          await batch.commit();
        }
        
        isLoading.value = false;

        if (countAdded > 0 && countSkipped == 0) {
          Get.snackbar("Sukses 🎉", "$countAdded Data siswa baru berhasil diimpor!", backgroundColor: Colors.green, colorText: Colors.white);
        } else if (countAdded > 0 && countSkipped > 0) {
          Get.snackbar("Selesai 🎉", "$countAdded Data ditambahkan, $countSkipped dilewati (karena sudah ada).", backgroundColor: Colors.blue, colorText: Colors.white, duration: const Duration(seconds: 4));
        } else if (countAdded == 0 && countSkipped > 0) {
          Get.snackbar("Ups! ℹ️", "Semua isi file CSV ini sudah terdaftar di aplikasi.", backgroundColor: Colors.orange, colorText: Colors.white, duration: const Duration(seconds: 4));
        } else {
          Get.snackbar("Info", "File CSV kosong atau format salah.", backgroundColor: Colors.orange, colorText: Colors.white);
        }

      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Gagal Import", "Error: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ==========================================================
  // FITUR 2: UNDUH TEMPLATE CSV
  // ==========================================================
  void downloadTemplateCSV() async {
    try {
      isLoading.value = true;
      
      String templateData = "Nama,Kelas,Gender,Tanggal Lahir\nBudi Santoso,TK A,Laki-laki,2021-03-15\nSiti Aminah,TK A,Perempuan,2021-05-20\n";

      if (Platform.isAndroid) {
        Directory downloadDir = Directory('/storage/emulated/0/Download');

        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }

        String path = '${downloadDir.path}/Template_MotorikKids.csv';
        File file = File(path);

        await file.writeAsString(templateData);

        isLoading.value = false;
        Get.snackbar(
          "Berhasil Diunduh! 📥",
          "File Template_MotorikKids.csv sudah tersimpan di folder Download. Silakan cek Pengelola File HP Anda.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      } else {
        final directory = await getApplicationDocumentsDirectory();
        String path = '${directory.path}/Template_MotorikKids.csv';
        await File(path).writeAsString(templateData);

        isLoading.value = false;
        await Share.shareXFiles([XFile(path)], subject: 'Template CSV MotorikKids');
      }
    } catch (e) {
      isLoading.value = false;
      
      try {
        String templateData = "Nama,Kelas,Gender,Tanggal Lahir\nBudi Santoso,TK A,Laki-laki,2021-03-15\nSiti Aminah,TK A,Perempuan,2021-05-20\n";
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/Template_MotorikKids.csv';
        await File(path).writeAsString(templateData);
        await Share.shareXFiles([XFile(path)], text: 'Simpan file CSV ini');
      } catch (fallbackError) {
        Get.snackbar("Gagal Mengunduh", "Error: $e", backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }

  // ==========================================================
  // FITUR 3: EXPORT KE PDF
  // ==========================================================
  void exportPDF() async {
    if (studentsStream.isEmpty) {
      Get.snackbar("Info", "Belum ada data siswa untuk diexport", backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      Get.snackbar("Memproses...", "Sedang membuat file PDF 📄", backgroundColor: Colors.blue, colorText: Colors.white);

      final pdf = pw.Document();
      final dataSiswa = studentsStream.toList();
      
      final headers = ['No', 'Nama Anak', 'Kelas', 'L/P', 'Umur', 'Token Ortu', 'Status'];
      final tableData = <List<String>>[];

      for (int i = 0; i < dataSiswa.length; i++) {
        final s = dataSiswa[i];
        
        bool isLinked = s['parent_id'] != null && s['parent_id'].toString().isNotEmpty;
        String tokenTampil = isLinked ? 'Terhubung' : (s['token_ortu'] ?? '-');

        tableData.add([
          (i + 1).toString(),
          s['name'] ?? '-',
          s['kelas'] ?? '-',
          s['gender'] == 'Laki-laki' ? 'L' : 'P',
          s['age'] ?? '-',
          tokenTampil, 
          s['status'] ?? '-',
        ]);
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape, 
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Daftar Anak Didik & Token - MotorikKids', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text('Tanggal Export: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
                pw.SizedBox(height: 20),
                pw.TableHelper.fromTextArray(
                  headers: headers,
                  data: tableData,
                  border: pw.TableBorder.all(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                  cellAlignment: pw.Alignment.centerLeft,
                  cellPadding: const pw.EdgeInsets.all(5),
                ),
              ],
            );
          },
        ),
      );

      await Printing.sharePdf(bytes: await pdf.save(), filename: 'Data_MotorikKids.pdf');
      isLoading.value = false;

    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Gagal export PDF: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
  
  // --- FUNGSI TAMBAH MANUAL & LAINNYA ---
  void addStudent() async {
    if (_validateForm()) {
      try {
        isLoading.value = true;
        User? user = auth.currentUser;
        
        String tokenBaru = generateToken(); 

        await firestore.collection('students').add({
          'teacherId': user?.uid,
          'name': nameC.text, 
          'age': ageText.value,
          'birthDate': selectedBirthDate.value?.toIso8601String(),
          'kelas': selectedKelas.value, 
          'gender': selectedGender.value, 
          'status': 'Belum Dinilai', 
          'createdAt': DateTime.now().toIso8601String(),
          'token_ortu': tokenBaru, 
        });
        _finishAction("Data siswa berhasil disimpan");
      } catch (e) { _handleError(e); }
    }
  }

  void updateStudent(String docId) async {
    if (_validateForm()) {
      try {
        isLoading.value = true;
        await firestore.collection('students').doc(docId).update({
          'name': nameC.text, 'age': ageText.value,
          'birthDate': selectedBirthDate.value?.toIso8601String(),
          'kelas': selectedKelas.value, 'gender': selectedGender.value, 
        });
        _finishAction("Data siswa berhasil diperbarui");
      } catch (e) { _handleError(e); }
    }
  }

  void deleteStudent(String docId) {
    Get.defaultDialog(
      title: "Hapus Siswa", middleText: "Yakin ingin menghapus data ini?",
      textConfirm: "Hapus", textCancel: "Batal",
      confirmTextColor: Colors.white, buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        try {
          await firestore.collection('students').doc(docId).delete();
          Get.snackbar("Sukses", "Data dihapus", backgroundColor: Colors.green, colorText: Colors.white);
        } catch (e) { Get.snackbar("Error", "$e", backgroundColor: Colors.red); }
      }
    );
  }

  void pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedBirthDate.value ?? DateTime.now().subtract(const Duration(days: 365 * 5)), 
      firstDate: DateTime(2010), lastDate: DateTime.now(),
    );
    if (picked != null) { selectedBirthDate.value = picked; _calculateAge(picked); }
  }

  void _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int years = today.year - birthDate.year; int months = today.month - birthDate.month;
    if (today.day < birthDate.day) months--;
    if (months < 0) { years--; months += 12; }
    ageText.value = (months > 0) ? "$years Thn $months Bln" : "$years Tahun";
  }

  bool _validateForm() {
    if (nameC.text.isEmpty || selectedBirthDate.value == null) {
      Get.snackbar("Info", "Nama & Tanggal Lahir wajib diisi", backgroundColor: Colors.orange, colorText: Colors.white);
      return false;
    }
    return true;
  }

  void _finishAction(String msg) {
    isLoading.value = false; resetForm(); Get.back();
    Get.snackbar("Sukses", msg, backgroundColor: Colors.green, colorText: Colors.white);
  }

  void _handleError(dynamic e) {
    isLoading.value = false; Get.snackbar("Error", "$e", backgroundColor: Colors.red);
  }

  Color getStatusColor(String status) {
    if (status == 'Perlu Pendampingan') return Colors.red;
    if (status == 'Perlu Stimulasi') return Colors.amber;
    if (status == 'Belum Dinilai') return Colors.grey; 
    return Colors.green;
  }

  @override
  void onClose() { 
    nameC.dispose(); 
    observasiKelompokC.dispose(); // <-- Dispose input baru
    super.onClose(); 
  }
}