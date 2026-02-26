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
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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


  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          
          Text(
            "Assalamualaikum, ${controller.getSalam()}", 
            style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87), 
              maxLines: 1, 
              overflow: TextOverflow.ellipsis
            );
          }),
        ]),
        
        
        GestureDetector(
          onTap: () => Get.toNamed(Routes.PROFILE),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)]
            ),
            child: const CircleAvatar(
              radius: 20, 
              backgroundColor: Color(0xFFE8F5E9), 
              backgroundImage: AssetImage('assets/guru.png')
            ),
          ),
        ),
      ],
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: isEdit ? Colors.orange.shade50 : Colors.green.shade50, shape: BoxShape.circle),
                child: Icon(isEdit ? Icons.edit_rounded : Icons.person_add_rounded, size: 32, color: isEdit ? Colors.orange : Colors.green.shade400),
              )),
              const SizedBox(height: 16),
              Center(child: Text(isEdit ? "Edit Data Siswa" : "Siswa Baru", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              const SizedBox(height: 24),

              _label("Nama Lengkap"),
              TextField(controller: controller.nameC, decoration: _inputDecor(Icons.person)),
              const SizedBox(height: 16),

              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label("Kelas"), Obx(() => _dropdown(controller.selectedKelas, ["TK A", "TK B"]))])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label("Gender"), Obx(() => _dropdown(controller.selectedGender, ["Laki-laki", "Perempuan"]))])),
              ]),
              const SizedBox(height: 16),

              _label("Tanggal Lahir"),
              GestureDetector(
                onTap: () => controller.pickDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(16)),
                  child: Row(children: [
                    const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
                    const SizedBox(width: 10),
                    Obx(() => Text(controller.selectedBirthDate.value == null ? "Pilih Tanggal" : "${controller.selectedBirthDate.value!.day}/${controller.selectedBirthDate.value!.month}/${controller.selectedBirthDate.value!.year}", style: const TextStyle(fontWeight: FontWeight.bold)))
                  ]),
                ),
              ),
              const SizedBox(height: 16),

              _label("Status Awal"),
              Obx(() => Wrap(spacing: 8, children: [_chip("Baik", Colors.green), _chip("Perlu Stimulasi", Colors.amber), _chip("Perlu Pendampingan", Colors.red)])),
              const SizedBox(height: 24),

              SizedBox(width: double.infinity, height: 50, child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : () => isEdit ? controller.updateStudent(docId!) : controller.addStudent(),
                style: ElevatedButton.styleFrom(backgroundColor: isEdit ? Colors.orange : const Color(0xFFA5D6A7), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text(isEdit ? "Update" : "Simpan", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ))),
              Center(child: TextButton(onPressed: () => Get.back(), child: const Text("Batal", style: TextStyle(color: Colors.grey))))
            ]),
          ),
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
    IconData genderIcon = isMale ? Icons.male_rounded : Icons.female_rounded;
    Color genderColor = isMale ? Colors.blue : Colors.pinkAccent;

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(Routes.STUDENT_DETAIL, arguments: {...data, 'color': statusColor}),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(width: 50, height: 50, decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle), child: Center(child: Text(name.isNotEmpty ? name[0] : "?", style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 20)))),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(children: [
                  Text("$kelas • $age • ", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Icon(genderIcon, size: 14, color: genderColor)
                ])
              ])),
              Row(children: [
                InkWell(onTap: () => _showInputDialog(context, isEdit: true, docId: id, dataLama: data), child: Padding(padding: const EdgeInsets.all(6), child: Icon(Icons.edit, size: 20, color: Colors.orange.shade300))),
                InkWell(onTap: () => controller.deleteStudent(id), child: Padding(padding: const EdgeInsets.all(6), child: Icon(Icons.delete, size: 20, color: Colors.red.shade300)))
              ])
            ]),
          ),
        ),
      ),
    );
  }

  
  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)));
  InputDecoration _inputDecor(IconData i) => InputDecoration(filled: true, fillColor: const Color(0xFFF5F6FA), prefixIcon: Icon(i, color: Colors.grey), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none));
  Widget _dropdown(RxString v, List<String> l) => Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(16)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: v.value, isExpanded: true, items: l.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (val) => v.value = val!)));
  Widget _chip(String l, Color c) => GestureDetector(onTap: () => controller.selectedStatus.value = l, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: controller.selectedStatus.value == l ? c.withOpacity(0.1) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: controller.selectedStatus.value == l ? c : Colors.grey.shade300)), child: Text(l, style: TextStyle(fontSize: 11, color: controller.selectedStatus.value == l ? c : Colors.grey))));

  Widget _buildHeroCard() {
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 10))]), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Ringkasan Data", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 16), Obx(() => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("${controller.totalSiswa.value}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16)), const SizedBox(height: 2), Text("Total Anak", style: TextStyle(fontSize: 10, color: Colors.blue.withOpacity(0.8)))])))])), Image.asset('assets/guru.png', height: 80, errorBuilder: (c,o,s) => const Icon(Icons.school, size: 60, color: Colors.orange))]));
  }

  Widget _buildEmptyState() {
    return const Center(child: Padding(padding: EdgeInsets.only(top: 50), child: Column(children: [Icon(Icons.person_search_rounded, size: 40, color: Colors.blue), SizedBox(height: 16), Text("Belum ada data siswa", style: TextStyle(color: Colors.grey))])));
  }
}