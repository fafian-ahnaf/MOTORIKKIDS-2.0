import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/teacher_dashboard_controller.dart';

class TeacherDashboardView extends GetView<TeacherDashboardController> {
  const TeacherDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER (Orange Theme)
            Container(
              padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 30),
              decoration: const BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Selamat Pagi,",
                            style: TextStyle(color: Colors.orange.shade100, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          // NAMA USER DARI FIREBASE (Pakai Obx)
                          Obx(() => Text(
                            controller.userName.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                        ],
                      ),
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage('assets/guru.png'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Statistik (Data dari Firebase)
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                    ),
                    child: Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem("Total Siswa", "${controller.totalSiswa.value}", Icons.groups_outlined),
                        Container(height: 30, width: 1, color: Colors.grey.shade300),
                        _buildStatItem("Laporan", "${controller.totalLaporan.value}", Icons.assignment_turned_in_outlined),
                      ],
                    )),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. MENU GRID (Tetap Sama)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildMenuCard("Input Observasi", Icons.edit_note_rounded, Colors.orange, () => Get.toNamed(Routes.ASSESSMENT_FORM)),
                  _buildMenuCard("Data Siswa", Icons.child_care_rounded, Colors.blue, () => Get.toNamed(Routes.STUDENT_LIST)),
                  _buildMenuCard("Hasil Analisa", Icons.analytics_rounded, Colors.purple, () => Get.toNamed(Routes.ANALYSIS_RESULT)),
                  _buildMenuCard("Profil Saya", Icons.person_rounded, Colors.teal, () => Get.toNamed(Routes.PROFILE)),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            TextButton.icon(
              onPressed: () => controller.logout(),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text("Keluar Akun", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildMenuCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withOpacity(0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}