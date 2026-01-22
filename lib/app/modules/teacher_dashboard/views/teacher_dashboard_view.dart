import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/teacher_dashboard_controller.dart';

class TeacherDashboardView extends GetView<TeacherDashboardController> {
  const TeacherDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            // --- KONTEN SCROLLABLE ---
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildHeroCard(),
                  const SizedBox(height: 30),
                  const Text(
                    "Daftar Anak Didik",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  
                  // LIST SISWA
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
                          data: data, // Kirim seluruh data map
                          statusColor: controller.getStatusColor(data['status'] ?? "Baik"),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),

            // --- TOMBOL TAMBAH ---
            Positioned(
              left: 24, right: 24, bottom: 24,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: const Color(0xFFA5D6A7).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _showInputDialog(context, isEdit: false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA5D6A7),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_rounded, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text("Tambah Siswa", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
  //      ✨ DIALOG INPUT (BISA EDIT & TAMBAH) ✨
  // ==========================================================
  void _showInputDialog(BuildContext context, {required bool isEdit, String? docId, Map<String, dynamic>? dataLama}) {
    // Jika Mode Tambah, Reset Form dulu
    if (!isEdit) {
      controller.resetForm();
    } else if (dataLama != null) {
      // Jika Mode Edit, Isi Form dengan data lama
      controller.fillFormToEdit(dataLama);
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
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: isEdit ? Colors.orange.shade50 : Colors.green.shade50, shape: BoxShape.circle),
                    child: Icon(isEdit ? Icons.edit_rounded : Icons.person_add_rounded, size: 32, color: isEdit ? Colors.orange : Colors.green.shade400),
                  ),
                ),
                const SizedBox(height: 16),
                Center(child: Text(isEdit ? "Edit Data Siswa" : "Data Siswa Baru", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87))),
                const SizedBox(height: 24),

                // Form Nama
                _buildLabel("Nama Lengkap"),
                TextField(
                  controller: controller.nameC,
                  decoration: _inputDecoration(Icons.person_rounded),
                ),
                const SizedBox(height: 16),

                // Form Kelas & Gender
                Row(
                  children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _buildLabel("Kelas"),
                        Obx(() => _buildDropdown(controller.selectedKelas, ["TK A", "TK B", "KB"])),
                      ]),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _buildLabel("Jenis Kelamin"),
                        Obx(() => _buildDropdown(controller.selectedGender, ["Laki-laki", "Perempuan"])),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Form Tanggal Lahir
                _buildLabel("Tanggal Lahir"),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () => controller.pickDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, color: Colors.grey.shade400, size: 18),
                              const SizedBox(width: 10),
                              Obx(() => Text(
                                controller.selectedBirthDate.value == null 
                                  ? "Pilih Tanggal" 
                                  : "${controller.selectedBirthDate.value!.day}/${controller.selectedBirthDate.value!.month}/${controller.selectedBirthDate.value!.year}",
                                style: TextStyle(fontWeight: FontWeight.bold, color: controller.selectedBirthDate.value == null ? Colors.grey.shade400 : Colors.black87),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                            style: TextStyle(fontWeight: FontWeight.bold, color: controller.selectedBirthDate.value == null ? Colors.grey.shade400 : Colors.green.shade700),
                          ),
                        ),
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Form Status
                _buildLabel("Status Awal"),
                Obx(() => Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    _buildModernChip("Baik", Colors.green, Icons.sentiment_very_satisfied_rounded),
                    _buildModernChip("Perlu Stimulasi", Colors.amber, Icons.sentiment_neutral_rounded),
                    _buildModernChip("Perlu Pendampingan", Colors.red, Icons.sentiment_dissatisfied_rounded),
                  ],
                )),
                const SizedBox(height: 28),

                // Tombol Simpan/Update
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : () {
                      if (isEdit && docId != null) {
                        controller.updateStudent(docId);
                      } else {
                        controller.addStudent();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEdit ? Colors.orange : const Color(0xFFA5D6A7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: controller.isLoading.value
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(isEdit ? "Update Data" : "Simpan Data", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  )),
                ),
                const SizedBox(height: 12),
                Center(child: TextButton(onPressed: () => Get.back(), child: const Text("Batal", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)))),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ==========================================================
  //      ✨ KARTU SISWA (DENGAN EDIT & DELETE) ✨
  // ==========================================================
  Widget _buildStudentItem({
    required Map<String, dynamic> data,
    required Color statusColor,
  }) {
    String name = data['name'] ?? "Tanpa Nama";
    String kelas = data['kelas'] ?? "TK A";
    String gender = data['gender'] ?? "Laki-laki";
    String age = data['age'] ?? "-";
    String statusLabel = data['status'] ?? "Baik";
    String id = data['id'];

    bool isMale = gender == "Laki-laki";
    IconData genderIcon = isMale ? Icons.male_rounded : Icons.female_rounded;
    Color genderColor = isMale ? Colors.blue : Colors.pinkAccent;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          // Navigasi ke Detail
          onTap: () {
            Get.toNamed(
              Routes.STUDENT_DETAIL, 
              arguments: {
                'id': id, 'name': name, 'age': age, 'gender': gender, 
                'kelas': kelas, 'status': statusLabel, 'color': statusColor,
              }
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : "?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: statusColor))),
                ),
                const SizedBox(width: 16),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                            child: Text(kelas, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                          ),
                          const SizedBox(width: 6),
                          Text("$age • ", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          Icon(genderIcon, size: 14, color: genderColor),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // --- TOMBOL AKSI (EDIT & DELETE) ---
                Row(
                  children: [
                    // Edit Button
                    InkWell(
                      onTap: () => _showInputDialog(Get.context!, isEdit: true, docId: id, dataLama: data),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(Icons.edit_rounded, size: 20, color: Colors.orange.shade300),
                      ),
                    ),
                    // Delete Button
                    InkWell(
                      onTap: () => controller.deleteStudent(id),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(Icons.delete_rounded, size: 20, color: Colors.red.shade300),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildDropdown(RxString value, List<String> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value.value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          items: items.map((String val) => DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: (val) => value.value = val!,
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)));
  }

  InputDecoration _inputDecoration(IconData icon) {
    return InputDecoration(
      filled: true, fillColor: const Color(0xFFF5F6FA),
      prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
    );
  }

  Widget _buildModernChip(String label, Color color, IconData icon) {
    bool isSelected = controller.selectedStatus.value == label;
    return GestureDetector(
      onTap: () => controller.selectedStatus.value = label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? color : Colors.grey),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? color : Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Selamat Datang,", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Obx(() => Text(controller.namaGuru.value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
        const CircleAvatar(radius: 20, backgroundColor: Color(0xFFE8F5E9), backgroundImage: AssetImage('assets/guru.png')),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Ringkasan Data", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Obx(() => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("${controller.totalSiswa.value}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16)), const SizedBox(height: 2), Text("Total Anak", style: TextStyle(fontSize: 10, color: Colors.blue.withOpacity(0.8)))]))),
        ])),
        Image.asset('assets/guru.png', height: 80, errorBuilder: (c,o,s) => Icon(Icons.school, size: 60, color: Colors.orange.shade300)),
      ]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(padding: const EdgeInsets.only(top: 50), child: Column(children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle), child: Icon(Icons.person_search_rounded, size: 40, color: Colors.blue.shade300)),
        const SizedBox(height: 16),
        Text("Belum ada data siswa", style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
      ])),
    );
  }
}