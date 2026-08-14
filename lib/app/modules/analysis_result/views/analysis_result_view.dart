import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/analysis_result_controller.dart';

class AnalysisResultView extends GetView<AnalysisResultController> {
  const AnalysisResultView({super.key});

  // Helper untuk menampilkan kepanjangan status SDIDTK agar lebih informatif
  String _getStatusDescription(String kode) {
    switch (kode) {
      case "BB":
        return "Belum Berkembang";
      case "MB":
        return "Mulai Berkembang";
      case "BSH":
        return "Berkembang Sesuai Harapan";
      case "BSB":
        return "Berkembang Sangat Baik";
      default:
        return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          "Hasil Analisa AI", 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Color(0xFFA5D6A7)),
                const SizedBox(height: 20),
                Text(
                  "Model IndoBERT sedang menganalisa...", 
                  style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMainStatusCard(),
              
              const SizedBox(height: 30),
              const Text(
                "Rekomendasi Aktivitas", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _buildRecommendationDetail(),

              const SizedBox(height: 40),

              // ========================================================
              // REVISI UX: TOMBOL SIMPAN & SELESAI (AUTO-CLOSE)
              // ========================================================
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => controller.saveAndFinish(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA5D6A7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Simpan ke Riwayat & Selesai", 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMainStatusCard() {
    final bool isKasar = controller.kategoriMotorik.value.toUpperCase().contains("KASAR");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), 
            blurRadius: 20, 
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          // --- REVISI KETUA PENGUJI: TAMPILKAN KATEGORI & USIA ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isKasar ? Colors.orange.shade50 : Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isKasar ? "Motorik Kasar" : "Motorik Halus",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isKasar ? Colors.orange.shade800 : Colors.purple.shade800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Usia: ${controller.usiaBulan.value} Bulan",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Status Perkembangan", 
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: controller.statusColor.value.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: controller.statusColor.value.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  controller.status.value,
                  style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.w900, 
                    color: controller.statusColor.value,
                  ),
                ),
                const SizedBox(height: 4),
                // Keterangan lengkap status
                Text(
                  _getStatusDescription(controller.status.value),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: controller.statusColor.value,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          Text(
            "Tingkat Keyakinan AI: ${(controller.tingkatKeyakinan.value * 100).toStringAsFixed(1)}%",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const Divider(height: 40),
          Text(
            "\"${controller.inputTeks.value}\"",
            textAlign: TextAlign.center,
            style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationDetail() {
    var data = controller.recommendationData;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.orange),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  data['title'] ?? "-", 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.flag_outlined, "Tujuan", data['goal'] ?? "-"),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.task_alt, "Metode", data['method'] ?? "-"),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.timer_outlined, "Durasi", data['duration'] ?? "-"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label, 
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                value, 
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}