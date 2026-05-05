import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends StatelessWidget {
  ForgotPasswordView({Key? key}) : super(key: key);

  // Menginisiasi controller secara langsung di sini agar praktis
  final ForgotPasswordController controller = Get.put(ForgotPasswordController());

  // --- PALET WARNA ---
  final Color bgBase = const Color(0xFFFFF8E7); 
  final Color orenJeruk = const Color(0xFFFFB74D);
  final Color pinkCeria = const Color(0xFFFF7E95); 
  final Color biruAwan = const Color(0xFF4FC3F7); 
  final Color teksGelap = const Color(0xFF4A4A4A);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: bgBase,
        appBar: AppBar(
          backgroundColor: bgBase,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: orenJeruk, size: 28),
            onPressed: () => Get.back(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // --- IKON / ILUSTRASI ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: pinkCeria, width: 4),
                  boxShadow: [
                    BoxShadow(color: pinkCeria.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
                  ]
                ),
                child: Icon(Icons.lock_reset_rounded, size: 80, color: pinkCeria),
              ),
              const SizedBox(height: 32),

              // --- TEKS JUDUL ---
              Text(
                "Lupa Kata Sandi? 🔐",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: teksGelap),
              ),
              const SizedBox(height: 12),
              Text(
                "Tenang, jangan panik! Masukkan email yang Anda gunakan saat mendaftar, nanti kami kirimkan kunci rahasia untuk meresetnya.",
                textAlign: TextAlign.center,
                style: TextStyle(color: teksGelap.withOpacity(0.7), fontSize: 15, fontWeight: FontWeight.w600, height: 1.5),
              ),

              const SizedBox(height: 40),

              // --- FORM EMAIL ---
              TextField(
                controller: controller.emailC,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: "Alamat Email Anda",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w700),
                  prefixIcon: Icon(Icons.email_rounded, color: orenJeruk),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: orenJeruk.withOpacity(0.3), width: 3),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: orenJeruk, width: 3),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // --- TOMBOL KIRIM ---
              Obx(() => SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () => controller.resetPassword(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orenJeruk,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shadowColor: orenJeruk.withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text("KIRIM EMAIL RESET", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}