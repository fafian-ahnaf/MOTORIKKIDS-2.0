import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/welcome_controller.dart';

class WelcomeView extends GetView<WelcomeController> {
  const WelcomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Kita pakai MediaQuery biar responsif di HP kecil/besar
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FD), // Putih kebiruan dikit biar gak sakit mata
      body: Stack(
        children: [
          // 1. BACKGROUND DECORATION (Biar gak sepi)
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // 2. MAIN CONTENT
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LOGO DENGAN EFEK SHADOW
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Image.asset('assets/logo_anak.png', height: 100),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // TYPOGRAPHY YANG LEBIH MODERN
                    const Text(
                      "Motorik Kids",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2D3142), // Warna Dark Slate (bukan hitam pekat)
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Pantau tumbuh kembang si kecil\ndengan teknologi cerdas.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    const SizedBox(height: 50),

                    // CARD PILIHAN GURU (Primary Styling)
                    _buildRoleCard(
                      context,
                      title: "Saya Guru",
                      subtitle: "Input observasi & kelola siswa",
                      imagePath: "assets/guru.png",
                      primaryColor: Colors.orange,
                      accentColor: const Color(0xFFFFE0B2), // Orange muda
                      onTap: () => Get.toNamed(Routes.LOGIN, arguments: {'role': 'teacher'}),
                    ),

                    const SizedBox(height: 20),

                    // CARD PILIHAN ORANG TUA (Secondary Styling)
                    _buildRoleCard(
                      context,
                      title: "Saya Orang Tua",
                      subtitle: "Lihat hasil perkembangan anak",
                      imagePath: "assets/orang tua.png",
                      primaryColor: Colors.blueAccent,
                      accentColor: const Color(0xFFBBDEFB), // Biru muda
                      onTap: () => Get.toNamed(Routes.LOGIN, arguments: {'role': 'parent'}),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Footer version (Opsional)
                    Text(
                      "v1.0.0 • Universitas Harkat Negeri",
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET CARD "PRO" LEVEL
  // Menggunakan Material + InkWell untuk efek sentuh (Ripple Effect)
  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imagePath,
    required Color primaryColor,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Radius besar = modern
        boxShadow: [
          // Multi-layer shadow biar terlihat "mengambang" (depth)
          BoxShadow(
            color: primaryColor.withOpacity(0.08),
            offset: const Offset(0, 10),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: primaryColor.withOpacity(0.1), // Efek cipratan warna saat diklik
          highlightColor: primaryColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Container untuk Gambar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Image.asset(imagePath, width: 50, height: 50),
                ),
                const SizedBox(width: 20),
                
                // Teks Judul & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Icon Panah
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}