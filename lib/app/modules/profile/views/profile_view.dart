import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text("Profil Saya", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Tentukan Label Role
        String roleLabel = "Pengguna";
        Color roleColor = Colors.grey;
        if (controller.role.value == 'teacher') {
          roleLabel = "Guru Pengajar";
          roleColor = Colors.blue;
        } else if (controller.role.value == 'parent') {
          roleLabel = "Orang Tua";
          roleColor = Colors.green;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Foto Profil Besar
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFFE8F5E9),
                  backgroundImage: const AssetImage('assets/guru.png'), // Bisa diganti logic asset sesuai role jika mau
                ),
              ),
              const SizedBox(height: 16),
              
              // Nama & Role
              Text(
                controller.name.value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  roleLabel,
                  style: TextStyle(fontWeight: FontWeight.bold, color: roleColor, fontSize: 12),
                ),
              ),

              const SizedBox(height: 40),

              // Informasi Detail
              _buildInfoTile(Icons.email_outlined, "Email", controller.email.value),
              const SizedBox(height: 16),
              _buildInfoTile(Icons.phone_outlined, "Nomor Telepon", controller.phone.value),
              
              const SizedBox(height: 50),

              // Tombol Logout
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => controller.logout(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.red.shade400),
                      const SizedBox(width: 8),
                      Text("Keluar Aplikasi", style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.grey.shade600, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}