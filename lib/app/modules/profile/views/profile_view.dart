import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  final Color bgBase = const Color(0xFFFFF8E7);
  final Color pinkCeria = const Color(0xFFFF7E95);
  final Color biruAwan = const Color(0xFF4FC3F7);
  final Color teksGelap = const Color(0xFF4A4A4A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBase,
      appBar: AppBar(
        title: Text("Edit Profil", style: TextStyle(color: teksGelap, fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: teksGelap),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: pinkCeria));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // --- FOTO PROFIL ---
              Center(
                child: GestureDetector(
                  onTap: () => controller.pickImage(),
                  child: Stack(
                    children: [
                      Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: biruAwan, width: 4),
                          boxShadow: [BoxShadow(color: biruAwan.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
                        ),
                        child: ClipOval(
                          child: _buildAvatarImage(),
                        ),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: pinkCeria, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text("Ketuk foto untuk mengubah", style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 32),

              // --- FORM EDIT ---
              _buildLabel("Nama Lengkap"),
              _buildTextField(controller.nameC, Icons.person_rounded),
              const SizedBox(height: 16),

              _buildLabel("Nomor WhatsApp"),
              _buildTextField(controller.phoneC, Icons.phone_android_rounded, isPhone: true),
              const SizedBox(height: 16),

              _buildLabel("Jenis Kelamin"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300, width: 2)),
                child: Row(children: [
                  Icon(Icons.wc_rounded, color: biruAwan),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.gender.value,
                        isExpanded: true,
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black87), 
                        onChanged: (val) { if(val!=null) controller.gender.value = val; },
                        items: ['Laki-laki', 'Perempuan'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                      ),
                    )),
                  ),
                ]),
              ),
              const SizedBox(height: 40),

              // --- TOMBOL SIMPAN ---
              SizedBox(
                width: double.infinity, height: 55,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isSaving.value ? null : () => controller.updateProfile(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: biruAwan,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 5
                  ),
                  child: controller.isSaving.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                )),
              ),

              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () => controller.logout(), 
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent), 
                label: const Text("Keluar (Logout)", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
              )
            ],
          ),
        );
      }),
    );
  }

  // --- HELPER UNTUK MENAMPILKAN GAMBAR ---
  Widget _buildAvatarImage() {
    // 1. Jika ada file gambar lokal yang baru dipilih
    if (controller.selectedImage.value != null) {
      return Image.file(controller.selectedImage.value!, fit: BoxFit.cover);
    } 
    // 2. Jika ada link foto dari database
    else if (controller.profilePicUrl.value.isNotEmpty) {
      return Image.network(
        controller.profilePicUrl.value, 
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
      );
    } 
    // 3. Jika sama sekali tidak ada foto
    else {
      return _buildFallbackIcon();
    }
  }

  Widget _buildFallbackIcon() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(Icons.person_rounded, size: 60, color: Colors.grey.shade400),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8, left: 4), child: Text(text, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: teksGelap)));

  Widget _buildTextField(TextEditingController ctrl, IconData icon, {bool isPhone = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black87),
      decoration: InputDecoration(
        filled: true, fillColor: Colors.white,
        prefixIcon: Icon(icon, color: biruAwan),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade300, width: 2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: biruAwan, width: 2)),
      ),
    );
  }
}