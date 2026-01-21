import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  // Instance Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Variabel Utama
  var currentRole = 'parent'.obs;
  var isLoading = false.obs;
  var isObscure = true.obs;

  // Controller Textfield
  final emailC = TextEditingController();
  final passC = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Tangkap data role dari halaman Welcome
    if (Get.arguments != null && Get.arguments['role'] != null) {
      currentRole.value = Get.arguments['role'];
    }
  }

  // --- GETTER HELPER (UI) ---
  Color get themeColor => currentRole.value == 'teacher' ? Colors.orange : Colors.blueAccent;
  Color get lightThemeColor => currentRole.value == 'teacher' ? Colors.orange.shade50 : Colors.blue.shade50;
  String get roleLabel => currentRole.value == 'teacher' ? "Ibu/Bapak Guru" : "Ayah/Bunda";
  String get assetImage => currentRole.value == 'teacher' ? "assets/guru.png" : "assets/orang tua.png";

  void togglePassword() {
    isObscure.value = !isObscure.value;
  }

  // --- FUNGSI LOGIN FIREBASE ---
  void login() async {
    if (emailC.text.isNotEmpty && passC.text.isNotEmpty) {
      try {
        isLoading.value = true;

        // 1. Proses Login ke Firebase Auth
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: emailC.text.trim(),
          password: passC.text.trim(),
        );

        // 2. Jika sukses login, cek data di Firestore (Validasi Role)
        String uid = userCredential.user!.uid;
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

        if (userDoc.exists) {
          // Ambil role asli dari database
          String dbRole = userDoc['role'];

          // Redirect sesuai role di database (bukan cuma pilihan di depan)
          if (dbRole == 'teacher') {
             Get.offAllNamed(Routes.TEACHER_DASHBOARD);
          } else {
             Get.offAllNamed(Routes.PARENT_DASHBOARD);
          }
          
          Get.snackbar("Berhasil Masuk", "Selamat datang kembali!", backgroundColor: Colors.green.shade100);
        } else {
          // Kasus aneh: Login auth sukses, tapi data di Firestore gak ada
          Get.snackbar("Error Data", "Data profil tidak ditemukan.", backgroundColor: Colors.red.shade100);
        }

      } on FirebaseAuthException catch (e) {
        // Handle Error Firebase (Password salah, user gak ada, dll)
        String errorMessage = "Terjadi kesalahan.";
        if (e.code == 'user-not-found') errorMessage = "Email tidak terdaftar.";
        if (e.code == 'wrong-password') errorMessage = "Password salah.";
        if (e.code == 'invalid-email') errorMessage = "Format email salah.";

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

  void goToRegister() {
    Get.toNamed(Routes.REGISTER, arguments: {'role': currentRole.value});
  }
}