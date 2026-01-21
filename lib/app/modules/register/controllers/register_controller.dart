import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../../../routes/app_pages.dart';

class RegisterController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Data Role & UI State
  var currentRole = 'parent'.obs;
  var isLoading = false.obs;
  var isObscure = true.obs;
  var isObscureConfirm = true.obs;

  // Text Controllers
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final phoneC = TextEditingController();
  final passC = TextEditingController();
  final confirmPassC = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments['role'] != null) {
      currentRole.value = Get.arguments['role'];
    }
  }

  // Getter Helper UI
  Color get themeColor => currentRole.value == 'teacher' ? Colors.orange : Colors.blueAccent;
  Color get lightThemeColor => currentRole.value == 'teacher' ? Colors.orange.shade50 : Colors.blue.shade50;
  String get roleName => currentRole.value == 'teacher' ? "Guru" : "Orang Tua";

  void togglePass() => isObscure.value = !isObscure.value;
  void toggleConfirmPass() => isObscureConfirm.value = !isObscureConfirm.value;

  // --- FUNGSI REGISTER FIREBASE ---
  void register() async {
    // 1. Validasi Input
    if (nameC.text.isEmpty || emailC.text.isEmpty || passC.text.isEmpty) {
      Get.snackbar("Eits!", "Nama, Email, dan Password wajib diisi.", backgroundColor: Colors.red.shade100);
      return;
    }

    if (passC.text != confirmPassC.text) {
      Get.snackbar("Password Tidak Sama", "Cek lagi password konfirmasinya.", backgroundColor: Colors.orange.shade100);
      return;
    }

    try {
      isLoading.value = true;

      // 2. Buat Akun di Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailC.text.trim(),
        password: passC.text.trim(),
      );

      // 3. Simpan Data Profil ke Firestore (Database)
      // Kita pakai UID dari Auth sebagai nama dokumen agar mudah dicari
      String uid = userCredential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'nama_lengkap': nameC.text,
        'email': emailC.text.trim(),
        'no_telp': phoneC.text,
        'role': currentRole.value, // 'teacher' atau 'parent'
        'created_at': FieldValue.serverTimestamp(),
      });

      // 4. Sukses -> Redirect ke Dashboard
      Get.snackbar("Berhasil", "Akun berhasil dibuat!", backgroundColor: Colors.green.shade100);
      
      Get.offAllNamed(
        currentRole.value == 'teacher' ? Routes.TEACHER_DASHBOARD : Routes.PARENT_DASHBOARD
      );

    } on FirebaseAuthException catch (e) {
      // Handle Error Khusus Register
      String msg = "Gagal daftar.";
      if (e.code == 'weak-password') msg = "Password terlalu lemah (min 6 karakter).";
      if (e.code == 'email-already-in-use') msg = "Email sudah terdaftar. Silakan login.";
      
      Get.snackbar("Gagal Daftar", msg, backgroundColor: Colors.red.shade100, colorText: Colors.red[900]);
    } catch (e) {
      print(e);
      Get.snackbar("Error", "Terjadi kesalahan sistem.", backgroundColor: Colors.red.shade100);
    } finally {
      isLoading.value = false;
    }
  }
}