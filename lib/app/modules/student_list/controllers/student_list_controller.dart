import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../routes/app_pages.dart';

class StudentListController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream: Ini yang bikin list-nya otomatis update kalau ada data baru
  Stream<QuerySnapshot> get studentsStream => _firestore
      .collection('students')
      .orderBy('nama_siswa', descending: false)
      .snapshots();

  // Controller untuk Form Tambah Siswa
  final namaC = TextEditingController();
  final nikC = TextEditingController(); // Opsional, buat ID unik
  final kelasC = TextEditingController();
  var selectedGender = 'L'.obs;
  var selectedDate = DateTime.now().obs;

  // Fungsi Tambah Siswa ke Firestore
  Future<void> addStudent() async {
    if (namaC.text.isNotEmpty && kelasC.text.isNotEmpty) {
      try {
        await _firestore.collection('students').add({
          'nama_siswa': namaC.text,
          'nik': nikC.text,
          'kelas': kelasC.text,
          'jenis_kelamin': selectedGender.value,
          'tgl_lahir': selectedDate.value.toIso8601String(),
          'parent_id': '', // Nanti diisi kalau fitur connect Ortu sudah ada
          'created_at': FieldValue.serverTimestamp(),
        });
        
        Get.back(); // Tutup Dialog
        _resetForm();
        Get.snackbar("Sukses", "Data siswa berhasil ditambahkan", backgroundColor: Colors.green.shade100);
      } catch (e) {
        Get.snackbar("Error", "Gagal menyimpan data", backgroundColor: Colors.red.shade100);
      }
    } else {
      Get.snackbar("Ups", "Nama dan Kelas wajib diisi", backgroundColor: Colors.yellow.shade100);
    }
  }

  // Fungsi Hapus Siswa
  Future<void> deleteStudent(String docId) async {
    try {
      await _firestore.collection('students').doc(docId).delete();
      Get.snackbar("Terhapus", "Data siswa dihapus", backgroundColor: Colors.orange.shade100);
    } catch (e) {
      Get.snackbar("Error", "Gagal menghapus", backgroundColor: Colors.red.shade100);
    }
  }

  // Helper ke Form Observasi
  void goToAssessment(Map<String, dynamic> studentData, String docId) {
    Get.toNamed(Routes.ASSESSMENT_FORM, arguments: {
      'id': docId,
      'data': studentData
    });
  }

  void _resetForm() {
    namaC.clear();
    nikC.clear();
    kelasC.clear();
    selectedGender.value = 'L';
  }
}