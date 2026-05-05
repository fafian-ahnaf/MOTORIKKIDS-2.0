import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/teacher_dashboard_controller.dart';

class TeacherDashboardView extends GetView<TeacherDashboardController> {
  const TeacherDashboardView({Key? key}) : super(key: key);

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
            Container(color: bgBase),

            Positioned(
              top: -120, left: -100,
              child: Container(
                width: 350, height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [pinkCeria.withOpacity(0.25), pinkCeria.withOpacity(0.0)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
              ),
            ),
            Positioned(
              bottom: 0, left: -50, right: -50,
              child: Opacity(
                opacity: 0.35,
                child: Image.asset('assets/Background anak.png', fit: BoxFit.cover, errorBuilder: (c, e, s) => const SizedBox()), 
              ),
            ),
            Positioned(top: 100, left: 25, child: Icon(Icons.cloud_rounded, color: biruAwan.withOpacity(0.5), size: 60)),
            Positioned(top: 40, right: 30, child: Icon(Icons.cloud_rounded, color: biruAwan.withOpacity(0.3), size: 40)),

            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 110), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildHeroCard(),
                  const SizedBox(height: 30),
                  
                  // ==========================================================
                  // HEADER DAFTAR ANAK + TOMBOL MODE HAPUS BANYAK
                  // ==========================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Daftar Anak Didik 🎈", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: teksGelap, letterSpacing: 0.5)),
                      Obx(() {
                        if (controller.studentsStream.isEmpty) return const SizedBox();
                        return IconButton(
                          icon: Icon(
                            controller.isSelectionMode.value ? Icons.cancel_rounded : Icons.checklist_rtl_rounded, 
                            color: controller.isSelectionMode.value ? Colors.red : orenJeruk, 
                            size: 28
                          ),
                          onPressed: () => controller.toggleSelectionMode(),
                        );
                      })
                    ],
                  ),
                  
                  // ==========================================================
                  // PANEL PILIH SEMUA (Hanya Muncul Saat Mode Seleksi Aktif)
                  // ==========================================================
                  Obx(() {
                    if (!controller.isSelectionMode.value || controller.studentsStream.isEmpty) return const SizedBox();
                    bool isAllSelected = controller.selectedIds.length == controller.studentsStream.length;
                    
                    return Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50, 
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.red.shade200, width: 2)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: isAllSelected,
                                activeColor: Colors.red,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                onChanged: (val) => controller.toggleSelectAll(),
                              ),
                              Text("Pilih Semua", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700, fontSize: 16)),
                            ],
                          ),
                          if (controller.selectedIds.isNotEmpty)
                            ElevatedButton.icon(
                              onPressed: () => controller.deleteSelectedStudents(),
                              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 20),
                              label: Text("Hapus (${controller.selectedIds.length})", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red, 
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                              ),
                            )
                        ],
                      ),
                    );
                  }),
                  // ==========================================================

                  const SizedBox(height: 16),
                  
                  Obx(() {
                    if (controller.studentsStream.isEmpty) return _buildEmptyState();
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.studentsStream.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        var data = controller.studentsStream[index];
                        return _buildStudentItem(context: context, data: data, statusColor: controller.getStatusColor(data['status'] ?? "Belum Dinilai"));
                      },
                    );
                  }),
                ],
              ),
            ),

            // TOMBOL BAWAH (TAMBAH MANUAL + TITIK TIGA DI KANAN)
            Positioned(
              left: 24, right: 24, bottom: 24,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 65,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: pinkCeria.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
                      ),
                      child: ElevatedButton(
                        onPressed: () => _showInputDialog(context, isEdit: false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pinkCeria, elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.face_retouching_natural_rounded, color: Colors.white, size: 28),
                            SizedBox(width: 12),
                            Text("Tambah Manual", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  Container(
                    height: 65, width: 65,
                    decoration: BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: biruAwan.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                    ),
                    child: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded, color: biruAwan, size: 30),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      offset: const Offset(0, -170), 
                      onSelected: (value) {
                        if (value == 'import') controller.importCSV();
                        else if (value == 'template') controller.downloadTemplateCSV();
                        else if (value == 'pdf') controller.exportPDF();
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'import', child: _menuItem(Icons.upload_file_rounded, 'Import CSV', biruAwan)),
                        const PopupMenuDivider(),
                        PopupMenuItem(value: 'template', child: _menuItem(Icons.download_rounded, 'Unduh Template', orenJeruk)),
                        const PopupMenuDivider(),
                        PopupMenuItem(value: 'pdf', child: _menuItem(Icons.picture_as_pdf_rounded, 'Export PDF', Colors.redAccent)),
                      ],
                    ),
                  ),
                ],
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Assalamualaikum, ${controller.getSalam()} ☀️", style: TextStyle(fontSize: 15, color: orenJeruk, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Obx(() {
                String fullName = controller.namaGuru.value;
                String call = controller.panggilan.value;
                String displayName = fullName;
                if (call.isNotEmpty && !fullName.toLowerCase().startsWith(call.toLowerCase())) displayName = "$call $fullName";
                return Text(displayName, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: teksGelap), maxLines: 1, overflow: TextOverflow.ellipsis);
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
              boxShadow: [BoxShadow(color: pinkCeria.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: const CircleAvatar(radius: 28, backgroundColor: Colors.white, backgroundImage: AssetImage('assets/guru.png')),
          ),
        ),
      ],
    );
  }

  Widget _menuItem(IconData icon, String title, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.15), shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: teksGelap)),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF64B5F6), Color(0xFF29B6F6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(30), 
        boxShadow: [BoxShadow(color: biruAwan.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Data Anak Didik 🌟", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 16),
                Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${controller.totalSiswa.value}", style: TextStyle(fontWeight: FontWeight.w900, color: orenJeruk, fontSize: 22)),
                      const SizedBox(height: 2),
                      Text("Total Anak", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: teksGelap.withOpacity(0.6)))
                    ],
                  ),
                ))
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
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
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 20)]),
              child: Icon(Icons.sentiment_dissatisfied_rounded, size: 60, color: orenJeruk),
            ),
            const SizedBox(height: 20),
            Text("Yah, belum ada teman kecil...", style: TextStyle(color: teksGelap, fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 8),
            const Text("Yuk tambahkan sekarang! 👇", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // CARD DAFTAR SISWA (Menyesuaikan Jika Mode Seleksi Aktif)
  // ==========================================================
  Widget _buildStudentItem({required BuildContext context, required Map<String, dynamic> data, required Color statusColor}) {
    String name = data['name'] ?? "No Name"; String kelas = data['kelas'] ?? "-";
    String gender = data['gender'] ?? "Laki-laki"; String id = data['id']; String age = data['age'] ?? "-";
    bool isMale = gender == "Laki-laki";
    IconData genderIcon = isMale ? Icons.boy_rounded : Icons.girl_rounded;
    Color genderColor = isMale ? const Color(0xFF4FC3F7) : const Color(0xFFFF7E95);

    return Obx(() {
      bool isSelectionMode = controller.isSelectionMode.value;
      bool isSelected = controller.selectedIds.contains(id);

      return Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.shade50 : Colors.white, // Highlight merah terang jika dipilih
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? Colors.red : statusColor.withOpacity(0.5), width: isSelected ? 3 : 3), 
          boxShadow: [BoxShadow(color: statusColor.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 6))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Jika mode pilih aktif, tekan card akan otomatis mencentang
              if (isSelectionMode) {
                controller.toggleStudentSelection(id);
              } else {
                Get.toNamed(Routes.STUDENT_DETAIL, arguments: {...data, 'color': statusColor});
              }
            },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.2), shape: BoxShape.circle),
                    child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : "?", style: TextStyle(fontWeight: FontWeight.w900, color: statusColor, fontSize: 26))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: teksGelap)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: bgBase, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("$kelas • $age", style: TextStyle(fontSize: 12, color: teksGelap.withOpacity(0.7), fontWeight: FontWeight.bold)),
                              const SizedBox(width: 4), Icon(genderIcon, size: 16, color: genderColor)
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  
                  // JIKA MODE SELEKSI: Tampilkan Checkbox
                  // JIKA NORMAL: Tampilkan tombol Edit & Hapus
                  if (isSelectionMode)
                    Checkbox(
                      value: isSelected,
                      activeColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      onChanged: (val) => controller.toggleStudentSelection(id),
                    )
                  else
                    Column(
                      children: [
                        InkWell(
                          onTap: () => _showInputDialog(context, isEdit: true, docId: id, dataLama: data),
                          child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle), child: Icon(Icons.edit_rounded, size: 20, color: orenJeruk)),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => controller.deleteStudent(id),
                          child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle), child: Icon(Icons.delete_rounded, size: 20, color: Colors.red.shade400)),
                        ),
                      ],
                    )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void _showInputDialog(BuildContext context, {required bool isEdit, String? docId, Map<String, dynamic>? dataLama}) {
    if (!isEdit) controller.resetForm(); else if (dataLama != null) controller.fillFormToEdit(dataLama);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: pinkCeria, width: 4)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: isEdit ? orenJeruk.withOpacity(0.2) : pinkCeria.withOpacity(0.2), shape: BoxShape.circle),
                    child: Icon(isEdit ? Icons.edit_note_rounded : Icons.child_care_rounded, size: 40, color: isEdit ? orenJeruk : pinkCeria),
                  ),
                ),
                const SizedBox(height: 16),
                Center(child: Text(isEdit ? "✏️ Edit Teman Kecil" : "🌟 Daftar Peserta Baru", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: teksGelap))),
                const SizedBox(height: 24),

                _label("Nama Lengkap"),
                TextField(controller: controller.nameC, decoration: _inputDecor(Icons.person_rounded), style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label("Kelas"), Obx(() => _dropdown(controller.selectedKelas, ["TK A", "TK B"]))])),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label("Jenis Kelamin"), Obx(() => _dropdown(controller.selectedGender, ["Laki-laki", "Perempuan"]))])),
                  ],
                ),
                const SizedBox(height: 16),

                _label("Tanggal Lahir 📅"), 
                GestureDetector(
                  onTap: () => controller.pickDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(color: bgBase, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.transparent)),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month_rounded, color: orenJeruk, size: 22), const SizedBox(width: 12),
                        Obx(() => Text(
                          controller.selectedBirthDate.value == null ? "Pilih Tanggal..." : "${controller.selectedBirthDate.value!.day}/${controller.selectedBirthDate.value!.month}/${controller.selectedBirthDate.value!.year}",
                          style: TextStyle(fontWeight: FontWeight.w800, color: controller.selectedBirthDate.value == null ? Colors.grey : teksGelap),
                        ))
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity, height: 55,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : () { if (isEdit) controller.updateStudent(docId!); else controller.addStudent(); },
                    style: ElevatedButton.styleFrom(backgroundColor: isEdit ? orenJeruk : pinkCeria, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 5),
                    child: Text(isEdit ? "Update Data!" : "Simpan Data!", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                  )),
                ),
                const SizedBox(height: 8),
                Center(child: TextButton(onPressed: () => Get.back(), child: const Text("Batal", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 8, left: 4), child: Text(t, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: teksGelap)));

  InputDecoration _inputDecor(IconData i) => InputDecoration(
        filled: true, fillColor: bgBase, prefixIcon: Icon(i, color: pinkCeria), contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.transparent)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: pinkCeria, width: 2)),
      );

  Widget _dropdown(RxString v, List<String> l) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), decoration: BoxDecoration(color: bgBase, borderRadius: BorderRadius.circular(20)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: v.value, isExpanded: true, icon: Icon(Icons.arrow_drop_down_circle_rounded, color: biruAwan),
            style: TextStyle(fontWeight: FontWeight.w800, color: teksGelap, fontFamily: 'Roboto'),
            items: l.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => v.value = val!,
          ),
        ),
      );
}