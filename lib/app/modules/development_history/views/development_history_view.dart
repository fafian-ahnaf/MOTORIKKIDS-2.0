import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart'; 
import '../controllers/development_history_controller.dart';

class DevelopmentHistoryView extends GetView<DevelopmentHistoryController> {
  const DevelopmentHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text("Riwayat & Tren", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87), onPressed: () => Get.back()),
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        
        // Cek jika data kosong
        if (controller.assessmentList.isEmpty) {
          return Center(child: Text("Belum ada riwayat.", style: TextStyle(color: Colors.grey)));
        }

        // Logic untuk grafik (min 2 titik agar garis terbentuk)
        double maxXVal = (controller.assessmentList.length - 1).toDouble();
        if (maxXVal < 1) maxXVal = 1.0; 

        return Column(
          children: [
            // Grafik
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              height: 250,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
              child: LineChart(
                LineChartData(
                  minY: 0.5, maxY: 4.5,
                  minX: 0, maxX: maxXVal,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, m) => Text(['','BB','MB','BSH','BSB'][v.toInt()], style: TextStyle(fontSize: 10)))),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: controller.assessmentList.reversed.toList().asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), controller.getChartValue(e.value['score'] ?? ""));
                      }).toList(),
                      isCurved: true, color: Colors.blue, barWidth: 4, dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            // List Riwayat
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: controller.assessmentList.length,
                separatorBuilder: (c, i) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _buildHistoryItem(controller.assessmentList[index]),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(data['date'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(data['date'])) : "-", style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text("Skor: ${data['score']}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),
          Text(data['activity'] ?? "-", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}