import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/recommendation_controller.dart';

class RecommendationView extends GetView<RecommendationController> {
  const RecommendationView({super.key});

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
          Container(color: bgBase),
          
          Positioned(
            top: -100, right: -50,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: biruAwan.withOpacity(0.15)),
            ),
          ),
          
          _buildBalloonBackgroundPattern(),

          SafeArea(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: orenJeruk, strokeWidth: 6),
                      const SizedBox(height: 24),
                      Text("Sedang memuat data... 🎈", 
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
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 120), 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderCard(data),

                        const SizedBox(height: 30),
                        Text("Panduan Stimulasi 🎨", 
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: teksGelap)),
                        const SizedBox(height: 16),

                        _buildInfoCard(
                          icon: Icons.rocket_launch_rounded, 
                          color: orenJeruk,
                          title: "Tujuan Bermain 🎯",
                          content: data['tujuan'] ?? "-",
                        ),
                        const SizedBox(height: 16),

                        _buildInfoCard(
                          icon: Icons.toys_rounded, 
                          color: pinkCeria,
                          title: "Cara Bermainnya 🧩",
                          content: data['cara'] ?? "-",
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _buildSmallDetailCard(
                                icon: Icons.hourglass_bottom_rounded, 
                                color: Colors.purple.shade400,
                                label: "Waktu Main ⏳",
                                value: data['durasi'] ?? "-",
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSmallDetailCard(
                                icon: Icons.castle_rounded, 
                                color: Colors.green.shade400,
                                label: "Lokasi 🏰",
                                value: data['lokasi'] ?? "-",
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                        
                        // ============================================================
                        // --- WIDGET KHUSUS ORANG TUA: CHECKLIST & FEEDBACK ---
                        // ============================================================
                        if (controller.role == 'parent')
                          Obx(() {
                            if (controller.isDoneByParent.value) {
                              // TAMPILAN JIKA SUDAH SELESAI
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.green.shade300, width: 2),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 28),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text("Aktivitas Selesai! 🎉", style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w900, fontSize: 18))),
                                      ],
                                    ),
                                    if (controller.parentFeedbackText.value.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      const Divider(color: Colors.green),
                                      const SizedBox(height: 8),
                                      Text("Catatan Bunda/Ayah:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.green.shade800)),
                                      const SizedBox(height: 4),
                                      Text('"${controller.parentFeedbackText.value}"', style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.green.shade900)),
                                    ]
                                  ],
                                ),
                              );
                            } else {
                              // TAMPILAN JIKA BELUM SELESAI
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: orenJeruk.withOpacity(0.5), width: 2),
                                  boxShadow: [BoxShadow(color: orenJeruk.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Sudah Bermain Bersama? 🌟", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: teksGelap)),
                                    const SizedBox(height: 8),
                                    Text("Tuliskan respon atau kendala ananda saat melakukan aktivitas ini (Opsional):", style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600, height: 1.5)),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: controller.feedbackC,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        hintText: "Contoh: Ananda sangat senang dan bisa melompat dengan baik...",
                                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                                        filled: true,
                                        fillColor: bgBase,
                                        contentPadding: const EdgeInsets.all(16),
                                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.transparent)),
                                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: orenJeruk, width: 2)),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton.icon(
                                        onPressed: () => controller.submitParentFeedback(),
                                        icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                                        label: const Text("Tandai Selesai!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green.shade400,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          elevation: 0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }),
                        // ============================================================
                      ],
                    ),
                  ),

                  // --- TOMBOL SIMPAN MELAYANG (KHUSUS GURU) ---
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
                                Icon(Icons.favorite_rounded, color: Colors.white, size: 28), 
                                SizedBox(width: 12),
                                Text("Simpan & Kirim ke Ortu", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
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
            child: Icon(Icons.child_care_rounded, color: biruAwan, size: 45), 
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
                child: Icon(icon, color: color, size: 24), 
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
          Icon(icon, color: color, size: 28), 
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
              child: Icon(Icons.sentiment_satisfied_alt_rounded, size: 60, color: Colors.grey.shade400), 
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