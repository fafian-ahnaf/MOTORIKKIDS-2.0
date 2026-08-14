import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final emailC = TextEditingController();
  
  var isLoading = false.obs;

  void sendPasswordResetEmail() async {
    String email = emailC.text.trim();

    if (email.isEmpty) {
      Get.snackbar(
        "Eits! ⚠️", 
        "Alamat email tidak boleh kosong ya Bunda/Yanda.",
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        "Format Email Kurang Tepat ❌", 
        "Pastikan penulisan alamat email sudah benar (contoh: nama@email.com).",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email);
      isLoading.value = false;

      // Munculkan dialog sukses yang ramah
      _showSuccessDialog(email);

    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String pesanError = "Terjadi kesalahan saat mengirim email reset.";
      
      if (e.code == 'user-not-found') {
        pesanError = "Alamat email ini belum terdaftar di sistem MotorikKids.";
      } else if (e.code == 'invalid-email') {
        pesanError = "Format email tidak valid.";
      }

      Get.snackbar(
        "Gagal Mengirim 😔", 
        pesanError,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Gagal mengirim tautan: $e");
    }
  }

  void _showSuccessDialog(String email) {
    Get.defaultDialog(
      title: "Email Terkirim! 💌",
      titleStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [
            const Icon(Icons.mark_email_read_rounded, size: 64, color: Color(0xFF4FC3F7)),
            const SizedBox(height: 16),
            Text(
              "Kami telah mengirimkan tautan pemulihan kata sandi ke:\n\n$email\n\nSilakan cek kotak masuk atau folder spam/junk email Anda ya!",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, height: 1.5, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      radius: 24,
      barrierDismissible: false,
      confirm: SizedBox(
        width: double.infinity,
        height: 45,
        child: ElevatedButton(
          onPressed: () {
            Get.back(); // Tutup dialog
            Get.back(); // Kembali ke halaman Login
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4FC3F7),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          child: const Text(
            "Siap, Kembali ke Masuk! 👍", 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }

  @override
  void onClose() {
    emailC.dispose();
    super.onClose();
  }
}