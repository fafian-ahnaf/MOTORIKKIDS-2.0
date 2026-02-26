import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/parent_dashboard_controller.dart';

class ParentDashboardView extends GetView<ParentDashboardController> {
  const ParentDashboardView({Key? key}) : super(key: key);

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              _buildHeader(),
              
              const SizedBox(height: 30),
              
              const Text(
                "Perkembangan Si Kecil",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),

              
              _buildChildCard(),
              
              const SizedBox(height: 30),

              
              const Text(
                "Menu Orang Tua",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              
              
              _buildMenuTile(
                "Lihat Riwayat", 
                "Cek hasil observasi guru", 
                Icons.history_edu_rounded, 
                Colors.blueAccent, 
                () {
                  if (controller.studentId.value.isNotEmpty) {
                    Get.toNamed(
                      Routes.DEVELOPMENT_HISTORY, 
                      arguments: {'studentId': controller.studentId.value}
                    );
                  } else {
                    Get.snackbar("Belum Terhubung", "Data anak belum tersedia.", backgroundColor: Colors.orange.shade100);
                  }
                }
              ),
              
              const SizedBox(height: 16),
              
              
              _buildMenuTile(
                "Rekomendasi Aktivitas", 
                "Lihat saran aktivitas dari guru", 
                Icons.lightbulb_rounded, 
                Colors.orange, 
                () {
                  if (controller.studentId.value.isNotEmpty) {
                    Get.toNamed(
                      Routes.RECOMMENDATION,
                      arguments: {
                        'studentId': controller.studentId.value,
                        'role': 'parent', 
                        'age': '5 Tahun', 
                        'fineScore': 0.0, 
                        'grossScore': 0.0, 
                      }
                    );
                  } else {
                    Get.snackbar("Belum Terhubung", "Data anak belum tersedia.", backgroundColor: Colors.orange.shade100);
                  }
                }
              ),
            ],
          ),
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
            String fullName = controller.parentName.value;
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
              backgroundColor: Color(0xFFE3F2FD), 
              backgroundImage: AssetImage('assets/orang tua.png') 
            ),
          ),
        ),
      ],
    );
  }

  
  Widget _buildChildCard() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF2196F3)], 
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 10))
        ],
      ),
      child: controller.isLoading.value
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFE3F2FD),
                  backgroundImage: AssetImage('assets/logo_anak.png'),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.childName.value,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        controller.className.value,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    ));
  }

  
  Widget _buildMenuTile(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade300),
        ),
      ),
    );
  }
}