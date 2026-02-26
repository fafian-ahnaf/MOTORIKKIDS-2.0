import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart'; 
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
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      
      debugShowCheckedModeBanner: false, 
    ),
  );
}