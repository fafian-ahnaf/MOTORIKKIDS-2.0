import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/analysis_result_controller.dart';

class AnalysisResultView extends StatelessWidget {
  const AnalysisResultView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi Controller
    final controller = Get.put(AnalysisResultController());

    // Mengatur warna status bar agar ikon terlihat jelas
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Background putih abu-abu muda
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text("Hasil Analisa", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- CARD UTAMA HASIL ANALISA ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bagian 1: Ringkasan Otomatis
                  const Text("Ringkasan Otomatis", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                    controller.nlpSummary.value,
                    style: TextStyle(color: Colors.grey.shade600, height: 1.5, fontSize: 14),
                  )),
                  
                  const SizedBox(height: 24),
                  
                  // Bagian 2: Klasifikasi
                  const Text("Klasifikasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildScoreRow("Motorik Kasar", "${controller.scoreKasar.value}%"),
                      const SizedBox(height: 6),
                      _buildScoreRow("Motorik Halus", "${controller.scoreHalus.value}%"),
                    ],
                  )),

                  const SizedBox(height: 24),

                  // Bagian 3: Status
                  const Text("Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Obx(() => Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: controller.statusColor.value, // Warna dinamis dari controller
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        controller.status.value,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  )),
                ],
              ),
            ),
            
            const Spacer(),

            // --- TOMBOL AKSI DI BAWAH ---
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.saveAndFinish(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA5D6A7), // Hijau Soft (sesuai tema umum)
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text("Simpan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.goToRecommendation(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA5D6A7), 
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text("Lihat Rekomendasi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Baris Skor
  Widget _buildScoreRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}