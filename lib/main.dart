import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'firebase_options.dart'; 
import 'app/routes/app_pages.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    GetMaterialApp(
      title: "MotorikKids",
      home: const AutoLoginCheck(), // Halaman pengecekan super cepat
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false, 
    ),
  );
}

// ==============================================================
// --- WIDGET PENGECEKAN SESSION (PALING CEPAT & AMAN) ---
// ==============================================================
class AutoLoginCheck extends StatefulWidget {
  const AutoLoginCheck({Key? key}) : super(key: key);

  @override
  State<AutoLoginCheck> createState() => _AutoLoginCheckState();
}

class _AutoLoginCheckState extends State<AutoLoginCheck> {
  @override
  void initState() {
    super.initState();
    // Eksekusi secepat kilat (0 detik) tepat setelah frame UI pertama dirender
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession(); 
    });
  }

  void _checkSession() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser != null) {
        // Cek data di Firestore dengan batas waktu 3 detik
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get()
            .timeout(const Duration(seconds: 3));

        if (doc.exists) {
          String role = doc['role']?.toString().toLowerCase() ?? '';
          
          if (role == 'guru') {
            Get.offAllNamed(Routes.TEACHER_DASHBOARD);
            return; 
          } else if (role == 'parent' || role == 'orangtua' || role == 'orang_tua') {
            Get.offAllNamed(Routes.PARENT_DASHBOARD);
            return; 
          }
        }
      }
      
      // Jika belum login atau sesi tidak valid, langsung ke Welcome
      Get.offAllNamed(Routes.WELCOME);

    } catch (e) {
      debugPrint("Error session: $e");
      // Jika error (misal tidak ada sinyal), langsung ke Welcome
      Get.offAllNamed(Routes.WELCOME);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan kosong polos (hanya warna background) agar transisi secepat kilat
    return const Scaffold(
      backgroundColor: Color(0xFFFFF8E7), 
      body: SizedBox(), 
    );
  }
}