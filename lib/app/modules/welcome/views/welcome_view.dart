import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/welcome_controller.dart';

class WelcomeView extends GetView<WelcomeController> {
  const WelcomeView({Key? key}) : super(key: key);

  // --- PALET WARNA CERIA ANAK-ANAK ---
  final Color bgBase = const Color(0xFFFFF8E7); // Krem hangat
  final Color pinkCeria = const Color(0xFFFF7E95); 
  final Color biruAwan = const Color(0xFF4FC3F7); 
  final Color orenJeruk = const Color(0xFFFFB74D);
  final Color teksGelap = const Color(0xFF4A4A4A);

  @override
  Widget build(BuildContext context) {
    // Agar status bar transparan dan ikonnya gelap
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
          // ============================================================
          // --- BACKGROUND DEKORASI (AWAN & BALON) ---
          // ============================================================
          // Blob Pink Kiri Atas
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: pinkCeria.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Blob Biru Kanan Bawah
          Positioned(
            bottom: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: biruAwan.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          // Ikon Awan dan Bintang tersebar
          Positioned(top: 80, right: 30, child: Icon(Icons.cloud_rounded, color: Colors.white, size: 70)),
          Positioned(top: 150, left: 20, child: Icon(Icons.star_rounded, color: orenJeruk.withOpacity(0.4), size: 40)),
          Positioned(bottom: 250, left: -20, child: Icon(Icons.cloud_rounded, color: Colors.white, size: 100)),
          Positioned(bottom: 120, right: 40, child: Icon(Icons.star_rounded, color: pinkCeria.withOpacity(0.4), size: 30)),

          // ============================================================
          // --- KONTEN UTAMA ---
          // ============================================================
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    
                    // --- GAMBAR ILUSTRASI ANAK-ANAK ---
                    // Menggunakan aset gambar anak yang sama seperti background sebelumnya,
                    // Tapi di sini ditampilkan penuh & bulat agar jadi fokus utama!
                    Container(
                      width: 220,
                      height: 220,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: biruAwan, width: 4), // Border tebal
                        boxShadow: [
                          BoxShadow(
                            color: biruAwan.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo_anak.png', // Pastikan gambar ini ada
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Jika gambar gagal dimuat, tampilkan ikon mainan sebagai ganti
                            return Icon(Icons.toys_rounded, size: 100, color: pinkCeria);
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // --- TEKS SAMBUTAN ---
                    Text(
                      "Motorik Kids 🎈",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900, // Font gemuk
                        color: teksGelap, 
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Teman seru untuk memantau\ntumbuh kembang si Kecil! ✨",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: teksGelap.withOpacity(0.7),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    
                    const SizedBox(height: 40),

                    // --- TOMBOL PILIHAN PERAN (BUBBLY STYLE) ---
                    _buildRoleCard(
                      context,
                      title: "Guru 👩‍🏫",
                      subtitle: "Catat observasi & kelola siswa",
                      imagePath: "assets/guru.png", // Pastikan gambar ini ada
                      primaryColor: orenJeruk,
                      onTap: () => Get.toNamed(Routes.LOGIN, arguments: {'role': 'teacher'}),
                    ),

                    const SizedBox(height: 20),

                    _buildRoleCard(
                      context,
                      title: "Orang Tua 👨‍👩‍👧",
                      subtitle: "Lihat hasil belajar Anak",
                      imagePath: "assets/orang tua.png", // Pastikan gambar ini ada
                      primaryColor: biruAwan,
                      onTap: () => Get.toNamed(Routes.LOGIN, arguments: {'role': 'parent'}),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // --- FOOTER ---
                    Text(
                      "v1.0.0 • Universitas Harkat Negeri",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade400),
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

  // ============================================================
  // WIDGET KARTU PERAN (BUBBLY & KIDS FRIENDLY)
  // ============================================================
  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imagePath,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30), // Sangat melengkung
        border: Border.all(color: primaryColor.withOpacity(0.5), width: 3), // Garis tepi berwarna
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.15),
            offset: const Offset(0, 8),
            blurRadius: 15,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          splashColor: primaryColor.withOpacity(0.2), 
          highlightColor: primaryColor.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Avatar Lingkaran
                Container(
                  width: 65,
                  height: 65,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    imagePath, 
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.person, color: primaryColor),
                  ),
                ),
                const SizedBox(width: 20),
                
                // Teks Judul & Subjudul
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: teksGelap,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Panah Kanan Lucu
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 20,
                    color: Colors.white,
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