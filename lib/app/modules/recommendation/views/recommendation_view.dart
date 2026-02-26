import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/recommendation_controller.dart';

class RecommendationView extends GetView<RecommendationController> {
  const RecommendationView({super.key});

  // --- PALET WARNA CERIA ---
  final Color bgBase = const Color(0xFFFFF8E7); 
  final Color pinkCeria = const Color(0xFFFF7E95); 
  final Color biruAwan = const Color(0xFF4FC3F7); 
  final Color orenJeruk = const Color(0xFFFFB74D);
  final Color teksGelap = const Color(0xFF4A4A4A);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: bgBase,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Saran Bermain 🎈", 
          style: TextStyle(color: teksGelap, fontWeight: FontWeight.w900, fontSize: 20)
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white, 
              shape: BoxShape.circle, 
              border: Border.all(color: biruAwan, width: 2),
              boxShadow: [BoxShadow(color: biruAwan.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.black87),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      
      body: Stack(
        children: [
          // ============================================================
          // --- BACKGROUND BARU: POLA BALON & AWAN ---
          // ============================================================
          Container(color: bgBase),
          
          Positioned(
            top: -100, right: -50,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: biruAwan.withOpacity(0.15)),
            ),
          ),
          
          _buildBalloonBackgroundPattern(),

          // ============================================================
          // --- KONTEN UTAMA ---
          // ============================================================
          SafeArea(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: orenJeruk, strokeWidth: 6),
                      const SizedBox(height: 24),
                      Text("Sedang meracik ide\nbermain yang seru... 🎈", 
                        textAlign: TextAlign.center,
                        style: TextStyle(color: teksGelap, fontWeight: FontWeight.w900, fontSize: 16)
                      ),
                    ],
                  ),
                );
              }

              final data = controller.recommendationData;

              if (data.isEmpty || data['title'] == "Belum Ada Saran Bermain 🍃" || data['title'] == "Belum Ada Rekomendasi") {
                return _buildEmptyState();
              }

              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 120), // Padding bawah diperbesar untuk tombol
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderCard(data),

                        const SizedBox(height: 30),
                        Text("Panduan Stimulasi 🎨", 
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: teksGelap)),
                        const SizedBox(height: 16),

                        // KARTU INFO (TUJUAN & CARA) - IKON ANAK-ANAK
                        _buildInfoCard(
                          icon: Icons.rocket_launch_rounded, // Roket untuk tujuan
                          color: orenJeruk,
                          title: "Tujuan Bermain 🎯",
                          content: data['tujuan'] ?? "-",
                        ),
                        const SizedBox(height: 16),

                        _buildInfoCard(
                          icon: Icons.toys_rounded, // Mainan untuk cara bermain
                          color: pinkCeria,
                          title: "Cara Bermainnya 🧩",
                          content: data['cara'] ?? "-",
                        ),
                        const SizedBox(height: 16),

                        // ROW INFO DURASI & LOKASI
                        Row(
                          children: [
                            Expanded(
                              child: _buildSmallDetailCard(
                                icon: Icons.hourglass_bottom_rounded, // Jam Pasir
                                color: Colors.purple.shade400,
                                label: "Waktu Main ⏳",
                                value: data['durasi'] ?? "-",
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSmallDetailCard(
                                icon: Icons.castle_rounded, // Kastil / Istana Mainan
                                color: Colors.green.shade400,
                                label: "Lokasi 🏰",
                                value: data['lokasi'] ?? "-",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // --- TOMBOL SIMPAN MELAYANG ---
                  if (controller.role != 'parent')
                    Positioned(
                      left: 24, right: 24, bottom: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 65,
                          child: ElevatedButton(
                            onPressed: () => controller.markAsDone(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade400,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.favorite_rounded, color: Colors.white, size: 28), // Hati untuk menyimpan
                                SizedBox(width: 12),
                                Text("Simpan ke Jurnal!", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // WIDGET BARU UNTUK BACKGROUND BALON
  // ==============================================================
  Widget _buildBalloonBackgroundPattern() {
    return Stack(
      children: [
        Positioned(top: 80, left: 40, child: Icon(Icons.circle, color: pinkCeria.withOpacity(0.15), size: 40)),
        Positioned(top: 150, right: 30, child: Icon(Icons.circle, color: biruAwan.withOpacity(0.2), size: 60)),
        Positioned(top: 280, left: -10, child: Icon(Icons.circle, color: orenJeruk.withOpacity(0.15), size: 80)),
        Positioned(top: 400, right: 50, child: Icon(Icons.circle, color: pinkCeria.withOpacity(0.1), size: 50)),
        Positioned(bottom: 180, left: 70, child: Icon(Icons.circle, color: biruAwan.withOpacity(0.15), size: 70)),
        Positioned(bottom: 50, right: -20, child: Icon(Icons.circle, color: orenJeruk.withOpacity(0.2), size: 90)),
        Positioned(bottom: 300, right: 100, child: Icon(Icons.circle, color: pinkCeria.withOpacity(0.1), size: 30)),
        Positioned(top: 150, right: 50, child: Icon(Icons.cloud_rounded, color: Colors.white.withOpacity(0.6), size: 80)),
        Positioned(bottom: 250, left: 60, child: Icon(Icons.cloud_rounded, color: Colors.white.withOpacity(0.5), size: 60)),
      ],
    );
  }

  // ==============================================================
  // WIDGET KOMPONEN
  // ==============================================================

  Widget _buildHeaderCard(Map<String, String> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: biruAwan, width: 3),
        boxShadow: [BoxShadow(color: biruAwan.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: biruAwan.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(Icons.child_care_rounded, color: biruAwan, size: 45), // Ikon Wajah Anak
          ),
          const SizedBox(height: 16),
          Text(data['title'] ?? "-", 
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: teksGelap)),
          const SizedBox(height: 12),
          Text(data['desc'] ?? "-", 
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade600, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required Color color, required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 24), // Ukuran ikon sedikit diperbesar
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color))),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: teksGelap, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildSmallDetailCard({required IconData icon, required Color color, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28), // Ukuran ikon sedikit diperbesar
          const SizedBox(height: 12),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: teksGelap.withOpacity(0.6))),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: teksGelap)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 15)]
              ),
              child: Icon(Icons.sentiment_satisfied_alt_rounded, size: 60, color: Colors.grey.shade400), // Wajah tersenyum
            ),
            const SizedBox(height: 20),
            Text("Belum Ada Saran 🌱", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: teksGelap)),
            const SizedBox(height: 12),
            Text("Sepertinya guru belum mengirimkan saran aktivitas bermain untuk Ananda saat ini.", 
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, height: 1.5)),
          ],
        ),
      ),
    );
  }
}