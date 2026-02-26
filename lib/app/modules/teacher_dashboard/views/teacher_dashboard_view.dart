import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/teacher_dashboard_controller.dart';

class TeacherDashboardView extends GetView<TeacherDashboardController> {
  const TeacherDashboardView({Key? key}) : super(key: key);

  // --- PALET WARNA CERIA ---
  final Color bgBase = const Color(0xFFFFF8E7); 
  final Color pinkCeria = const Color(0xFFFF7E95); 
  final Color biruAwan = const Color(0xFF4FC3F7); 
  final Color orenJeruk = const Color(0xFFFFB74D);
  final Color teksGelap = const Color(0xFF4A4A4A);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: bgBase,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // ============================================================
            // --- BACKGROUND DENGAN GAMBAR ANAK-ANAK ---
            // ============================================================
            Container(color: bgBase),

            Positioned(
              top: -120,
              left: -100,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [pinkCeria.withOpacity(0.25), pinkCeria.withOpacity(0.0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 0,
              left: -50,
              right: -50,
              child: Opacity(
                opacity: 0.35,
                child: Image.asset(
                  'assets/Background anak.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(), 
                ),
              ),
            ),

            Positioned(top: 100, left: 25, child: Icon(Icons.cloud_rounded, color: biruAwan.withOpacity(0.5), size: 60)),
            Positioned(top: 40, right: 30, child: Icon(Icons.cloud_rounded, color: biruAwan.withOpacity(0.3), size: 40)),

            // ============================================================
            // --- KONTEN UTAMA ---
            // ============================================================
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildHeroCard(),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Text(
                        "Daftar Anak Didik 🎈",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: teksGelap,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (controller.studentsStream.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.studentsStream.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        var data = controller.studentsStream[index];

                        return _buildStudentItem(
                          context: context,
                          data: data,
                          statusColor: controller.getStatusColor(data['status'] ?? "Baik"),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),

            // --- TOMBOL TAMBAH MELAYANG ---
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: pinkCeria.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 65, 
                  child: ElevatedButton(
                    onPressed: () => _showInputDialog(context, isEdit: false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pinkCeria,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.face_retouching_natural_rounded, color: Colors.white, size: 28),
                        SizedBox(width: 12),
                        Text(
                          "Tambah Anak Hebat!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo, ${controller.getSalam()} ☀️",
                style: TextStyle(fontSize: 15, color: orenJeruk, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Obx(() {
                String fullName = controller.namaGuru.value;
                String call = controller.panggilan.value;
                String displayName = fullName;
                if (call.isNotEmpty && !fullName.toLowerCase().startsWith(call.toLowerCase())) {
                  displayName = "$call $fullName";
                }

                return Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: teksGelap,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              }),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Get.toNamed(Routes.PROFILE),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: pinkCeria, width: 3), 
              boxShadow: [
                BoxShadow(color: pinkCeria.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: const CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/guru.png'), 
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF64B5F6), Color(0xFF29B6F6)], 
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30), 
        boxShadow: [
          BoxShadow(
            color: biruAwan.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Data Anak Didik 🌟",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${controller.totalSiswa.value}",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: orenJeruk,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Total Anak",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: teksGelap.withOpacity(0.6),
                        ),
                      )
                    ],
                  ),
                ))
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.toys_rounded, size: 60, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 20)
                ]
              ),
              child: Icon(Icons.sentiment_dissatisfied_rounded, size: 60, color: orenJeruk),
            ),
            const SizedBox(height: 20),
            Text(
              "Yah, belum ada teman kecil...",
              style: TextStyle(color: teksGelap, fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              "Yuk tambahkan sekarang! 👇",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentItem({required BuildContext context, required Map<String, dynamic> data, required Color statusColor}) {
    String name = data['name'] ?? "No Name";
    String kelas = data['kelas'] ?? "-";
    String gender = data['gender'] ?? "Laki-laki";
    String id = data['id'];
    String age = data['age'] ?? "-";

    bool isMale = gender == "Laki-laki";
    IconData genderIcon = isMale ? Icons.boy_rounded : Icons.girl_rounded;
    Color genderColor = isMale ? const Color(0xFF4FC3F7) : const Color(0xFFFF7E95);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withOpacity(0.5), width: 3), 
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(Routes.STUDENT_DETAIL, arguments: {...data, 'color': statusColor}),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "?",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                        fontSize: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: teksGelap),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: bgBase,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "$kelas • $age",
                              style: TextStyle(fontSize: 12, color: teksGelap.withOpacity(0.7), fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            Icon(genderIcon, size: 16, color: genderColor)
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Column(
                  children: [
                    InkWell(
                      onTap: () => _showInputDialog(context, isEdit: true, docId: id, dataLama: data),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
                        child: Icon(Icons.edit_rounded, size: 20, color: orenJeruk),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => controller.deleteStudent(id),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                        child: Icon(Icons.delete_rounded, size: 20, color: Colors.red.shade400),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showInputDialog(BuildContext context, {required bool isEdit, String? docId, Map<String, dynamic>? dataLama}) {
    if (!isEdit) {
      controller.resetForm();
    } else if (dataLama != null) {
      controller.fillFormToEdit(dataLama);
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), 
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: pinkCeria, width: 4), 
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isEdit ? orenJeruk.withOpacity(0.2) : pinkCeria.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isEdit ? Icons.edit_note_rounded : Icons.child_care_rounded,
                      size: 40,
                      color: isEdit ? orenJeruk : pinkCeria,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    isEdit ? "✏️ Edit Teman Kecil" : "🌟 Daftar Peserta Baru", // --- UPDATED ---
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: teksGelap),
                  ),
                ),
                const SizedBox(height: 24),

                _label("Nama Lengkap"),
                TextField(
                  controller: controller.nameC,
                  decoration: _inputDecor(Icons.person_rounded),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label("Kelas"),
                          Obx(() => _dropdown(controller.selectedKelas, ["TK A", "TK B"])),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label("Jenis Kelamin"), // --- UPDATED ---
                          Obx(() => _dropdown(controller.selectedGender, ["Laki-laki", "Perempuan"])),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _label("Tanggal Lahir 📅"), // --- UPDATED ---
                GestureDetector(
                  onTap: () => controller.pickDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: bgBase,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month_rounded, color: orenJeruk, size: 22), // Ikon diganti
                        const SizedBox(width: 12),
                        Obx(() => Text(
                          controller.selectedBirthDate.value == null
                              ? "Pilih Tanggal..."
                              : "${controller.selectedBirthDate.value!.day}/${controller.selectedBirthDate.value!.month}/${controller.selectedBirthDate.value!.year}",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: controller.selectedBirthDate.value == null ? Colors.grey : teksGelap,
                          ),
                        ))
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _label("Status Perkembangan 📈"),
                // --- STATUS PERKEMBANGAN YANG LEBIH MENARIK ---
                Obx(() => Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _statusChip("Baik", Icons.sentiment_very_satisfied_rounded, Colors.green),
                    _statusChip("Perlu Stimulasi", Icons.extension_rounded, orenJeruk), // Ikon puzzle
                    _statusChip("Perlu Pendampingan", Icons.volunteer_activism_rounded, Colors.redAccent), // Ikon hati & tangan
                  ],
                )),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (isEdit) {
                              controller.updateStudent(docId!);
                            } else {
                              controller.addStudent();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEdit ? orenJeruk : pinkCeria,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 5,
                    ),
                    child: Text(
                      isEdit ? "Update Data!" : "Simpan Data!",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  )),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text("Batal", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(t, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: teksGelap)),
      );

  InputDecoration _inputDecor(IconData i) => InputDecoration(
        filled: true,
        fillColor: bgBase, 
        prefixIcon: Icon(i, color: pinkCeria),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: pinkCeria, width: 2),
        ),
      );

  Widget _dropdown(RxString v, List<String> l) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: bgBase,
          borderRadius: BorderRadius.circular(20),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: v.value,
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down_circle_rounded, color: biruAwan),
            style: TextStyle(fontWeight: FontWeight.w800, color: teksGelap, fontFamily: 'Roboto'),
            items: l.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => v.value = val!,
          ),
        ),
      );

  // --- WIDGET STATUS PERKEMBANGAN (BARU) ---
  Widget _statusChip(String label, IconData icon, Color color) {
    bool isSelected = controller.selectedStatus.value == label;
    
    return GestureDetector(
      onTap: () => controller.selectedStatus.value = label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(25), // Pill shape yang lucu
          border: Border.all(
            color: isSelected ? Colors.transparent : color.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              size: 20, 
              color: isSelected ? Colors.white : color
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}