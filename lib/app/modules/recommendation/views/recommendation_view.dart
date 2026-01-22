import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/recommendation_controller.dart';

class RecommendationView extends GetView<RecommendationController> {
  const RecommendationView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller dengan tag agar aman (opsional, tapi Get.put biasa sudah cukup jika routing benar)
    if (!Get.isRegistered<RecommendationController>()) {
      Get.put(RecommendationController());
    }

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text("Rekomendasi Aktivitas", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
        
        // --- TAMBAHAN: TOMBOL REFRESH ---
        
      ),
      
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(color: Color(0xFFA5D6A7)),
                SizedBox(height: 16),
                Text("Sedang mencari ide baru...", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
              ],
            ),
          );
        }

        var data = controller.recommendationData;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // 1. HEADER KARTU
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                      child: Icon(Icons.auto_awesome, size: 40, color: Colors.blue.shade400),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      data['title'] ?? "Aktivitas",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['desc'] ?? "-",
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. DETAIL INFORMASI
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.flag_rounded, Colors.red, "Tujuan", data['tujuan'] ?? "-"),
                    const Divider(height: 32, thickness: 1, color: Color(0xFFF5F5F5)),
                    _buildInfoRow(Icons.lightbulb_rounded, Colors.orange, "Cara Pelaksanaan", data['cara'] ?? "-"),
                    const Divider(height: 32, thickness: 1, color: Color(0xFFF5F5F5)),
                    Row(
                      children: [
                        Expanded(child: _buildInfoRow(Icons.timer_rounded, Colors.purple, "Durasi", data['durasi'] ?? "-")),
                        const SizedBox(width: 16),
                        Expanded(child: _buildInfoRow(Icons.place_rounded, Colors.green, "Lokasi", data['lokasi'] ?? "-")),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 3. TOMBOL AKSI
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => controller.markAsDone(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA5D6A7),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text("Tandai Selesai", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(IconData icon, Color color, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }
}