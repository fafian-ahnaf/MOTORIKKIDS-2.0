import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/parent_dashboard_controller.dart';

class ParentDashboardView extends GetView<ParentDashboardController> {
  const ParentDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FD),
      appBar: AppBar(
        title: const Text("Dashboard Orang Tua"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () => controller.logout(),
            icon: const Icon(Icons.logout, color: Colors.grey),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GREETING
            Obx(() => Text(
              "Halo, ${controller.parentName.value} 👋",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            )),
            const SizedBox(height: 5),
            const Text(
              "Perkembangan Si Kecil",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 24),

            // DATA ANAK (DARI FIREBASE)
            Obx(() => Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.lightBlue]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 15, offset: Offset(0, 10))],
              ),
              child: controller.isLoading.value
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Image.asset('assets/logo_anak.png'),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.childName.value,
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              controller.className.value,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
            )),
            
            const SizedBox(height: 30),

            // MENU ORTU
            _buildMenuTile("Lihat Riwayat", "Cek hasil observasi", Icons.history_edu_rounded, Colors.blueAccent, () => Get.toNamed(Routes.DEVELOPMENT_HISTORY)),
            const SizedBox(height: 15),
            _buildMenuTile("Rekomendasi", "Tips melatih motorik", Icons.lightbulb_rounded, Colors.orange, () => Get.toNamed(Routes.RECOMMENDATION)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      ),
    );
  }
}