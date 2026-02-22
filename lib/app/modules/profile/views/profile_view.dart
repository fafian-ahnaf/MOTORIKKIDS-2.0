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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // --- 💡 LOGIKA GAMBAR OTOMATIS BERDASARKAN ROLE ---
        bool isParent = controller.role.value == 'parent';
        
        // Pastikan nama file di folder assets Anda sesuai dengan ini:
        String imageAsset = isParent ? 'assets/orang tua.png' : 'assets/guru.png'; 
        
        String roleLabel = isParent ? 'Orang Tua' : 'Guru';
        Color roleColor = isParent ? Colors.green : Colors.orange;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // 1. FOTO PROFIL
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 15)],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blue.shade50,
                    backgroundImage: AssetImage(imageAsset), // <-- MENGGUNAKAN VARIABEL DI ATAS
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. NAMA & LABEL ROLE
              Text(
                controller.name.value, 
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(roleLabel, style: TextStyle(color: roleColor, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 32),

              // 3. INFORMASI KONTAK
              _buildInfoTile(Icons.email_outlined, "Email", controller.email.value),
              const SizedBox(height: 16),
              _buildInfoTile(Icons.phone_outlined, "Nomor Telepon", controller.phone.value),
              const SizedBox(height: 40),

              // 4. TOMBOL KELUAR
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () => controller.logout(),
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text("Keluar Aplikasi", style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // WIDGET HELPER UNTUK KOTAK INFORMASI
  Widget _buildInfoTile(IconData icon, String title, String value) {
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}