import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // GestureDetector ini penting biar keyboard nutup kalau tap area kosong
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                // 1. BACKGROUND DECORATION (Dynamic Color)
                Obx(() => Positioned(
                  top: -100,
                  right: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: controller.themeColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                )),
                Obx(() => Positioned(
                  top: -50,
                  left: -50,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: controller.themeColor.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                )),

                // 2. FORM CONTENT
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(), // Dorong ke tengah
                      
                      // HEADER ICON & TEXT
                      Center(
                        child: Obx(() => Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: controller.lightThemeColor,
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            controller.assetImage, 
                            height: 80,
                            width: 80,
                          ),
                        )),
                      ),
                      const SizedBox(height: 24),
                      
                      Obx(() => Column(
                        children: [
                          Text(
                            "Halo, ${controller.roleLabel}! 👋",
                            style: const TextStyle(
                              fontSize: 26, 
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2D3142),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Senang bertemu Anda kembali.",
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                          ),
                        ],
                      )),

                      const SizedBox(height: 40),

                      // INPUT EMAIL
                      _buildTextField(
                        controller: controller.emailC,
                        label: "Email Address",
                        icon: Icons.email_outlined,
                        inputType: TextInputType.emailAddress,
                      ),
                      
                      const SizedBox(height: 20),

                      // INPUT PASSWORD (With Eye Toggle)
                      Obx(() => _buildTextField(
                        controller: controller.passC,
                        label: "Password",
                        icon: Icons.lock_outline,
                        isObscure: controller.isObscure.value,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isObscure.value ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () => controller.togglePassword(),
                        ),
                      )),

                      // LUPA PASSWORD?
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {}, // Nanti diimplementasi
                          child: const Text("Lupa Password?", style: TextStyle(color: Colors.grey)),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // TOMBOL LOGIN BESAR
                      Obx(() => SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value ? null : () => controller.login(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: controller.themeColor,
                            foregroundColor: Colors.white,
                            elevation: 5,
                            shadowColor: controller.themeColor.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 20, 
                                  width: 20, 
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                )
                              : const Text(
                                  "MASUK SEKARANG",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                                ),
                        ),
                      )),

                      const Spacer(), 

                      // FOOTER REGISTER
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Belum punya akun? ", style: TextStyle(color: Colors.grey.shade600)),
                            Obx(() => GestureDetector(
                              onTap: () => controller.goToRegister(),
                              child: Text(
                                "Daftar disini",
                                style: TextStyle(
                                  color: controller.themeColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // TOMBOL BACK (Pojok Kiri Atas)
                Positioned(
                  top: 50,
                  left: 20,
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: Colors.black12,
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

  // WIDGET TEXTFIELD YANG REUSABLE & CANTIK
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isObscure = false,
    TextInputType inputType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA), // Warna abu-abu sangat muda (Soft)
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent), // Border invisible by default
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: inputType,
        style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(icon, color: Colors.grey.shade500),
          suffixIcon: suffixIcon,
          border: InputBorder.none, // Hilangkan garis bawah default
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
    );
  }
}