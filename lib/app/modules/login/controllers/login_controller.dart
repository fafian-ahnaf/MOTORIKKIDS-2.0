import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var currentRole = 'parent'.obs;
  var isLoading = false.obs;
  var isObscure = true.obs;

  final emailC = TextEditingController();
  final passC = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    
    if (Get.arguments != null && Get.arguments['role'] != null) {
      currentRole.value = Get.arguments['role'];
    }
  }

  Color get themeColor => currentRole.value == 'teacher' ? Colors.orange : Colors.blueAccent;
  Color get lightThemeColor => currentRole.value == 'teacher' ? Colors.orange.shade50 : Colors.blue.shade50;
  String get roleLabel => currentRole.value == 'teacher' ? "Ibu/Bapak Guru" : "Ayah/Bunda";
  String get assetImage => currentRole.value == 'teacher' ? "assets/guru.png" : "assets/orang tua.png";

  void togglePassword() {
    isObscure.value = !isObscure.value;
  }

  void login() async {
    if (emailC.text.isNotEmpty && passC.text.isNotEmpty) {
      try {
        isLoading.value = true;

        // 1. Coba login ke Firebase
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: emailC.text.trim(),
          password: passC.text.trim(),
        );

        // =======================================================
        // --- CEK APAKAH EMAIL SUDAH DIVERIFIKASI ---
        // =======================================================
        if (!userCredential.user!.emailVerified) {
          // Jika belum diverifikasi, paksa logout dan beri peringatan
          await _auth.signOut();
          isLoading.value = false;
          Get.snackbar(
            "Email Belum Aktif ⚠️",
            "Silakan cek kotak masuk atau folder spam Gmail Anda dan klik link verifikasi sebelum login.",
            backgroundColor: Colors.orange.shade100,
            colorText: Colors.orange[900],
            duration: const Duration(seconds: 5),
          );
          return; // Hentikan fungsi di sini
        }
        // =======================================================

        // 2. Jika lolos verifikasi, lanjutkan cek Firestore
        String uid = userCredential.user!.uid;
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

        if (userDoc.exists) {
          String dbRole = userDoc['role'];

          // 3. Arahkan ke dashboard masing-masing
          if (dbRole == 'teacher') {
             Get.offAllNamed(Routes.TEACHER_DASHBOARD);
          } else {
             Get.offAllNamed(Routes.PARENT_DASHBOARD);
          }
          
          Get.snackbar("Berhasil Masuk", "Selamat datang kembali!", backgroundColor: Colors.green.shade100);
        } else {
          Get.snackbar("Error Data", "Data profil tidak ditemukan.", backgroundColor: Colors.red.shade100);
          await _auth.signOut();
        }

      } on FirebaseAuthException catch (e) {
        String errorMessage = "Terjadi kesalahan.";
        if (e.code == 'user-not-found') errorMessage = "Email tidak terdaftar.";
        if (e.code == 'wrong-password') errorMessage = "Password salah.";
        if (e.code == 'invalid-email') errorMessage = "Format email salah.";
        if (e.code == 'invalid-credential') errorMessage = "Email atau Password salah.";

        Get.snackbar("Gagal Masuk", errorMessage, backgroundColor: Colors.red.shade100, colorText: Colors.red[900]);
      } catch (e) {
        Get.snackbar("Error", "Gagal koneksi ke server.", backgroundColor: Colors.red.shade100);
      } finally {
        isLoading.value = false;
      }
    } else {
      Get.snackbar("Warning", "Email dan Password wajib diisi.", backgroundColor: Colors.yellow.shade100);
    }
  }

  // ==============================================================
  // --- FUNGSI LUPA PASSWORD (RESET PASSWORD VIA EMAIL) ---
  // ==============================================================
  void resetPassword() async {
    // Meminta user mengisi email di kolom input sebelum klik Lupa Password
    if (emailC.text.isEmpty || !GetUtils.isEmail(emailC.text.trim())) {
      Get.snackbar(
        "Perhatian",
        "Masukkan email Anda yang valid di kolom email terlebih dahulu, lalu klik Lupa Password.",
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue[900],
        duration: const Duration(seconds: 4),
      );
      return;
    }

    try {
      // Mengirim link reset password ke Gmail
      await _auth.sendPasswordResetEmail(email: emailC.text.trim());
      Get.snackbar(
        "Link Terkirim 📩",
        "Link untuk mereset password telah dikirim ke ${emailC.text.trim()}. Silakan cek email Anda.",
        backgroundColor: Colors.green.shade100,
        duration: const Duration(seconds: 5),
      );
    } on FirebaseAuthException catch (e) {
      String msg = "Tidak dapat mengirim link reset.";
      if (e.code == 'user-not-found') msg = "Email ini belum terdaftar di sistem.";
      Get.snackbar("Gagal", msg, backgroundColor: Colors.red.shade100);
    }
  }

  void goToRegister() {
    Get.toNamed(Routes.REGISTER, arguments: {'role': currentRole.value});
  }
}