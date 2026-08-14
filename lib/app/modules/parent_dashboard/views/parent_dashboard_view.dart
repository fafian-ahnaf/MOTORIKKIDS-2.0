import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../routes/app_pages.dart';
import '../controllers/parent_dashboard_controller.dart';

class ParentDashboardView extends GetView<ParentDashboardController> {
  const ParentDashboardView({Key? key}) : super(key: key);

  final Color bgBase = const Color(0xFFFFF8E7); 
  final Color pinkCeria = const Color(0xFFFF7E95); 
  final Color biruAwan = const Color(0xFF4FC3F7); 
  final Color orenJeruk = const Color(0xFFFFB74D);
  final Color teksGelap = const Color(0xFF4A4A4A);

  // Penguji status pintar kebal teks panjang & berbagai variasi
  Map<String, dynamic> _getStatusDetail(String rawKode, [double score = 0]) {
    String kode = rawKode.toUpperCase().trim();

    if (kode.isEmpty || kode == "-" || kode.contains("BELUM DINILAI")) {
      if (score >= 76) {
        kode = "BSB";
      } else if (score >= 51) {
        kode = "BSH";
      } else if (score >= 26) {
        kode = "MB";
      } else if (score > 0) {
        kode = "BB";
      }
    }

    if (kode.contains("BSB") || kode.contains("SANGAT") || kode.contains("BAIK")) {
      return {"label": "Berkembang Sangat Baik (BSB)", "color": Colors.green.shade500};
    } else if (kode.contains("BSH") || kode.contains("HARAPAN") || kode.contains("SESUAI")) {
      return {"label": "Berkembang Sesuai Harapan (BSH)", "color": Colors.blue.shade400};
    } else if (kode.contains("MB") || kode.contains("MULAI")) {
      return {"label": "Mulai Berkembang (MB)", "color": const Color(0xFFEEDB00)};
    } else if (kode.contains("BB") || kode.contains("BELUM")) {
      return {"label": "Belum Berkembang (BB)", "color": Colors.red.shade400};
    }

    return {"label": "Berkembang Sesuai Harapan (BSH)", "color": Colors.blue.shade400};
  }

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
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(top: -100, right: -50, child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: biruAwan.withOpacity(0.15)))),
            Positioned(top: 150, left: -50, child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: pinkCeria.withOpacity(0.1)))),
            
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return RefreshIndicator(
                onRefresh: () async => controller.loadDashboardData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 30),

                      if (controller.studentData.isEmpty)
                        _buildEmptyStudentState()
                      else ...[
                        _buildChildHeroCard(),
                        const SizedBox(height: 30),
                        
                        Text("Menu Cepat 🚀", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: teksGelap)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMenuButton(
                                icon: Icons.auto_graph_rounded,
                                color: biruAwan,
                                title: "Riwayat &\nTren",
                                onTap: () => Get.toNamed(Routes.DEVELOPMENT_HISTORY, arguments: {'studentId': controller.studentId.value}),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildMenuButton(
                                icon: Icons.lightbulb_rounded,
                                color: orenJeruk,
                                title: "Saran\nBermain",
                                onTap: () => Get.toNamed(Routes.RECOMMENDATION, arguments: {
                                  'studentId': controller.studentId.value,
                                  'role': 'parent' 
                                }),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Catatan Terbaru 📝", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: teksGelap)),
                            TextButton(
                              onPressed: () => Get.toNamed(Routes.DEVELOPMENT_HISTORY, arguments: {'studentId': controller.studentId.value}), 
                              child: Text("Lihat Semua", style: TextStyle(color: pinkCeria, fontWeight: FontWeight.bold))
                            )
                          ],
                        ),
                        const SizedBox(height: 8),

                        _buildLatestObservationsList(),
                      ]
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${controller.getSalam()} ☀️", style: TextStyle(fontSize: 14, color: orenJeruk, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text("Halo, ${controller.parentName.value}!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: teksGelap), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text("Yuk cek perkembangan Ananda hari ini.", style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Get.toNamed(Routes.PROFILE), 
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: pinkCeria, width: 3)),
            child: const CircleAvatar(radius: 26, backgroundColor: Colors.white, backgroundImage: AssetImage('assets/orang tua.png')), 
          ),
        ),
      ],
    );
  }

  Widget _buildChildHeroCard() {
    var student = controller.studentData;

    String name = student['name'] ?? 
                  student['nama'] ?? 
                  student['nama_siswa'] ?? 
                  student['nama_lengkap'] ?? 
                  "Ananda";
                  
    String rawStatus = student['status'] ?? "";
    final statusInfo = _getStatusDetail(rawStatus);
    String status = statusInfo["label"];
    String initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : "A";

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [pinkCeria.withOpacity(0.8), pinkCeria], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: pinkCeria.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            width: 70, height: 70,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Center(child: Text(initial, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: pinkCeria))),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Flexible(child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMenuButton({required IconData icon, required Color color, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: color.withOpacity(0.3), width: 2), boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle), child: Icon(icon, color: color, size: 30)),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: teksGelap)),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestObservationsList() {
    var history = controller.assessmentHistory;
    
    if (history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade200)),
        child: Center(child: Text("Belum ada catatan dari guru Ananda.", style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600))),
      );
    }

    var latestTwo = history.take(2).toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: latestTwo.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildSingleObservationCard(latestTwo[index]);
      },
    );
  }

  // ===========================================================================
  // KARTU OBSERVASI TERBARU (BISA DIKLIK MEMUNCULKAN POPUP DETAIL)
  // ===========================================================================
  Widget _buildSingleObservationCard(Map<String, dynamic> obs) {
    String activity = obs['activity'] ?? "Kegiatan Observasi";
    String notes = obs['notes'] ?? "-";
    double score = (obs['score'] ?? 0).toDouble();
    
    String dateStr = "-";
    try {
      if (obs['date'] != null) {
        dateStr = DateFormat('dd MMM yyyy').format(DateTime.parse(obs['date']));
      }
    } catch (_) {
      dateStr = "-";
    }
    
    String kategori = obs['type'] ?? obs['kategori'] ?? "Motorik Kasar";
    String statusKode = obs['status'] ?? "";
    
    final statusInfo = _getStatusDetail(statusKode, score);
    final bool isKasar = kategori.toLowerCase().contains("kasar");

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showDetailObservationDialog(obs), // <-- AKSI KLIK DETAIL
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(24), 
            border: Border.all(color: biruAwan.withOpacity(0.3), width: 2), 
            boxShadow: [BoxShadow(color: biruAwan.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), 
                    decoration: BoxDecoration(color: biruAwan.withOpacity(0.15), borderRadius: BorderRadius.circular(8)), 
                    child: Text(dateStr, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: biruAwan)),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: statusInfo["color"], borderRadius: BorderRadius.circular(12)),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          statusInfo["label"],
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: isKasar ? Colors.orange.shade50 : Colors.purple.shade50,
                    label: Text(
                      isKasar ? "Motorik Kasar" : "Motorik Halus",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isKasar ? Colors.orange.shade900 : Colors.purple.shade900,
                      ),
                    ),
                  ),
                  // Petunjuk kecil bahwa kartu bisa diklik
                  Row(
                    children: [
                      Text("Lihat Detail", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: biruAwan)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, size: 12, color: biruAwan),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),

              Text(activity, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: teksGelap)),
              const SizedBox(height: 8),
              Text('"$notes"', style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5, fontStyle: FontStyle.italic), maxLines: 2, overflow: TextOverflow.ellipsis),
              
              const Divider(height: 24),
              Text(
                isKasar ? "💡 Tips Motorik Kasar:" : "💡 Tips Motorik Halus:",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: teksGelap),
              ),
              const SizedBox(height: 4),
              Text(
                isKasar 
                  ? "Melibatkan gerakan otot besar tubuh. Ajak anak aktif bergerak, berlari, atau bermain bola di luar ruangan agar keseimbangannya makin optimal."
                  : "Melibatkan ketelitian otot jari dan tangan. Dampingi anak bermain menggambar, menyusun balok, atau melipat kertas di rumah.",
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // MODAL DIALOG DETAIL OBSERVASI LENGKAP
  // ===========================================================================
  void _showDetailObservationDialog(Map<String, dynamic> obs) {
    String activity = obs['activity'] ?? "Kegiatan Observasi";
    String notes = obs['notes'] ?? "-";
    double score = (obs['score'] ?? 0).toDouble();
    String teacherName = obs['teacher_name'] ?? obs['nama_guru'] ?? "Guru Kelas";
    
    String dateStr = "-";
    try {
      if (obs['date'] != null) {
        dateStr = DateFormat('dd MMMM yyyy').format(DateTime.parse(obs['date']));
      }
    } catch (_) {
      dateStr = "-";
    }

    String kategori = obs['type'] ?? obs['kategori'] ?? "Motorik Kasar";
    String statusKode = obs['status'] ?? "";
    final statusInfo = _getStatusDetail(statusKode, score);
    final bool isKasar = kategori.toLowerCase().contains("kasar");
    Color typeColor = isKasar ? orenJeruk : Colors.purple.shade400;

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
                // Header Ikon & Tanggal
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: typeColor.withOpacity(0.15), shape: BoxShape.circle),
                      child: Icon(isKasar ? Icons.directions_run_rounded : Icons.edit_rounded, color: typeColor, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Detail Observasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: teksGelap)),
                          Text(dateStr, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: typeColor, borderRadius: BorderRadius.circular(12)),
                      child: Text("${score.toInt()} ⭐", style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Badge Status Capaian
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusInfo["color"],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    statusInfo["label"],
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

                // Narasi Catatan Guru
                Text("Catatan Anekdot Guru:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: bgBase, borderRadius: BorderRadius.circular(16)),
                  child: Text(
                    '"$notes"',
                    style: TextStyle(fontSize: 13.5, color: teksGelap, height: 1.5, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 14),

                // Nama Guru Pengamat
                Row(
                  children: [
                    Icon(Icons.person_pin_rounded, size: 18, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text("Guru: $teacherName", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey.shade700)),
                  ],
                ),
                const Divider(height: 28),

                // Saran / Tips Stimulasi
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isKasar ? Colors.orange.shade50 : Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isKasar ? Colors.orange.shade200 : Colors.purple.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isKasar ? "💡 Tips Stimulasi Motorik Kasar:" : "💡 Tips Stimulasi Motorik Halus:",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: isKasar ? Colors.orange.shade900 : Colors.purple.shade900),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isKasar
                            ? "Melibatkan gerakan otot besar tubuh. Ajak anak aktif bergerak, berlari, atau bermain bola di luar ruangan agar keseimbangannya makin optimal."
                            : "Melibatkan ketelitian otot jari dan tangan. Dampingi anak bermain menggambar, menyusun balok, atau melipat kertas di rumah.",
                        style: TextStyle(fontSize: 11.5, color: isKasar ? Colors.orange.shade900 : Colors.purple.shade900, height: 1.4),
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStudentState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(24),
        border: Border.all(color: orenJeruk.withOpacity(0.4), width: 2),
      ),
      child: Column(
        children: [
          Icon(Icons.link_off_rounded, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("Belum Terhubung", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: teksGelap)),
          const SizedBox(height: 8),
          Text("Silakan masukkan Token Ortu yang diberikan oleh guru untuk melihat perkembangan Ananda.", textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showTokenDialog(), 
            style: ElevatedButton.styleFrom(backgroundColor: orenJeruk, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            child: const Text("Hubungkan Token", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _showTokenDialog() {
    controller.tokenC.clear(); 
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: orenJeruk.withOpacity(0.2), shape: BoxShape.circle),
                    child: Icon(Icons.link_rounded, color: orenJeruk, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text("Hubungkan Akun", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: teksGelap)),
                ],
              ),
              const SizedBox(height: 16),
              Text("Masukkan 6 digit token yang diberikan oleh Guru untuk mengakses data Ananda.", style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              const SizedBox(height: 16),
              TextField(
                controller: controller.tokenC,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: "Contoh: AX92BZ",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold),
                  filled: true, fillColor: orenJeruk.withOpacity(0.1),
                  prefixIcon: Icon(Icons.key_rounded, color: orenJeruk),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: orenJeruk.withOpacity(0.5), width: 2)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: orenJeruk, width: 2)),
                ),
              ),
              const SizedBox(height: 24),
              Obx(() => SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: controller.isLinking.value ? null : () => controller.linkStudentToken(),
                  style: ElevatedButton.styleFrom(backgroundColor: orenJeruk, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: controller.isLinking.value 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) 
                      : const Text("Verifikasi Token", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text("Batal", style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}