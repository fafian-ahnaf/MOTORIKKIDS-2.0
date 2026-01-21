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

  @override
  void onInit() {
    super.onInit();
    loadParentData();
  }

  void loadParentData() async {
    try {
      String uid = _auth.currentUser!.uid;

      // 1. Ambil Nama Orang Tua
      var userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        parentName.value = userDoc.data()?['nama_lengkap'] ?? "Ayah/Bunda";
      }

      // 2. Cari Anak yang parent_id nya sama dengan UID ini
      var anakQuery = await _firestore
          .collection('students')
          .where('parent_id', isEqualTo: uid)
          .limit(1) // Ambil 1 anak dulu
          .get();

      if (anakQuery.docs.isNotEmpty) {
        var anakData = anakQuery.docs.first.data();
        childName.value = anakData['nama_siswa'];
        className.value = anakData['kelas'];
      }
    } catch (e) {
      print("Error loading parent data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    await _auth.signOut();
    Get.offAllNamed(Routes.WELCOME);
  }
}