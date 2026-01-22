import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TeacherDashboardController extends GetxController {
  // Instance Firebase
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  // --- DATA OBSERVABLE ---
  RxList<Map<String, dynamic>> studentsStream = <Map<String, dynamic>>[].obs;
  RxInt totalSiswa = 0.obs;
  RxBool isLoading = false.obs;
  
  // Data Guru
  RxString namaGuru = "Guru".obs;

  // --- INPUT CONTROLLERS ---
  final nameC = TextEditingController();
  
  // Variabel Form
  Rx<DateTime?> selectedBirthDate = Rx<DateTime?>(null); 
  RxString ageText = "".obs; 
  
  // Pilihan Dropdown/Radio (Default Value)
  var selectedStatus = 'Baik'.obs;
  var selectedKelas = 'TK A'.obs;      
  var selectedGender = 'Laki-laki'.obs; 

  @override
  void onInit() {
    super.onInit();
    loadProfile();
    
    // Bind Stream Data Siswa (Realtime)
    studentsStream.bindStream(
      firestore.collection('students')
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

  // --- FUNGSI LOAD PROFIL ---
  void loadProfile() async {
    User? user = auth.currentUser;
    if (user != null) {
      try {
        var doc = await firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          String fetchedName = doc.data()?['nama_lengkap'] ?? "";
          if (fetchedName.isNotEmpty) {
            namaGuru.value = fetchedName;
            return; 
          }
        }
      } catch (e) {
        print("Error load profil: $e");
      }
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        namaGuru.value = user.displayName!;
      }
    }
  }

  // --- LOGIKA KALENDER ---
  void pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedBirthDate.value ?? DateTime.now().subtract(const Duration(days: 365 * 5)), 
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFA5D6A7), 
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedBirthDate.value = picked;
      calculateAge(picked);
    }
  }

  void calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int years = today.year - birthDate.year;
    int months = today.month - birthDate.month;

    if (today.day < birthDate.day) {
      months--;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    if (months > 0) {
      ageText.value = "$years Thn $months Bln";
    } else {
      ageText.value = "$years Tahun";
    }
  }

  // --- 🔥 LOGIKA EDIT: ISI FORM DENGAN DATA LAMA 🔥 ---
  void fillFormToEdit(Map<String, dynamic> data) {
    nameC.text = data['name'] ?? "";
    ageText.value = data['age'] ?? "";
    selectedStatus.value = data['status'] ?? "Baik";
    selectedKelas.value = data['kelas'] ?? "TK A";
    selectedGender.value = data['gender'] ?? "Laki-laki";
    
    // Parse Tanggal Lahir
    if (data['birthDate'] != null) {
      try {
        selectedBirthDate.value = DateTime.parse(data['birthDate']);
      } catch (_) {
        selectedBirthDate.value = null;
      }
    } else {
      selectedBirthDate.value = null;
    }
  }

  // --- 💾 FUNGSI SIMPAN (CREATE) ---
  void addStudent() async {
    if (_validateForm()) {
      try {
        isLoading.value = true;
        await firestore.collection('students').add({
          'name': nameC.text,
          'age': ageText.value,
          'birthDate': selectedBirthDate.value?.toIso8601String(),
          'status': selectedStatus.value,
          'kelas': selectedKelas.value,   
          'gender': selectedGender.value, 
          'createdAt': DateTime.now().toIso8601String(),
        });
        _finishAction("Data siswa berhasil disimpan");
      } catch (e) {
        _handleError(e);
      }
    }
  }

  // --- ✏️ FUNGSI UPDATE (EDIT) ---
  void updateStudent(String docId) async {
    if (_validateForm()) {
      try {
        isLoading.value = true;
        await firestore.collection('students').doc(docId).update({
          'name': nameC.text,
          'age': ageText.value,
          'birthDate': selectedBirthDate.value?.toIso8601String(),
          'status': selectedStatus.value,
          'kelas': selectedKelas.value,   
          'gender': selectedGender.value, 
          // createdAt tidak diubah
        });
        _finishAction("Data siswa berhasil diperbarui");
      } catch (e) {
        _handleError(e);
      }
    }
  }

  // --- 🗑️ FUNGSI HAPUS (DELETE) ---
  void deleteStudent(String docId) {
    Get.defaultDialog(
      title: "Hapus Siswa",
      middleText: "Apakah Anda yakin ingin menghapus data ini? Data tidak bisa dikembalikan.",
      textConfirm: "Ya, Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: Colors.black,
      onConfirm: () async {
        Get.back(); // Tutup Dialog
        try {
          await firestore.collection('students').doc(docId).delete();
          Get.snackbar("Sukses", "Data siswa dihapus", backgroundColor: Colors.green, colorText: Colors.white);
        } catch (e) {
          Get.snackbar("Error", "Gagal menghapus: $e", backgroundColor: Colors.red);
        }
      }
    );
  }

  // --- HELPER FUNCTIONS ---
  bool _validateForm() {
    if (nameC.text.isEmpty || selectedBirthDate.value == null) {
      Get.snackbar("Peringatan", "Nama dan Tanggal Lahir wajib diisi", backgroundColor: Colors.orange, colorText: Colors.white);
      return false;
    }
    return true;
  }

  void _finishAction(String successMessage) {
    resetForm();
    isLoading.value = false;
    Get.back(); // Tutup Dialog Input
    Get.snackbar("Sukses", successMessage, backgroundColor: Colors.green, colorText: Colors.white);
  }

  void _handleError(dynamic e) {
    isLoading.value = false;
    Get.snackbar("Error", "Terjadi kesalahan: $e", backgroundColor: Colors.red);
  }

  void resetForm() {
    nameC.clear();
    selectedBirthDate.value = null;
    ageText.value = "";
    selectedStatus.value = 'Baik';
    selectedKelas.value = 'TK A';
    selectedGender.value = 'Laki-laki';
  }
  
  Color getStatusColor(String status) {
    if (status == 'Perlu Pendampingan') return Colors.red;
    if (status == 'Perlu Stimulasi') return Colors.amber;
    return Colors.green;
  }

  @override
  void onClose() {
    nameC.dispose();
    super.onClose();
  }
}