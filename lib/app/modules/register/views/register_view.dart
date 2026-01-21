import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Tutup keyboard saat tap luar
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // 1. BACKGROUND DECORATION (Bola-bola warna di pojok)
            Obx(() => Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: controller.themeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            )),
            
            // 2. MAIN CONTENT
            SafeArea(
              child: Column(
                children: [
                  // HEADER CUSTOM (Tombol Back + Judul)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey.shade100,
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Buat Akun Baru",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            Obx(() => Text(
                              "Sebagai ${controller.roleName}",
                              style: TextStyle(color: controller.themeColor, fontWeight: FontWeight.w600),
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // FORM SCROLLABLE
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Lengkapi data diri Anda untuk memulai.", style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 30),

                          // NAMA LENGKAP
                          _buildLabel("Nama Lengkap"),
                          _buildTextField(
                            controller: controller.nameC,
                            hint: "Contoh: Budi Santoso",
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 20),

                          // EMAIL
                          _buildLabel("Alamat Email"),
                          _buildTextField(
                            controller: controller.emailC,
                            hint: "nama@email.com",
                            icon: Icons.email_outlined,
                            inputType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),

                          // NO HP (Opsional tapi bagus utk UX)
                          _buildLabel("Nomor WhatsApp"),
                          _buildTextField(
                            controller: controller.phoneC,
                            hint: "0812xxxx",
                            icon: Icons.phone_android_outlined,
                            inputType: TextInputType.phone,
                          ),
                          const SizedBox(height: 20),

                          // PASSWORD
                          _buildLabel("Password"),
                          Obx(() => _buildTextField(
                            controller: controller.passC,
                            hint: "Minimal 6 karakter",
                            icon: Icons.lock_outline,
                            isObscure: controller.isObscure.value,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isObscure.value ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () => controller.togglePass(),
                            ),
                          )),
                          const SizedBox(height: 20),

                          // KONFIRMASI PASSWORD
                          _buildLabel("Ulangi Password"),
                          Obx(() => _buildTextField(
                            controller: controller.confirmPassC,
                            hint: "Pastikan password sama",
                            icon: Icons.verified_user_outlined,
                            isObscure: controller.isObscureConfirm.value,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isObscureConfirm.value ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () => controller.toggleConfirmPass(),
                            ),
                          )),
                          
                          const SizedBox(height: 40),

                          // TOMBOL DAFTAR
                          Obx(() => SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value ? null : () => controller.register(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: controller.themeColor,
                                elevation: 3,
                                shadowColor: controller.themeColor.withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: controller.isLoading.value 
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    "DAFTAR SEKARANG",
                                    style: TextStyle(
                                      color: Colors.white, 
                                      fontSize: 16, 
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                            ),
                          )),
                          
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET HELPER: Label Input
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }

  // WIDGET HELPER: Input Field Soft UI
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isObscure = false,
    TextInputType inputType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA), // Abu-abu sangat muda
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: inputType,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(icon, color: Colors.grey.shade500),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}