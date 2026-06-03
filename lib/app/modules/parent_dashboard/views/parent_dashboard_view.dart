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
                        _buildLatestObservationCard(),
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
            child: const CircleAvatar(radius: 26, backgroundColor: Colors.white, backgroundImage: AssetImage('assets/ortu.png')), 
          ),
        ),
      ],
    );
  }

  Widget _buildChildHeroCard() {
    var student = controller.studentData;
    String name = student['name'] ?? "Ananda";
    String status = student['status'] ?? "Belum Dinilai";

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
            child: Center(child: Text(name[0].toUpperCase(), style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: pinkCeria))),
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

  Widget _buildLatestObservationCard() {
    var obs = controller.latestObservation;
    if (obs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade200)),
        child: Center(child: Text("Belum ada catatan dari guru Ananda.", style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600))),
      );
    }

    String activity = obs['activity'] ?? "Kegiatan";
    String notes = obs['notes'] ?? "-";
    String dateStr = obs['date'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(obs['date'])) : "-";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: biruAwan.withOpacity(0.3), width: 2), boxShadow: [BoxShadow(color: biruAwan.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: biruAwan.withOpacity(0.15), borderRadius: BorderRadius.circular(8)), child: Text(dateStr, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: biruAwan))),
            ],
          ),
          const SizedBox(height: 12),
          Text(activity, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: teksGelap)),
          const SizedBox(height: 8),
          Text('"$notes"', style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5, fontStyle: FontStyle.italic)),
        ],
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
            // SUDAH DIUBAH: Sekarang memanggil Pop-up Dialog
            onPressed: () => _showTokenDialog(), 
            style: ElevatedButton.styleFrom(backgroundColor: orenJeruk, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            child: const Text("Hubungkan Token", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          )
        ],
      ),
    );
  }

  // --- WIDGET POP-UP DIALOG UNTUK TOKEN ---
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