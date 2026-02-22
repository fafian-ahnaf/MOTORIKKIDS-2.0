import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. Import Firebase Core
import 'firebase_options.dart'; // 2. Import file config yang dibuat CLI tadi
import 'app/routes/app_pages.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 💡 TAMBAHAN: Import dotenv

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 💡 TAMBAHAN: Memuat file .env sebelum aplikasi berjalan
  await dotenv.load(fileName: ".env");

  // 5. Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      // Opsional: Matikan banner debug agar tampilan lebih bersih
      debugShowCheckedModeBanner: false, 
    ),
  );
}