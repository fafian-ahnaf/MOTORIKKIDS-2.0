import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Wajib untuk SystemChrome
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/teacher_dashboard_controller.dart';

class TeacherDashboardView extends GetView<TeacherDashboardController> {
  const TeacherDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. KONFIGURASI NAVIGASI BAR HP JADI PUTIH
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Stack(
          children: [
            // --- LAYER 1: KONTEN SCROLLABLE ---
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  
                  // Kartu Statistik Realtime
                  _buildHeroCard(),
                  
                  const SizedBox(height: 30),
                  const Text(
                    "Daftar Anak",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  
                  // LIST SISWA (REALTIME & PREMIUM)
                  Obx(() {
                    if (controller.studentsStream.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.person_search_rounded, size: 40, color: Colors.blue.shade300),
                              ),
                              const SizedBox(height: 16),
                              Text("Belum ada data siswa", 
                                style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.studentsStream.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        var data = controller.studentsStream[index];
                        
                        // FIX: Pastikan ID diambil dari data firebase
                        String docId = data['id'] ?? ""; 

                        return _buildStudentItem(
                          id: docId, // Kirim ID ke widget
                          name: data['name'] ?? "Tanpa Nama",
                          age: data['age'] ?? "-",
                          statusLabel: data['status'] ?? "Baik",
                          statusColor: controller.getStatusColor(data['status']),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),

            // --- LAYER 2: TOMBOL TAMBAH (STICKY BOTTOM) ---
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA5D6A7).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _showInputDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA5D6A7),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_rounded, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text(
                          "Tambah Catatan",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
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
  //      ✨ INPUT DIALOG CALENDAR & AUTO AGE (POP-UP) ✨
  // ==========================================================
  void _showInputDialog(BuildContext context) {
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Dialog
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.edit_note_rounded, size: 32, color: Colors.green.shade400),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text("Catat Perkembangan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87)),
                ),
                const SizedBox(height: 24),

                // 1. INPUT NAMA
                const Text("Nama Lengkap", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.nameC,
                  decoration: InputDecoration(
                    hintText: "Contoh: Budi Santoso",
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                    prefixIcon: Icon(Icons.person_rounded, color: Colors.grey.shade400),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. INPUT TANGGAL (KALENDER)
                const Text("Tanggal Lahir & Umur", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // A. Tombol Pilih Tanggal
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () => controller.pickDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6FA),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.transparent),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_month_rounded, color: Colors.grey.shade400, size: 20),
                              const SizedBox(width: 10),
                              Obx(() {
                                if (controller.selectedBirthDate.value == null) {
                                  return Text("Pilih Tgl", style: TextStyle(color: Colors.grey.shade400));
                                } else {
                                  DateTime date = controller.selectedBirthDate.value!;
                                  return Text(
                                    "${date.day}/${date.month}/${date.year}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                  );
                                }
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // B. Badge Umur Otomatis
                    Expanded(
                      flex: 2,
                      child: Obx(() => Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: controller.selectedBirthDate.value == null ? Colors.grey.shade100 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            controller.ageText.value.isEmpty ? "- Thn" : controller.ageText.value,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13,
                              color: controller.selectedBirthDate.value == null ? Colors.grey.shade400 : Colors.green.shade700,
                            ),
                          ),
                        ),
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 3. PILIHAN STATUS
                const Text("Status Saat Ini", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 12),
                Obx(() => Wrap(
                  spacing: 10, runSpacing: 10,
                  children: [
                    _buildModernChip("Baik", Colors.green, Icons.sentiment_very_satisfied_rounded),
                    _buildModernChip("Perlu Stimulasi", Colors.amber, Icons.sentiment_neutral_rounded),
                    _buildModernChip("Perlu Pendampingan", Colors.red, Icons.sentiment_dissatisfied_rounded),
                  ],
                )),
                const SizedBox(height: 28),

                // 4. TOMBOL AKSI
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: Text("Batal", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value ? null : () => controller.addStudent(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA5D6A7),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: controller.isLoading.value
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Simpan Data", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      )),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildModernChip(String label, Color color, IconData icon) {
    bool isSelected = controller.selectedStatus.value == label;
    return GestureDetector(
      onTap: () => controller.selectedStatus.value = label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isSelected ? color : Colors.grey.shade200, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? color : Colors.grey),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: isSelected ? color : Colors.grey.shade600, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  //      ✨ STUDENT CARD & NAVIGATION ✨
  // ==========================================================
  Widget _buildStudentItem({
    required String id, // ID Wajib ada
    required String name,
    required String age,
    required String statusLabel,
    required Color statusColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          // NAVIGASI KE DETAIL + KIRIM ID & DATA
          onTap: () {
            Get.toNamed(
              Routes.STUDENT_DETAIL, 
              arguments: {
                'id': id, // Mengirim ID dokumen untuk update
                'name': name,
                'age': age,
                'status': statusLabel,
                'color': statusColor,
              }
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar Inisial
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "?",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: statusColor),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Info Siswa
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.cake_rounded, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(age, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor.withOpacity(0.2)),
                        ),
                        child: Text(statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
                      ),
                    ],
                  ),
                ),
                
                // Panah
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET LAINNYA ---
  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Catatan Minggu Ini", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Obx agar update realtime
                    Obx(() => _buildStatItem("Total Anak", "${controller.totalSiswa.value}", Colors.blue.shade50, Colors.blue)),
                  ],
                ),
              ],
            ),
          ),
          Image.asset('assets/guru.png', height: 80, errorBuilder: (ctx, _, __) => const Icon(Icons.child_care, size: 60, color: Colors.orange)), 
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: text, fontSize: 16)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: text.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Dashboard Guru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("Monitoring Perkembangan Anak", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
        Row(
          children: [
            Icon(Icons.notifications_none_rounded, color: Colors.green.shade300, size: 28),
            const SizedBox(width: 12),
            const CircleAvatar(radius: 18, backgroundColor: Colors.grey, backgroundImage: AssetImage('assets/guru.png')),
          ],
        )
      ],
    );
  }
}