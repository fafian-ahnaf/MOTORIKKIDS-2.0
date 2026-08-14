import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  // --- PALET WARNA KHAS MOTORIKKIDS ---
  final Color bgBase = const Color(0xFFFFF8E7); 
  final Color pinkCeria = const Color(0xFFFF7E95); 
  final Color biruAwan = const Color(0xFF4FC3F7); 
  final Color orenJeruk = const Color(0xFFFFB74D);
  final Color teksGelap = const Color(0xFF4A4A4A);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: bgBase,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: bgBase,
      body: Stack(
        children: [
          // 1. DEKORASI AWAN & LINGKARAN LATAR BELAKANG
          _buildBackgroundPattern(),

          // 2. KONTEN UTAMA
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A. Tombol Kembali
                  _buildBackButton(),
                  const SizedBox(height: 30),

                  // B. Hero Illustration & Title
                  _buildHeroSection(),
                  const SizedBox(height: 36),

                  // C. Kartu Form Input Email
                  _buildFormCard(),
                  const SizedBox(height: 24),

                  // D. Tautan Kembali ke Login
                  _buildFooterLink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      onPressed: () => Get.back(),
      icon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: orenJeruk, width: 2),
          boxShadow: [
            BoxShadow(color: orenJeruk.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Icon(Icons.arrow_back_rounded, size: 20, color: teksGelap),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Center(
      child: Column(
        children: [
          // Lingkaran Ikon Bercahaya
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: orenJeruk.withOpacity(0.5), width: 4),
              boxShadow: [
                BoxShadow(color: orenJeruk.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.lock_reset_rounded, size: 60, color: orenJeruk),
                  Positioned(
                    right: 14,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: pinkCeria, shape: BoxShape.circle),
                      child: const Icon(Icons.mark_email_unread_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Judul Utama
          Text(
            "Lupa Kata Sandi? 🔑",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: teksGelap),
          ),
          const SizedBox(height: 10),

          // Subjudul Ramah
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Tenang Bunda/Yanda! Masukkan alamat email yang terdaftar, lalu kami akan mengirimkan tautan untuk membuat kata sandi baru. ✨",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: teksGelap.withOpacity(0.7), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: orenJeruk.withOpacity(0.4), width: 3),
        boxShadow: [
          BoxShadow(color: orenJeruk.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Alamat Email Terdaftar 📧", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: teksGelap)),
          const SizedBox(height: 10),

          // Input Field Email
          TextField(
            controller: controller.emailC,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: teksGelap),
            decoration: InputDecoration(
              hintText: "Contoh: bunda.ahnaf@gmail.com",
              hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w600, fontSize: 13),
              filled: true,
              fillColor: bgBase,
              prefixIcon: Icon(Icons.email_rounded, color: orenJeruk),
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: orenJeruk.withOpacity(0.3), width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: orenJeruk, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Tombol Kirim Tautan Reset
          SizedBox(
            width: double.infinity,
            height: 55,
            child: Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : () => controller.sendPasswordResetEmail(),
              style: ElevatedButton.styleFrom(
                backgroundColor: orenJeruk,
                disabledBackgroundColor: Colors.grey.shade300,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                  : const Text(
                      "Kirim Tautan Reset 🚀",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                    ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink() {
    return Center(
      child: TextButton.icon(
        onPressed: () => Get.back(),
        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: biruAwan),
        label: Text(
          "Sudah ingat kata sandi? Kembali ke Masuk",
          style: TextStyle(color: biruAwan, fontWeight: FontWeight.w900, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Stack(
      children: [
        Positioned(top: -50, right: -50, child: Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, color: orenJeruk.withOpacity(0.12)))),
        Positioned(top: 180, left: -40, child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, color: pinkCeria.withOpacity(0.1)))),
        Positioned(bottom: -30, left: -30, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: biruAwan.withOpacity(0.12)))),
        Positioned(bottom: 150, right: -20, child: Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: orenJeruk.withOpacity(0.1)))),
        Positioned(top: 90, left: 30, child: Icon(Icons.cloud_rounded, color: biruAwan.withOpacity(0.2), size: 40)),
        Positioned(bottom: 80, right: 40, child: Icon(Icons.cloud_rounded, color: pinkCeria.withOpacity(0.2), size: 50)),
      ],
    );
  }
}