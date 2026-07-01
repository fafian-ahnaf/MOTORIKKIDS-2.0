import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  var isLoading = true.obs;
  var isSaving = false.obs;

  final nameC = TextEditingController();
  final phoneC = TextEditingController();
  var gender = 'Laki-laki'.obs;
  var role = ''.obs;
  
  // Variabel untuk Foto Profil
  var profilePicUrl = ''.obs;
  var selectedImage = Rxn<File>();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void loadUserData() async {
    try {
      isLoading.value = true;
      User? user = _auth.currentUser;
      if (user != null) {
        var doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          var data = doc.data()!;
          nameC.text = data['nama_lengkap'] ?? '';
          phoneC.text = data['no_telp'] ?? '';
          gender.value = data['jenis_kelamin'] ?? 'Laki-laki';
          role.value = data['role'] ?? '';
          profilePicUrl.value = data['profile_url'] ?? '';
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat data: $e", backgroundColor: Colors.red.shade100);
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI PILIH FOTO DARI GALERI ---
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Kompres ukuran file agar tidak berat
    );

    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  // --- FUNGSI UPDATE DATA & UPLOAD FOTO ---
  void updateProfile() async {
    if (nameC.text.trim().isEmpty) {
      Get.snackbar("Info", "Nama tidak boleh kosong!", backgroundColor: Colors.orange.shade100);
      return;
    }

    try {
      isSaving.value = true;
      User? user = _auth.currentUser;
      if (user == null) return;

      String imageUrl = profilePicUrl.value;

      // Jika user memilih foto baru, upload ke Firebase Storage dulu
      if (selectedImage.value != null) {
        // Buat referensi lokasi file di Firebase Storage
        Reference ref = _storage.ref().child('profile_pictures/${user.uid}.jpg');
        
        // Mulai upload
        UploadTask uploadTask = ref.putFile(selectedImage.value!);
        TaskSnapshot snapshot = await uploadTask;
        
        // Dapatkan URL gambar yang sudah diupload
        imageUrl = await snapshot.ref.getDownloadURL();
        profilePicUrl.value = imageUrl; 
      }

      // Update data di Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'nama_lengkap': nameC.text.trim(),
        'no_telp': phoneC.text.trim(),
        'jenis_kelamin': gender.value,
        'profile_url': imageUrl, // Simpan link fotonya
      });

      Get.snackbar("Berhasil! 🎉", "Profil berhasil diperbarui.", backgroundColor: Colors.green.shade100);
      
      // Bersihkan file sementara agar UI kembali normal
      selectedImage.value = null; 

    } catch (e) {
      Get.snackbar("Gagal", "Error saat menyimpan profil: $e", backgroundColor: Colors.red.shade100);
    } finally {
      isSaving.value = false;
    }
  }

  // --- FUNGSI LOGOUT ---
  void logout() async {
    await _auth.signOut();
    Get.offAllNamed('/welcome'); // Pastikan rutenya sesuai
  }

  @override
  void onClose() {
    nameC.dispose();
    phoneC.dispose();
    super.onClose();
  }
}