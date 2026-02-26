import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/recommendation_controller.dart';

class RecommendationView extends GetView<RecommendationController> {
  const RecommendationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Saran Aktivitas", 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFA5D6A7)),
          );
        }

        final data = controller.recommendationData;

        
        if (data.isEmpty || data['title'] == "Belum Ada Rekomendasi") {
          return _buildEmptyState();
        }

        
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  _buildHeaderCard(data),

                  const SizedBox(height: 24),
                  const Text("Detail Panduan", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 16),

                  
                  _buildDetailCard(data),
                ],
              ),
            ),

            
            if (controller.role != 'parent')
              Positioned(
                left: 24, right: 24, bottom: 24,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => controller.markAsDone(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA5D6A7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      shadowColor: const Color(0xFFA5D6A7).withOpacity(0.4),
                    ),
                    child: const Text("Simpan ke Riwayat Siswa", 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  
  Widget _buildHeaderCard(Map<String, String> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
            child: const Icon(Icons.lightbulb_rounded, color: Colors.orange, size: 30),
          ),
          const SizedBox(height: 16),
          Text(data['title'] ?? "-", 
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87)),
          const SizedBox(height: 8),
          Text(data['desc'] ?? "-", 
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5)),
        ],
      ),
    );
  }

  
  Widget _buildDetailCard(Map<String, String> data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.track_changes_rounded, Colors.blue, "Tujuan Aktivitas", data['tujuan'] ?? "-"),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
          _buildInfoRow(Icons.ads_click_rounded, Colors.purple, "Cara Melakukan", data['cara'] ?? "-"),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
          _buildInfoRow(Icons.access_time_filled_rounded, Colors.green, "Durasi Rekomendasi", data['durasi'] ?? "-"),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
          _buildInfoRow(Icons.location_on_rounded, Colors.redAccent, "Lokasi Ideal", data['lokasi'] ?? "-"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, Color color, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_late_rounded, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            const Text("Belum Ada Saran", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 8),
            const Text("Guru belum mengirimkan saran aktivitas motorik untuk periode ini.", 
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}