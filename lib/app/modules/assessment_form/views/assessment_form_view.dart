import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/assessment_form_controller.dart';

class AssessmentFormView extends GetView<AssessmentFormController> {
  const AssessmentFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          'Form Observasi Motorik',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================================================
            // 1. REVISI KETUA PENGUJI: PILIH KOMPONEN MOTORIK
            // =========================================================
            const Text(
              "1. Komponen Motorik yang Dinilai",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            
            Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButton<String>(
                value: controller.selectedKomponen.value,
                isExpanded: true,
                underline: const SizedBox(),
                items: controller.daftarKomponen.map((item) {
                  return DropdownMenuItem<String>(
                    value: item["komponen"],
                    child: Text(
                      item["komponen"]!,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: controller.updateKomponen,
              ),
            )),

            const SizedBox(height: 12),

            // BADGE KATEGORI OTOMATIS (MOTORIK KASAR / HALUS)
            Obx(() {
              final bool isKasar = controller.selectedKategori.value.contains("Kasar");
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isKasar ? Colors.orange.shade100 : Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isKasar ? Icons.directions_run_rounded : Icons.edit_rounded,
                      size: 16,
                      color: isKasar ? Colors.orange.shade900 : Colors.purple.shade900,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Kategori: ${controller.selectedKategori.value}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isKasar ? Colors.orange.shade900 : Colors.purple.shade900,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // =========================================================
            // 2. REVISI KETUA PENGUJI: INPUT USIA ANAK
            // =========================================================
            const Text(
              "2. Usia Anak (Bulan)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Obx(() => Text(
                    "${controller.selectedUsiaBulan.value} Bulan (${(controller.selectedUsiaBulan.value / 12).toStringAsFixed(1)} Tahun)",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32)),
                  )),
                  Obx(() => Slider(
                    value: controller.selectedUsiaBulan.value.toDouble(),
                    min: 12,
                    max: 72,
                    divisions: 60,
                    activeColor: const Color(0xFFA5D6A7),
                    label: "${controller.selectedUsiaBulan.value} Bulan",
                    onChanged: (val) => controller.selectedUsiaBulan.value = val.toInt(),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =========================================================
            // 3. CATATAN OBSERVASI GURU
            // =========================================================
            const Text(
              "3. Catatan Observasi Guru",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: controller.teksObservasi, 
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Contoh: Anak sudah mampu melompat dengan kedua kaki secara stabil tanpa jatuh...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFA5D6A7), width: 2),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // =========================================================
            // 4. TOMBOL ANALISIS INDOBERT
            // =========================================================
            SizedBox(
              width: double.infinity,
              height: 55,
              child: Obx(() => ElevatedButton.icon(
                onPressed: controller.isLoading.value ? null : () => controller.analisisData(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA5D6A7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                icon: controller.isLoading.value 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.psychology_alt_rounded, color: Colors.white),
                label: Text(
                  controller.isLoading.value ? "Menganalisis..." : "Analisis dengan IndoBERT",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}