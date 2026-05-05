import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordController extends GetxController {
  final emailC = TextEditingController();
  RxBool isLoading = false.obs;
  FirebaseAuth auth = FirebaseAuth.instance;

  void resetPassword() async {
    if (emailC.text.isEmpty || !emailC.text.contains('@')) {
      Get.snackbar(
        "Oops!", 
        "Masukkan alamat email yang valid ya.", 
        backgroundColor: Colors.orange, 
        colorText: Colors.white
      );
      return;
    }

    try {
      isLoading.value = true;
      // Perintah sakti Firebase untuk mengirim email reset password
      await auth.sendPasswordResetEmail(email: emailC.text.trim());
      isLoading.value = false;
      
      Get.defaultDialog(
        title: "Terkirim! ✉️",
        middleText: "Coba cek kotak masuk (atau folder spam) di email Anda untuk mengatur ulang kata sandi.",
        textConfirm: "Siap, Paham!",
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFF4FC3F7), // warna biruAwan
        onConfirm: () {
          Get.back(); // Tutup dialog
          Get.back(); // Kembali ke halaman Login
        }
      );
      
      emailC.clear();
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String pesanError = "Terjadi kesalahan.";
      if (e.code == 'user-not-found') {
        pesanError = "Email ini belum terdaftar di aplikasi.";
      }
      Get.snackbar("Gagal", pesanError, backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Gagal", "Error: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  void onClose() {
    emailC.dispose();
    super.onClose();
  }
}