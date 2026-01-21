import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TeacherDashboardController extends GetxController {
  // Instance Firestore
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // --- DATA OBSERVABLE ---
  RxList<Map<String, dynamic>> studentsStream = <Map<String, dynamic>>[].obs;
  RxInt totalSiswa = 0.obs;
  RxBool isLoading = false.obs;

  // --- INPUT CONTROLLERS ---
  final nameC = TextEditingController();
  
  // Variabel untuk Tanggal Lahir & Umur
  Rx<DateTime?> selectedBirthDate = Rx<DateTime?>(null); 
  RxString ageText = "".obs; 
  
  // Status terpilih (Default: Baik)
  var selectedStatus = 'Baik'.obs;

  @override
  void onInit() {
    super.onInit();
    
    // BIND STREAM DATA
    studentsStream.bindStream(
      firestore.collection('students')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((query) {
          totalSiswa.value = query.docs.length; // Update total siswa
          
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

  // --- LOGIKA KALENDER & HITUNG UMUR ---
  void pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 5)), // Default 5 tahun lalu
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFA5D6A7), // Warna Hijau Soft
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

    // Format: "5 Thn 2 Bln"
    if (months > 0) {
      ageText.value = "$years Thn $months Bln";
    } else {
      ageText.value = "$years Tahun";
    }
  }

  // --- FUNGSI SIMPAN DATA ---
  void addStudent() async {
    if (nameC.text.isNotEmpty && selectedBirthDate.value != null) {
      try {
        isLoading.value = true;
        
        await firestore.collection('students').add({
          'name': nameC.text,
          'age': ageText.value, // Simpan umur hasil hitungan
          'birthDate': selectedBirthDate.value?.toIso8601String(),
          'status': selectedStatus.value,
          'createdAt': DateTime.now().toIso8601String(),
        });

        // Reset Form
        nameC.clear();
        selectedBirthDate.value = null;
        ageText.value = "";
        selectedStatus.value = 'Baik';
        isLoading.value = false;
        
        Get.back(); // Tutup Dialog
        
        Get.snackbar("Sukses", "Data siswa berhasil disimpan", 
          backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      } catch (e) {
        isLoading.value = false;
        Get.snackbar("Error", "Gagal menyimpan: $e", backgroundColor: Colors.red);
      }
    } else {
      Get.snackbar("Peringatan", "Nama dan Tanggal Lahir wajib diisi", 
        backgroundColor: Colors.orange, colorText: Colors.white);
    }
  }
  
  // Helper Warna Status
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