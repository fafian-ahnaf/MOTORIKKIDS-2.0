import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({Key? key}) : super(key: key); 

  // --- PALET WARNA CERIA TAMBAHAN ---
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
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white, shape: BoxShape.circle, 
                border: Border.all(color: controller.themeColor, width: 2),
                boxShadow: [BoxShadow(color: controller.themeColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
              ),
              child: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.black87),
            ),
            onPressed: () => Get.back(),
          ),
        ),
        body: Stack(
          children: [
            // ============================================================
            // --- BACKGROUND DEKORASI ---
            // ============================================================
            Positioned(
              top: -80, right: -50,
              child: Container(
                width: 250, height: 250,
                decoration: BoxDecoration(color: controller.themeColor.withOpacity(0.2), shape: BoxShape.circle),
              ),
            ),
            Positioned(
              bottom: -100, left: -50,
              child: Container(
                width: 300, height: 300,
                decoration: BoxDecoration(color: controller.lightThemeColor.withOpacity(0.5), shape: BoxShape.circle),
              ),
            ),
            
            Positioned(top: 150, left: 30, child: Icon(Icons.circle, color: pinkCeria.withOpacity(0.15), size: 50)),
            Positioned(bottom: 250, right: 30, child: Icon(Icons.circle, color: orenJeruk.withOpacity(0.2), size: 70)),
            Positioned(top: 200, right: 20, child: Icon(Icons.cloud_rounded, color: Colors.white.withOpacity(0.8), size: 80)),
            Positioned(bottom: 120, left: 40, child: Icon(Icons.cloud_rounded, color: Colors.white.withOpacity(0.6), size: 60)),

            // ============================================================
            // --- KONTEN UTAMA ---
            // ============================================================
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          
                          // --- ILUSTRASI ---
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle,
                                border: Border.all(color: controller.themeColor, width: 4),
                                boxShadow: [BoxShadow(color: controller.themeColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                              ),
                              child: Icon(Icons.face_retouching_natural_rounded, size: 60, color: controller.themeColor),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // --- TEKS SAMBUTAN ---
                          Text(
                            "Halo Teman Baru!", 
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: teksGelap)
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Yuk isi data untuk bergabung\nsebagai ${controller.roleName}!", 
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.grey.shade600, height: 1.5)
                          ),
                          const SizedBox(height: 40),

                          // --- FORM PENGISIAN ---
                          _buildLabel("Siapa Namamu?"),
                          _buildTextField(controller: controller.nameC, hint: "Nama Lengkap", icon: Icons.person_rounded),
                          const SizedBox(height: 20),

                          _buildLabel("Alamat Email"),
                          _buildTextField(controller: controller.emailC, hint: "nama@email.com", icon: Icons.email_rounded, inputType: TextInputType.emailAddress),
                          const SizedBox(height: 20),

                          _buildLabel("Nomor WhatsApp"),
                          _buildTextField(controller: controller.phoneC, hint: "0812xxxx", icon: Icons.phone_android_rounded, inputType: TextInputType.phone),
                          const SizedBox(height: 20),

                          // --- DROPDOWN JENIS KELAMIN ---
                          _buildLabel("Jenis Kelamin"),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white, 
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: controller.themeColor.withOpacity(0.3), width: 3),
                            ),
                            child: Row(children: [
                              Icon(Icons.wc_rounded, color: controller.themeColor),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Obx(() => DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: controller.gender.value,
                                    isExpanded: true,
                                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: controller.themeColor),
                                    style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black87), 
                                    onChanged: (val) { if(val!=null) controller.gender.value = val; },
                                    items: ['Laki-laki', 'Perempuan'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                                  ),
                                )),
                              ),
                            ]),
                          ),
                          const SizedBox(height: 20),

                          // --- PASSWORD ---
                          _buildLabel("Buat Password"),
                          Obx(() => _buildTextField(
                            controller: controller.passC, hint: "Minimal 6 karakter", icon: Icons.lock_rounded, 
                            isObscure: controller.isObscure.value,
                            suffixIcon: IconButton(icon: Icon(controller.isObscure.value ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey), onPressed: () => controller.togglePass()),
                          )),
                          const SizedBox(height: 20),

                          _buildLabel("Ulangi Password"),
                          Obx(() => _buildTextField(
                            controller: controller.confirmPassC, hint: "Pastikan password sama", icon: Icons.verified_user_rounded, 
                            isObscure: controller.isObscureConfirm.value,
                            suffixIcon: IconButton(icon: Icon(controller.isObscureConfirm.value ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey), onPressed: () => controller.toggleConfirmPass()),
                          )),
                          const SizedBox(height: 30),

                          // --- KHUSUS ORANG TUA (HUBUNGKAN DATA ANAK) ---
                          Obx(() {
                            if (controller.currentRole.value == 'parent') {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel("Ananda yang mana?"),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white, 
                                      borderRadius: BorderRadius.circular(25), 
                                      border: Border.all(color: biruAwan, width: 3)
                                    ),
                                    child: Row(children: [
                                      Icon(Icons.child_care_rounded, color: biruAwan),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: controller.selectedStudentId.value,
                                            hint: Text("Pilih nama anak...", style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w700)),
                                            isExpanded: true,
                                            icon: Icon(Icons.keyboard_arrow_down_rounded, color: biruAwan),
                                            style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black87),
                                            onChanged: (val) => controller.selectedStudentId.value = val,
                                            items: controller.studentList.map((item) => DropdownMenuItem(value: item['id'], child: Text(item['name']!, overflow: TextOverflow.ellipsis))).toList(),
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ),
                                  const SizedBox(height: 30),
                                ],
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),

                          // --- TOMBOL DAFTAR ---
                          Obx(() => SizedBox(
                            width: double.infinity, height: 60, 
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value ? null : () => controller.register(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: controller.themeColor, 
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), 
                                elevation: 5,
                                shadowColor: controller.themeColor.withOpacity(0.5)
                              ),
                              child: controller.isLoading.value 
                                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) 
                                : const Text("BUAT AKUN!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1)),
                            ),
                          )),
                          
                          const SizedBox(height: 20),

                          // --- TOMBOL KEMBALI KE LOGIN ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Sudah punya akun?", style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade600)),
                              TextButton(
                                onPressed: () => Get.back(), 
                                child: Text("Masuk yuk!", style: TextStyle(fontWeight: FontWeight.w900, color: controller.themeColor, fontSize: 16)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4), 
      child: Text(text, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: teksGelap))
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller, 
    required String hint, 
    required IconData icon, 
    bool isObscure = false, 
    TextInputType inputType = TextInputType.text, 
    Widget? suffixIcon
  }) {
    Color themeColor = this.controller.themeColor;
    return TextField(
      controller: controller, 
      obscureText: isObscure, 
      keyboardType: inputType, 
      style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint, 
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
      )
    );
  }
}