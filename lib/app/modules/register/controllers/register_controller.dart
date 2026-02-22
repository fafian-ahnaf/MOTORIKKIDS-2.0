import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../routes/app_pages.dart';

class RegisterController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- UI STATE & DATA ---
  var currentRole = 'parent'.obs;
  var isLoading = false.obs;
  var isObscure = true.obs;
  var isObscureConfirm = true.obs;
  
  var gender = 'Laki-laki'.obs; 

  // --- DROPDOWN ANAK ---
  var studentList = <Map<String, String>>[].obs; 
  var selectedStudentId = Rxn<String>(); 

  // --- TEXT CONTROLLERS ---
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final phoneC = TextEditingController();
  final passC = TextEditingController();
  final confirmPassC = TextEditingController();

  // --- GETTER HELPER (Untuk UI Warna & Teks) ---
  Color get themeColor => currentRole.value == 'teacher' ? Colors.orange : Colors.blueAccent;
  Color get lightThemeColor => currentRole.value == 'teacher' ? Colors.orange.shade50 : Colors.blue.shade50;
  String get roleName => currentRole.value == 'teacher' ? "Guru" : "Orang Tua";

  @override
  void onInit() {
    super.onInit();
    // 1. Ambil Argumen Role (dengan keamanan null check)
    if (Get.arguments != null && Get.arguments['role'] != null) {
      currentRole.value = Get.arguments['role'];
    }

    // 2. Load siswa pertama kali jika role Parent
    if (currentRole.value == 'parent') {
      fetchStudents();
    }

    // 3. (Opsional) Listener: Jika role berubah, otomatis load/clear siswa
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

  // --- AMBIL DAFTAR SISWA DARI FIREBASE ---
  void fetchStudents() async {
    try {
      // Ambil semua data siswa
      var snapshot = await _firestore.collection('students').get(); 
      
      var list = <Map<String, String>>[];
      for (var doc in snapshot.docs) {
        var data = doc.data();
        
        // Filter: Hanya siswa yang BELUM punya parent_id
        // Menggunakan logic: field tidak ada ATAU field null ATAU field string kosong
        bool hasParent = data.containsKey('parent_id') && data['parent_id'] != null && data['parent_id'] != "";
        
        if (!hasParent) {
          list.add({
            "id": doc.id,
            // Pakai ?? agar tidak error/muncul null jika data nama/kelas kosong
            "name": "${data['name'] ?? 'Tanpa Nama'} - ${data['kelas'] ?? '-'}",
          });
        }
      }
      studentList.value = list;
    } catch (e) {
      print("Error ambil siswa: $e");
    }
  }

  // --- FUNGSI REGISTER UTAMA ---
  void register() async {
    // 1. Validasi Input Dasar
    if (nameC.text.isEmpty || emailC.text.isEmpty || passC.text.isEmpty) {
      Get.snackbar("Eits!", "Nama, Email, dan Password wajib diisi.", backgroundColor: Colors.red.shade100);
      return;
    }
    
    // 2. Validasi Khusus Orang Tua: Wajib Pilih Anak
    if (currentRole.value == 'parent' && selectedStudentId.value == null) {
      Get.snackbar("Pilih Anak", "Silakan pilih nama anak Anda terlebih dahulu untuk menghubungkan data.", backgroundColor: Colors.orange.shade100);
      return;
    }

    // 3. Validasi Password Match
    if (passC.text != confirmPassC.text) {
      Get.snackbar("Password Salah", "Password dan Konfirmasi tidak sama.", backgroundColor: Colors.orange.shade100);
      return;
    }

    try {
      isLoading.value = true;

      // 4. Buat Akun di Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailC.text.trim(), // Trim spasi
        password: passC.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // 5. Simpan Data Profil ke Firestore 'users'
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'nama_lengkap': nameC.text.trim(),
        'email': emailC.text.trim(),
        'no_telp': phoneC.text.trim(),
        'role': currentRole.value,
        'jenis_kelamin': gender.value,
        'created_at': FieldValue.serverTimestamp(),
      });

      // 6. KHUSUS ORANG TUA: Hubungkan ke Data Siswa
      if (currentRole.value == 'parent' && selectedStudentId.value != null) {
        await _firestore.collection('students').doc(selectedStudentId.value).update({
          'parent_id': uid, // ID Orang Tua disimpan di data Anak
        });
      }

      // 7. Sukses & Redirect
      Get.snackbar("Berhasil", "Akun berhasil dibuat. Silakan Login.", backgroundColor: Colors.green.shade100);
      
      // Logout otomatis agar user login manual (untuk refresh state Auth)
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
    super.onClose();
  }
}