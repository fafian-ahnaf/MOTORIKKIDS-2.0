import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({Key? key}) : super(key: key); 

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            
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
            
            
            SafeArea(
              child: Column(
                children: [
                  
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
                            const Text("Buat Akun Baru", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            Obx(() => Text("Sebagai ${controller.roleName}", style: TextStyle(color: controller.themeColor, fontWeight: FontWeight.w600))),
                          ],
                        ),
                      ],
                    ),
                  ),

                  
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Nama Lengkap"),
                          _buildTextField(controller: controller.nameC, hint: "Contoh: Budi Santoso", icon: Icons.person_outline),
                          const SizedBox(height: 20),

                          _buildLabel("Alamat Email"),
                          _buildTextField(controller: controller.emailC, hint: "nama@email.com", icon: Icons.email_outlined, inputType: TextInputType.emailAddress),
                          const SizedBox(height: 20),

                          _buildLabel("Nomor WhatsApp"),
                          _buildTextField(controller: controller.phoneC, hint: "0812xxxx", icon: Icons.phone_android_outlined, inputType: TextInputType.phone),
                          const SizedBox(height: 20),

                          _buildLabel("Jenis Kelamin"),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(16)),
                            child: Row(children: [
                              Icon(Icons.wc_rounded, color: Colors.grey.shade500),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Obx(() => DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: controller.gender.value,
                                    isExpanded: true,
                                    onChanged: (val) { if(val!=null) controller.gender.value = val; },
                                    items: ['Laki-laki', 'Perempuan'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                                  ),
                                )),
                              ),
                            ]),
                          ),
                          const SizedBox(height: 20),

                          _buildLabel("Password"),
                          Obx(() => _buildTextField(
                            controller: controller.passC, hint: "Minimal 6 karakter", icon: Icons.lock_outline, 
                            isObscure: controller.isObscure.value,
                            suffixIcon: IconButton(icon: Icon(controller.isObscure.value ? Icons.visibility_off : Icons.visibility), onPressed: () => controller.togglePass()),
                          )),
                          const SizedBox(height: 20),

                          _buildLabel("Ulangi Password"),
                          Obx(() => _buildTextField(
                            controller: controller.confirmPassC, hint: "Pastikan password sama", icon: Icons.verified_user_outlined, 
                            isObscure: controller.isObscureConfirm.value,
                            suffixIcon: IconButton(icon: Icon(controller.isObscureConfirm.value ? Icons.visibility_off : Icons.visibility), onPressed: () => controller.toggleConfirmPass()),
                          )),
                          const SizedBox(height: 30),

                          
                          Obx(() {
                            if (controller.currentRole.value == 'parent') {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel("Hubungkan Data Anak"),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                    decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blueAccent.withOpacity(0.3))),
                                    child: Row(children: [
                                      const Icon(Icons.child_care_rounded, color: Colors.blueAccent),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: controller.selectedStudentId.value,
                                            hint: const Text("Cari nama anak...", style: TextStyle(color: Colors.grey)),
                                            isExpanded: true,
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

                          Obx(() => SizedBox(
                            width: double.infinity, height: 55,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value ? null : () => controller.register(),
                              style: ElevatedButton.styleFrom(backgroundColor: controller.themeColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                              child: controller.isLoading.value ? const CircularProgressIndicator(color: Colors.white) : const Text("DAFTAR SEKARANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8, left: 4), child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)));
  
  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool isObscure = false, TextInputType inputType = TextInputType.text, Widget? suffixIcon}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(16)),
      child: TextField(controller: controller, obscureText: isObscure, keyboardType: inputType, decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: Colors.grey), suffixIcon: suffixIcon, border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16))),
    );
  }
}