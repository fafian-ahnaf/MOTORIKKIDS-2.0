import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/development_history_controller.dart';

class DevelopmentHistoryView extends GetView<DevelopmentHistoryController> {
  const DevelopmentHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text("Riwayat Perkembangan", 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.assessmentList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text("Belum ada data penilaian.", 
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: controller.assessmentList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            var data = controller.assessmentList[index];
            return _buildHistoryItem(data);
          },
        );
      }),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> data) {
    
    String activity = data['activity'] ?? "Kegiatan Motorik";
    String score = data['score']?.toString() ?? "0";
    String notes = (data['notes'] == null || data['notes'] == "") 
        ? "Tidak ada catatan tambahan." 
        : data['notes'];
    
    
    String dateStr = "Tanpa Tanggal";
    if (data['date'] != null) {
      DateTime dt = DateTime.parse(data['date']);
      dateStr = DateFormat('dd MMMM yyyy, HH:mm').format(dt);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(dateStr, 
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("Skor: $score", 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(activity, 
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          const Text("Catatan Guru:", 
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(notes, 
            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
        ],
      ),
    );
  }
}