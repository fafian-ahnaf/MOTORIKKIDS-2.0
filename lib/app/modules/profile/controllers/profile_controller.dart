import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:motorikkids/app/routes/app_pages.dart';

class ProfileController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var name = ''.obs;
  var email = ''.obs;
  var role = ''.obs;
  var phone = ''.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  void loadUserProfile() async {
    try {
      User? user = auth.currentUser;
      if (user != null) {
        var doc = await firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          var data = doc.data();
          name.value = data?['nama_lengkap'] ?? user.displayName ?? 'Pengguna';
          email.value = data?['email'] ?? user.email ?? '-';
          role.value = data?['role'] ?? 'User';
          phone.value = data?['no_telp'] ?? '-';
        } else {
          name.value = user.displayName ?? 'Pengguna';
          email.value = user.email ?? '-';
        }
      }
    } catch (e) {
      print("Error loading profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    await auth.signOut();
    Get.offAllNamed(Routes.WELCOME);
  }
}