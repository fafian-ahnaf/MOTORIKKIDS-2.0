import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Pastikan import ini ada untuk format tanggal
import '../controllers/student_detail_controller.dart';

class StudentDetailView extends GetView<StudentDetailController> {
  const StudentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. TANGKAP DATA AWAL DARI ARGUMENTS
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String name = args['name'] ?? "Tanpa Nama";
    final String age = args['age'] ?? "-";
    final Color color = args['color'] ?? Colors.blue;

    // 2. CONFIG STATUS BAR (ICON HITAM)
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, 
      statusBarIconBrightness: Brightness.dark, // Icon Hitam
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Profil Siswa", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      
      body: SafeArea(
        child: Stack(
          children: [
            // --- LAYER 1: KONTEN SCROLLABLE ---
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 100), // Padding bawah besar agar tidak tertutup tombol
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. KARTU PROFIL UTAMA
                  _buildProfileCard(name, color),

                  const SizedBox(height: 24),
                  
                  // 2. STATISTIK KECIL (UMUR & STATUS)
                  Row(
                    children: [
                      Expanded(child: _buildDetailCard(Icons.cake_rounded, Colors.orange, "Umur", age)),
                      const SizedBox(width: 16),
                      Expanded(child: Obx(() => _buildDetailCard(Icons.verified_rounded, color, "Status Terkini", controller.currentStatus.value))),
                    ],
                  ),

                  const SizedBox(height: 30),
                  const Text("Analisa Perkembangan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 16),

                  // 3. KARTU GABUNGAN MOTORIK (MENAMPILKAN TOTAL POIN)
                  Obx(() => _buildCombinedMotorikCard(
                    fineAvg: controller.fineMotorScore.value,  // Untuk Progress Bar (0.0 - 1.0)
                    fineSum: controller.fineMotorSum.value,    // Untuk Text Total (e.g. 170)
                    grossAvg: controller.grossMotorScore.value,
                    grossSum: controller.grossMotorSum.value,
                  )),
                  
                  const SizedBox(height: 30),
                  
                  // 4. LIST RIWAYAT AKTIVITAS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Riwayat Aktivitas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Icon(Icons.history, color: Colors.grey.shade400),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // LIST DATA DARI FIREBASE
                  Obx(() {
                    if (controller.assessmentHistory.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            children: [
                              Icon(Icons.note_alt_outlined, size: 40, color: Colors.grey.shade300),
                              const SizedBox(height: 8),
                              Text("Belum ada data aktivitas.", style: TextStyle(color: Colors.grey.shade400)),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.assessmentHistory.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        var item = controller.assessmentHistory[index];
                        return _buildHistoryItem(item, context);
                      },
                    );
                  }),
                ],
              ),
            ),

            // --- LAYER 2: TOMBOL TAMBAH (STICKY BOTTOM) ---
            Positioned(
              left: 24, right: 24, bottom: 24,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: const Color(0xFFA5D6A7).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _showAssessmentDialog(context, isEdit: false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA5D6A7),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text("Input Perkembangan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  //      ✨ KARTU MOTORIK GABUNGAN (TOTAL POIN & PERSEN) ✨
  // ==========================================================
  Widget _buildCombinedMotorikCard({
    required double fineAvg, 
    required double fineSum, 
    required double grossAvg, 
    required double grossSum
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.analytics_rounded, color: Colors.blue.shade400, size: 24),
              ),
              const SizedBox(width: 16),
              const Text("Grafik Capaian", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 24),

          // 1. MOTORIK HALUS
          _buildSingleProgressRow(
            label: "Motorik Halus",
            percent: fineAvg,
            totalScore: fineSum, // Menampilkan Total Poin
            color: Colors.purple,
            icon: Icons.edit_rounded,
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
          ),

          // 2. MOTORIK KASAR
          _buildSingleProgressRow(
            label: "Motorik Kasar",
            percent: grossAvg,
            totalScore: grossSum, // Menampilkan Total Poin
            color: Colors.orange,
            icon: Icons.directions_run_rounded,
          ),
        ],
      ),
    );
  }

  // Widget Helper Baris Progress
  Widget _buildSingleProgressRow({
    required String label, 
    required double percent, 
    required double totalScore, 
    required Color color, 
    required IconData icon
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Label Kiri
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
              ],
            ),
            // Nilai Kanan (Total Poin + Persen)
            Row(
              children: [
                Text(
                  "${totalScore.toInt()} Poin", // Hasil Penjumlahan
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)
                ),
                const SizedBox(width: 4),
                Text(
                  "(${(percent * 100).toInt()}%)", // Rata-rata
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400)
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percent, // Menggunakan rata-rata agar bar proporsional (0.0 - 1.0)
            minHeight: 10,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  //      ✨ DIALOG INPUT & EDIT (DENGAN SLIDER) ✨
  // ==========================================================
  void _showAssessmentDialog(BuildContext context, {required bool isEdit, Map<String, dynamic>? oldData}) {
    // Set Data jika Edit
    if (isEdit && oldData != null) {
      controller.activityNameC.text = oldData['activity'];
      controller.notesC.text = oldData['notes'];
      controller.inputScore.value = (oldData['score'] ?? 75.0).toDouble();
      controller.selectedMotorikType.value = oldData['type'];
    } else {
      // Reset Data jika Baru
      controller.activityNameC.clear();
      controller.notesC.clear();
      controller.inputScore.value = 75.0;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Dialog
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: isEdit ? Colors.orange.shade50 : Colors.green.shade50, shape: BoxShape.circle),
                      child: Icon(isEdit ? Icons.edit : Icons.edit_note_rounded, color: isEdit ? Colors.orange : Colors.green.shade400),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(isEdit ? "Edit Data" : "Input Data Motorik", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(onPressed: () => Get.back(), icon: Icon(Icons.close, color: Colors.grey.shade400))
                  ],
                ),
                const SizedBox(height: 20),

                // 1. Jenis Motorik
                const Text("Jenis Motorik", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                Obx(() => Row(
                  children: [
                    Expanded(child: _buildSelectableChip("Halus", controller.selectedMotorikType.value == "Halus", Colors.purple)), 
                    const SizedBox(width: 8),
                    Expanded(child: _buildSelectableChip("Kasar", controller.selectedMotorikType.value == "Kasar", Colors.orange)),
                  ],
                )),
                const SizedBox(height: 16),
                
                // 2. Form Input
                const Text("Nama Kegiatan", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.activityNameC,
                  decoration: InputDecoration(
                    hintText: "Misal: Meronce manik-manik",
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. SLIDER NILAI (GABUNG SCORE + LABEL)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Penilaian:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        "${controller.inputScore.value.toInt()} - ${controller.getScoreLabel(controller.inputScore.value)}",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 13),
                      ),
                    )),
                  ],
                ),
                Obx(() => Slider(
                  value: controller.inputScore.value,
                  min: 0, max: 100, divisions: 20,
                  activeColor: Colors.blueAccent, inactiveColor: Colors.blue.shade100,
                  onChanged: (val) => controller.inputScore.value = val,
                )),
                const SizedBox(height: 10),

                // 4. Catatan
                const Text("Catatan Observasi", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.notesC,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: "Catatan tambahan...",
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 24),

                // 5. Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : () {
                      if (isEdit && oldData != null) {
                        controller.updateAssessment(oldData);
                      } else {
                        controller.addAssessment();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEdit ? Colors.orange : Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: controller.isLoading.value 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(isEdit ? "Update Data" : "Simpan Data", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ==========================================================
  //      ✨ LIST RIWAYAT (DENGAN EDIT) ✨
  // ==========================================================
  Widget _buildHistoryItem(Map<String, dynamic> item, BuildContext context) {
    bool isHalus = item['type'] == 'Halus';
    Color typeColor = isHalus ? Colors.purple : Colors.orange;
    double score = (item['score'] ?? 0).toDouble();

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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: typeColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(isHalus ? Icons.edit_rounded : Icons.directions_run_rounded, color: typeColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['activity'] ?? "-", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  "${controller.formatDate(item['date'])} • ${item['notes'] ?? ''}",
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  maxLines: 1, overflow: TextOverflow.ellipsis
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${score.toInt()}", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blue.shade700, fontSize: 16)),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => _showAssessmentDialog(context, isEdit: true, oldData: item),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                  child: Row(children: [Icon(Icons.edit, size: 10, color: Colors.grey.shade600), const SizedBox(width: 4), Text("Edit", style: TextStyle(fontSize: 10, color: Colors.grey.shade600))]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- HELPER LAINNYA ---
  Widget _buildSelectableChip(String label, bool isSelected, Color color) {
    return GestureDetector(
      onTap: () => controller.selectedMotorikType.value = label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.transparent),
        ),
        child: Center(child: Text(label, style: TextStyle(color: isSelected ? color : Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 12))),
      ),
    );
  }

  Widget _buildProfileCard(String name, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.blueGrey.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Row(children: [Container(width: 80, height: 80, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : "?", style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: color)))), const SizedBox(width: 20), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 8), Obx(() => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.2))), child: Text(controller.currentStatus.value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color))))]))]),
    );
  }

  Widget _buildDetailCard(IconData icon, Color color, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color, size: 24), const SizedBox(height: 8), Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)), Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1)]),
    );
  }
}