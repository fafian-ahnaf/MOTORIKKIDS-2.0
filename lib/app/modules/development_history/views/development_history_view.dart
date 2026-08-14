import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/development_history_controller.dart';

class DevelopmentHistoryView extends GetView<DevelopmentHistoryController> {
  const DevelopmentHistoryView({super.key});

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
      backgroundColor: bgBase,
      appBar: AppBar(
        title: Text(
          "Riwayat & Laporan 📊",
          style: TextStyle(color: teksGelap, fontWeight: FontWeight.w900, fontSize: 20),
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
              border: Border.all(color: pinkCeria, width: 2),
              boxShadow: [
                BoxShadow(color: pinkCeria.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.black87),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            _buildBackgroundPattern(),
            Column(
              children: [
                _buildStudentHeaderCard(),
                const SizedBox(height: 12),
                Expanded(
                  child: Obx(() {
                    if (controller.assessmentHistory.isEmpty) {
                      return _buildEmptyState();
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
                      itemCount: controller.assessmentHistory.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        var item = controller.assessmentHistory[index];
                        return _buildHistoryCard(item);
                      },
                    );
                  }),
                ),
              ],
            ),

            // Tombol Cetak PDF di Bawah Layar
            Positioned(
              left: 24,
              right: 24,
              bottom: 20,
              child: _buildPrintPdfButton(),
            ),
          ],
        ),
      ),
    );
  }

  // --- KARTU RINGKASAN PROFIL SISWA ---
  Widget _buildStudentHeaderCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: biruAwan.withOpacity(0.4), width: 3),
        boxShadow: [
          BoxShadow(color: biruAwan.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: biruAwan.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Obx(() {
                String name = controller.studentName.value;
                String initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : "A";
                return Text(
                  initial,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: biruAwan),
                );
              }),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                      controller.studentName.value,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: teksGelap),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                const SizedBox(height: 6),
                Obx(() => Text(
                      "Usia: ${controller.studentAge.value} • ${controller.assessmentHistory.length} Observasi",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                const SizedBox(height: 8),
                Obx(() {
                  String status = controller.currentStatus.value;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // KARTU RIWAYAT OBSERVASI (BISA DIKLIK -> MUNCUL POPUP DETAIL)
  // ===========================================================================
  Widget _buildHistoryCard(Map<String, dynamic> item) {
    String typeStr = (item['type'] ?? '').toString().toLowerCase();
    bool isHalus = typeStr.contains('halus');
    Color typeColor = isHalus ? Colors.purple.shade400 : orenJeruk;

    String activity = item['activity'] ?? "-";
    String notes = item['notes'] ?? "-";
    String status = item['status'] ?? "Berkembang Sesuai Harapan (BSH)";

    String rawTeacher = (item['teacher_name'] ?? "").toString().trim();
    String teacherName = (rawTeacher.isEmpty || rawTeacher == "Guru Kelas")
        ? controller.currentTeacherName.value
        : rawTeacher;

    double score = (item['score'] ?? 0).toDouble();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showDetailObservationDialog(item), // <-- AKSI KLIK LIHAT DETAIL
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: typeColor.withOpacity(0.3), width: 2.5),
            boxShadow: [
              BoxShadow(color: typeColor.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BARIS TANGGAL & STATUS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      controller.formatDate(item['date'] ?? ""),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: typeColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          status,
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // BARIS IKON, KEGIATAN & INDIKATOR KLIK
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isHalus ? Icons.edit_rounded : Icons.directions_run_rounded,
                      color: typeColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      activity,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: teksGelap),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Petunjuk kecil Lihat Detail
                  Row(
                    children: [
                      Text("Lihat Detail", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: typeColor)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, size: 12, color: typeColor),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // NARASI CATATAN (DIBATASI 2 BARIS AGAR RAPI DI LIST)
              Text(
                '"$notes"',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4, fontStyle: FontStyle.italic),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Divider(height: 24),

              // BARIS NAMA PENGAMAT & SKOR BINTANG
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.person_pin_rounded, size: 16, color: Colors.grey.shade500),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Pengamat: $teacherName",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${score.toInt()} ⭐",
                      style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // POPUP MODAL DIALOG DETAIL OBSERVASI LENGKAP
  // ===========================================================================
  void _showDetailObservationDialog(Map<String, dynamic> item) {
    String activity = item['activity'] ?? "-";
    String notes = item['notes'] ?? "-";
    String status = item['status'] ?? "Berkembang Sesuai Harapan (BSH)";
    double score = (item['score'] ?? 0).toDouble();

    String rawTeacher = (item['teacher_name'] ?? "").toString().trim();
    String teacherName = (rawTeacher.isEmpty || rawTeacher == "Guru Kelas")
        ? controller.currentTeacherName.value
        : rawTeacher;

    String typeStr = (item['type'] ?? '').toString().toLowerCase();
    bool isHalus = typeStr.contains('halus');
    Color typeColor = isHalus ? Colors.purple.shade400 : orenJeruk;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: typeColor, width: 3),
            boxShadow: [
              BoxShadow(color: typeColor.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))
            ],
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: typeColor.withOpacity(0.15), shape: BoxShape.circle),
                      child: Icon(
                        isHalus ? Icons.edit_rounded : Icons.directions_run_rounded,
                        color: typeColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Detail Observasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: teksGelap)),
                          Text(
                            controller.formatDate(item['date'] ?? ""),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: typeColor, borderRadius: BorderRadius.circular(12)),
                      child: Text("${score.toInt()} ⭐", style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Badge Status
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),

                // Judul Aktivitas
                Text("Kegiatan Stimulasi:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(activity, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: teksGelap)),
                const SizedBox(height: 14),

                // Catatan Anekdot Lengkap
                Text("Catatan Anekdot Guru:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: bgBase, borderRadius: BorderRadius.circular(16)),
                  child: Text(
                    '"$notes"',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: teksGelap,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Pengamat
                Row(
                  children: [
                    Icon(Icons.person_pin_rounded, size: 18, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text("Pengamat: $teacherName", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey.shade700)),
                  ],
                ),
                const Divider(height: 28),

                // Tips Stimulasi
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isHalus ? Colors.purple.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isHalus ? Colors.purple.shade200 : Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHalus ? "💡 Tips Stimulasi Motorik Halus:" : "💡 Tips Stimulasi Motorik Kasar:",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: isHalus ? Colors.purple.shade900 : Colors.orange.shade900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isHalus
                            ? "Melibatkan ketelitian otot jari dan tangan. Dampingi anak bermain menggambar, menyusun balok, atau melipat kertas di rumah."
                            : "Melibatkan gerakan otot besar tubuh. Ajak anak aktif bergerak, berlari, atau bermain bola di luar ruangan agar keseimbangannya makin optimal.",
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isHalus ? Colors.purple.shade900 : Colors.orange.shade900,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Tutup
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: typeColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text("Tutup Detail", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- TOMBOL CETAK LAPORAN PDF ---
  Widget _buildPrintPdfButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: pinkCeria.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : () => controller.cetakLaporanPDF(),
              style: ElevatedButton.styleFrom(
                backgroundColor: pinkCeria,
                disabledBackgroundColor: Colors.grey.shade300,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.print_rounded, color: Colors.white, size: 24),
                        SizedBox(width: 10),
                        Text(
                          "Cetak Laporan Resmi (PDF)",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
            )),
      ),
    );
  }

  // --- EMPTY STATE ---
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 15),
                ],
              ),
              child: Icon(Icons.history_toggle_off_rounded, size: 50, color: Colors.grey.shade300),
            ),
            const SizedBox(height: 16),
            Text(
              "Belum Ada Riwayat Observasi",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: teksGelap),
            ),
            const SizedBox(height: 6),
            Text(
              "Catatan observasi harian Ananda akan muncul di halaman ini.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  // --- BACKGROUND PATTERN ---
  Widget _buildBackgroundPattern() {
    return Stack(
      children: [
        Positioned(top: 20, right: -30, child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: pinkCeria.withOpacity(0.1)))),
        Positioned(bottom: 100, left: -40, child: Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, color: biruAwan.withOpacity(0.12)))),
      ],
    );
  }

  // --- WARNA STATUS CAPAIAN ---
  Color _getStatusColor(String status) {
    String s = status.toUpperCase();
    if (s.contains("BSB") || s.contains("SANGAT") || s.contains("BAIK")) {
      return Colors.green.shade500;
    }
    if (s.contains("BSH") || s.contains("HARAPAN") || s.contains("SESUAI")) {
      return biruAwan;
    }
    if (s.contains("MB") || s.contains("MULAI")) {
      return orenJeruk;
    }
    if (s.contains("BB") || s.contains("BELUM")) {
      return Colors.red.shade400;
    }
    return biruAwan;
  }
}