import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class ParentDashboardController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var parentName = "Memuat...".obs;
  var childName = "Belum ada data anak".obs;
  var className = "-".obs;
  var isLoading = true.obs;
  var panggilan = "".obs;
  
  // --- TAMBAHAN: Simpan ID Siswa ---
  var studentId = "".obs; 

  @override
  void onInit() {
    super.onInit();
    loadParentData();
  }

  void loadParentData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;
      String uid = user.uid;

      // 1. Ambil Data Orang Tua
      var userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        var data = userDoc.data();
        parentName.value = data?['nama_lengkap'] ?? "Ayah/Bunda";
        
        String gender = data?['jenis_kelamin'] ?? "";
        if (gender == "Laki-laki") panggilan.value = "Pak";
        else if (gender == "Perempuan") panggilan.value = "Bu";
      }

      // 2. Cari Anak (Sesuai parent_id)
      var anakQuery = await _firestore
          .collection('students')
          .where('parent_id', isEqualTo: uid)
          .limit(1) 
          .get();

      if (anakQuery.docs.isNotEmpty) {
        var anakDoc = anakQuery.docs.first; // Ambil Dokumen
        var anakData = anakDoc.data();
        
        childName.value = anakData['name'] ?? "Tanpa Nama"; 
        className.value = anakData['kelas'] ?? "-";
        
        // --- SIMPAN ID SISWA DI SINI ---
        studentId.value = anakDoc.id; 
      } else {
        childName.value = "Belum terhubung";
        className.value = "-";
      }
    } catch (e) {
      print("Error loading parent data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String getSalam() {
    var hour = DateTime.now().hour;
    if (hour < 11) return "Selamat Pagi";
    if (hour < 15) return "Selamat Siang";
    if (hour < 18) return "Selamat Sore";
    return "Selamat Malam";
  }

  void logout() async {
    await _auth.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }
}