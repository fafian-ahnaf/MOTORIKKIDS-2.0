import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../../../routes/app_pages.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  // --- PALET WARNA CERIA ---
  final Color bgBase = const Color(0xFFFFF8E7); 
  final Color orenJeruk = const Color(0xFFFFB74D);
  final Color pinkCeria = const Color(0xFFFF7E95); 
  final Color biruAwan = const Color(0xFF4FC3F7); 
  final Color teksGelap = const Color(0xFF4A4A4A);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: bgBase,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: bgBase,
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                // ============================================================
                // --- BACKGROUND DEKORASI ---
                // ============================================================
                // Menggunakan getter/variabel biasa untuk warna tema agar tidak error Obx
                Positioned(
                  top: -80,
                  left: -50,
                  child: Container(
                    width: 250, height: 250,
                    decoration: BoxDecoration(
                      color: controller.themeColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -100,
                  right: -50,
                  child: Container(
                    width: 300, height: 300,
                    decoration: BoxDecoration(
                      color: controller.lightThemeColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                Positioned(top: 100, right: 30, child: Icon(Icons.circle, color: pinkCeria.withOpacity(0.15), size: 60)),
                Positioned(bottom: 250, left: 20, child: Icon(Icons.circle, color: orenJeruk.withOpacity(0.15), size: 80)),
                Positioned(top: 180, left: 20, child: Icon(Icons.cloud_rounded, color: Colors.white.withOpacity(0.8), size: 70)),
                Positioned(bottom: 120, right: 40, child: Icon(Icons.cloud_rounded, color: Colors.white.withOpacity(0.6), size: 90)),

                // ============================================================
                // --- KONTEN UTAMA ---
                // ============================================================
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(), 
                        
                        // --- ILUSTRASI PROFIL ---
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: controller.themeColor, width: 4),
                              boxShadow: [BoxShadow(color: controller.themeColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                            ),
                            child: Image.asset(
                              controller.assetImage, 
                              height: 80, width: 80, fit: BoxFit.contain,
                              errorBuilder: (c, e, s) => Icon(Icons.face_retouching_natural_rounded, size: 80, color: controller.themeColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // --- TEKS SAMBUTAN ---
                        Text(
                          "Halo, ${controller.roleLabel}! 👋",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: teksGelap),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Yuk masuk untuk mulai aktivitasmu.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: teksGelap.withOpacity(0.6), fontSize: 16, fontWeight: FontWeight.w700),
                        ),

                        const SizedBox(height: 40),

                        // --- FORM EMAIL ---
                        _buildTextField(
                          controller: controller.emailC,
                          label: "Alamat Email",
                          icon: Icons.email_rounded,
                          inputType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),

                        // --- FORM PASSWORD ---
                        Obx(() => _buildTextField(
                          controller: controller.passC,
                          label: "Kata Sandi",
                          icon: Icons.lock_rounded,
                          isObscure: controller.isObscure.value,
                          suffixIcon: IconButton(
                            icon: Icon(controller.isObscure.value ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey),
                            onPressed: () => controller.togglePassword(),
                          ),
                        )),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {}, 
                            child: Text("Lupa Kata Sandi?", style: TextStyle(color: orenJeruk, fontWeight: FontWeight.w900)),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // --- TOMBOL MASUK ---
                        Obx(() => SizedBox(
                          height: 60,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value ? null : () => controller.login(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: controller.themeColor,
                              foregroundColor: Colors.white,
                              elevation: 5,
                              shadowColor: controller.themeColor.withOpacity(0.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                : const Text("MASUK SEKARANG!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                          ),
                        )),

                        const Spacer(), 

                        // --- TOMBOL DAFTAR ---
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Belum punya akun? ", style: TextStyle(color: teksGelap.withOpacity(0.6), fontWeight: FontWeight.w700)),
                              GestureDetector(
                                onTap: () => controller.goToRegister(),
                                child: Text("Daftar disini", style: TextStyle(color: controller.themeColor, fontWeight: FontWeight.w900, fontSize: 15)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // --- TOMBOL KEMBALI MELAYANG ---
                Positioned(
                  top: 50, left: 20,
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.arrow_back_rounded, color: controller.themeColor, size: 24),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: Colors.black12,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isObscure = false,
    TextInputType inputType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    Color themeColor = this.controller.themeColor;
    return TextField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: inputType,
      style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black87),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w700),
        prefixIcon: Icon(icon, color: themeColor),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: themeColor.withOpacity(0.3), width: 3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: themeColor, width: 3),
        ),
      ),
    );
  }
}