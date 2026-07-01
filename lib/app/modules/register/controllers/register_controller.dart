import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../routes/app_pages.dart';

class RegisterController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var currentRole = 'parent'.obs;
  var isLoading = false.obs;
  var isObscure = true.obs;
  var isObscureConfirm = true.obs;
  
  var gender = 'Laki-laki'.obs; 

  // --- TAMBAHAN UNTUK GURU: PILIHAN KELAS ---
  var selectedKelas = 'Kelas A'.obs; 
  final List<String> daftarKelas = ['Kelas A', 'Kelas B', 'Kelas C', 'Kelas D']; 

  var studentList = <Map<String, String>>[].obs; 
  var selectedStudentId = Rxn<String>(); 

  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final phoneC = TextEditingController();
  final passC = TextEditingController();
  final confirmPassC = TextEditingController();
  final tokenAnakC = TextEditingController();

  Color get themeColor => currentRole.value == 'teacher' ? Colors.orange : Colors.blueAccent;
  Color get lightThemeColor => currentRole.value == 'teacher' ? Colors.orange.shade50 : Colors.blue.shade50;
  String get roleName => currentRole.value == 'teacher' ? "Guru" : "Orang Tua";

  @override
  void onInit() {
    super.onInit();
    
    if (Get.arguments != null && Get.arguments['role'] != null) {
      currentRole.value = Get.arguments['role'];
    }

    if (currentRole.value == 'parent') {
      fetchStudents();
    }

    ever(currentRole, (role) {
      if (role == 'parent') {
        fetchStudents();
      } else {
        studentList.clear();
        selectedStudentId.value = null;
      }
    });
  }

  void togglePass() => isObscure.value = !isObscure.value;
  void toggleConfirmPass() => isObscureConfirm.value = !isObscureConfirm.value;

  void fetchStudents() async {
    try {
      var snapshot = await _firestore.collection('students').get(); 
      
      var list = <Map<String, String>>[];
      for (var doc in snapshot.docs) {
        var data = doc.data();
        
        bool hasParent = data.containsKey('parent_id') && data['parent_id'] != null && data['parent_id'] != "";
        
        if (!hasParent) {
          list.add({
            "id": doc.id,
            "name": "${data['name'] ?? 'Tanpa Nama'} - ${data['kelas'] ?? '-'}",
          });
        }
      }
      studentList.value = list;
    } catch (e) {
      print("Error ambil siswa: $e");
    }
  }

  void register() async {
    // 1. Validasi Dasar
    if (nameC.text.isEmpty || emailC.text.isEmpty || passC.text.isEmpty) {
      Get.snackbar("Eits!", "Nama, Email, dan Password wajib diisi.", backgroundColor: Colors.red.shade100);
      return;
    }
    
    // 2. Validasi Password
    if (passC.text != confirmPassC.text) {
      Get.snackbar("Password Salah", "Password dan Konfirmasi tidak sama.", backgroundColor: Colors.orange.shade100);
      return;
    }

    // 3. Validasi Khusus Orang Tua (Token Wajib Isi)
    if (currentRole.value == 'parent' && tokenAnakC.text.trim().isEmpty) {
      Get.snackbar("Token Kosong", "Silakan masukkan Token Anak yang didapat dari Guru.", backgroundColor: Colors.orange.shade100);
      return;
    }

    try {
      isLoading.value = true;
      String? studentDocIdToUpdate; 

      // 4. CEK VALIDITAS TOKEN (Khusus Orang Tua)
      if (currentRole.value == 'parent') {
        var snapshot = await _firestore.collection('students')
            .where('token_ortu', isEqualTo: tokenAnakC.text.trim())
            .get();

        if (snapshot.docs.isEmpty) {
          isLoading.value = false;
          Get.snackbar("Token Tidak Valid", "Token anak tidak ditemukan. Pastikan token persis seperti yang diberikan guru.", backgroundColor: Colors.red.shade100, colorText: Colors.red[900]);
          return; 
        } 
        
        var dataAnak = snapshot.docs.first.data();
        if (dataAnak['parent_id'] != null && dataAnak['parent_id'].toString().isNotEmpty) {
          isLoading.value = false;
          Get.snackbar("Token Kadaluarsa", "Token ini sudah digunakan oleh akun orang tua lain.", backgroundColor: Colors.orange.shade100, colorText: Colors.orange[900]);
          return; 
        }

        studentDocIdToUpdate = snapshot.docs.first.id;
      }

      // 5. Buat Akun Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailC.text.trim(), 
        password: passC.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // 6. Simpan Profil ke Firestore 'users'
      Map<String, dynamic> userData = {
        'uid': uid,
        'nama_lengkap': nameC.text.trim(),
        'email': emailC.text.trim(),
        'no_telp': phoneC.text.trim(),
        'role': currentRole.value,
        'jenis_kelamin': gender.value,
        'created_at': FieldValue.serverTimestamp(),
      };

      // --- TAMBAHAN: JIKA GURU, SIMPAN DATA KELAS ---
      if (currentRole.value == 'teacher') {
        userData['kelas'] = selectedKelas.value;
      }

      await _firestore.collection('users').doc(uid).set(userData);

      // 7. Jika Orang Tua, Hubungkan Akun Ortu ke Data Anak
      if (currentRole.value == 'parent' && studentDocIdToUpdate != null) {
        await _firestore.collection('students').doc(studentDocIdToUpdate).update({
          'parent_id': uid, 
        });
      }

      Get.snackbar("Berhasil 🎉", "Akun berhasil dibuat. Silakan Login.", backgroundColor: Colors.green.shade100);
      
      await _auth.signOut();
      Get.offAllNamed(Routes.LOGIN);

    } on FirebaseAuthException catch (e) {
      String msg = "Terjadi kesalahan.";
      if (e.code == 'email-already-in-use') msg = "Email sudah terdaftar.";
      if (e.code == 'weak-password') msg = "Password terlalu lemah.";
      if (e.code == 'invalid-email') msg = "Format email salah.";
      
      Get.snackbar("Gagal Daftar", msg, backgroundColor: Colors.red.shade100, colorText: Colors.red[900]);
    } catch (e) {
      Get.snackbar("Error", "Sistem sedang sibuk, coba lagi nanti.", backgroundColor: Colors.red.shade100);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameC.dispose();
    emailC.dispose();
    phoneC.dispose();
    passC.dispose();
    confirmPassC.dispose();
    tokenAnakC.dispose();
    super.onClose();
  }
}