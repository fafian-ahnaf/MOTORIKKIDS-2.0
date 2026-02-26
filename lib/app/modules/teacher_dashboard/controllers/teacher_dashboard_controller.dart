import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  var selectedStatus = 'Baik'.obs;
  var selectedKelas = 'TK A'.obs;      
  var selectedGender = 'Laki-laki'.obs; 

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
          if (fetchedName.isNotEmpty) {
            namaGuru.value = fetchedName;
          }

          
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
        print("Error load profil: $e");
      }
      
      if (namaGuru.value == "Guru" && user.displayName != null) {
        namaGuru.value = user.displayName!;
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

  void resetForm() {
    nameC.clear();
    selectedBirthDate.value = null;
    ageText.value = "";
    selectedStatus.value = 'Baik';
    selectedKelas.value = 'TK A';
    selectedGender.value = 'Laki-laki';
  }

  void fillFormToEdit(Map<String, dynamic> data) {
    nameC.text = data['name'] ?? "";
    ageText.value = data['age'] ?? "";
    selectedStatus.value = data['status'] ?? "Baik";
    selectedKelas.value = data['kelas'] ?? "TK A";
    selectedGender.value = data['gender'] ?? "Laki-laki";
    if (data['birthDate'] != null) {
      try { selectedBirthDate.value = DateTime.parse(data['birthDate']); } catch (_) { selectedBirthDate.value = null; }
    } else { selectedBirthDate.value = null; }
  }

  void addStudent() async {
    if (_validateForm()) {
      try {
        isLoading.value = true;
        User? user = auth.currentUser;
        await firestore.collection('students').add({
          'teacherId': user?.uid,
          'name': nameC.text,
          'age': ageText.value,
          'birthDate': selectedBirthDate.value?.toIso8601String(),
          'status': selectedStatus.value,
          'kelas': selectedKelas.value,   
          'gender': selectedGender.value, 
          'createdAt': DateTime.now().toIso8601String(),
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
          'name': nameC.text,
          'age': ageText.value,
          'birthDate': selectedBirthDate.value?.toIso8601String(),
          'status': selectedStatus.value,
          'kelas': selectedKelas.value,   
          'gender': selectedGender.value, 
        });
        _finishAction("Data siswa berhasil diperbarui");
      } catch (e) { _handleError(e); }
    }
  }

  void deleteStudent(String docId) {
    Get.defaultDialog(
      title: "Hapus Siswa",
      middleText: "Yakin ingin menghapus data ini?",
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
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      selectedBirthDate.value = picked;
      _calculateAge(picked);
    }
  }

  void _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int years = today.year - birthDate.year;
    int months = today.month - birthDate.month;
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
    isLoading.value = false;
    resetForm();
    Get.back();
    Get.snackbar("Sukses", msg, backgroundColor: Colors.green, colorText: Colors.white);
  }

  void _handleError(dynamic e) {
    isLoading.value = false;
    Get.snackbar("Error", "$e", backgroundColor: Colors.red);
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