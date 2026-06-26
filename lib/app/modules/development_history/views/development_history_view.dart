import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart'; 
import '../controllers/development_history_controller.dart';

class DevelopmentHistoryView extends GetView<DevelopmentHistoryController> {
  const DevelopmentHistoryView({Key? key}) : super(key: key);

  // --- PALET WARNA CERIA ---
  final Color bgBase = const Color(0xFFFFF8E7); 
  final Color pinkCeria = const Color(0xFFFF7E95); 
  final Color biruAwan = const Color(0xFF4FC3F7); 
  final Color orenJeruk = const Color(0xFFFFB74D);
  final Color teksGelap = const Color(0xFF4A4A4A);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: bgBase,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Riwayat & Tren 📈", style: TextStyle(color: teksGelap, fontWeight: FontWeight.w900, fontSize: 20)), 
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white, shape: BoxShape.circle, 
              border: Border.all(color: biruAwan, width: 2),
              boxShadow: [BoxShadow(color: biruAwan.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.black87),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // ============================================================
          // --- BACKGROUND DEKORASI ---
          // ============================================================
          Positioned(top: -50, right: -50, child: Icon(Icons.circle, size: 200, color: pinkCeria.withOpacity(0.1))),
          Positioned(top: 250, left: -50, child: Icon(Icons.circle, size: 150, color: orenJeruk.withOpacity(0.15))),
          Positioned(bottom: 100, right: -20, child: Icon(Icons.circle, size: 200, color: biruAwan.withOpacity(0.15))),
          Positioned(top: 100, left: 20, child: Icon(Icons.cloud_rounded, size: 60, color: Colors.white.withOpacity(0.8))),
          Positioned(top: 180, right: 30, child: Icon(Icons.cloud_rounded, size: 40, color: Colors.white.withOpacity(0.6))),

          // ============================================================
          // --- KONTEN UTAMA ---
          // ============================================================
          SafeArea(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: pinkCeria));
              }
              
              if (controller.assessmentList.isEmpty) {
                return _buildEmptyState();
              }

              double maxXVal = (controller.assessmentList.length - 1).toDouble();
              if (maxXVal < 1) maxXVal = 1.0;

              return Column(
                children: [
                  // --- GRAFIK TREN ---
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(30), 
                      border: Border.all(color: biruAwan.withOpacity(0.3), width: 3),
                      boxShadow: [BoxShadow(color: biruAwan.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8))]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: pinkCeria.withOpacity(0.2), shape: BoxShape.circle),
                              child: Icon(Icons.show_chart_rounded, color: pinkCeria, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text("Grafik Capaian", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: teksGelap)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: LineChart(
                            LineChartData(
                              minY: 0.5, maxY: 4.5, minX: 0, maxX: maxXVal,
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true, reservedSize: 40, interval: 1, 
                                    getTitlesWidget: (v, m) {
                                      if (v == 1.0) return const Text('BB', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.redAccent));
                                      if (v == 2.0) return const Text('MB', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.orange));
                                      if (v == 3.0) return Text('BSH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: biruAwan));
                                      if (v == 4.0) return const Text('BSB', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.green));
                                      return const Text('');
                                    }
                                  )
                                ),
                                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(
                                show: true, drawVerticalLine: false, 
                                getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 2, dashArray: [5, 5])
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: controller.assessmentList.reversed.toList().asMap().entries.map((e) {
                                    return FlSpot(e.key.toDouble(), controller.getChartValue(e.value['score']));
                                  }).toList(),
                                  isCurved: true, 
                                  gradient: LinearGradient(colors: [biruAwan, pinkCeria]), // Gradasi pada garis grafik
                                  barWidth: 5, 
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true, 
                                    getDotPainter: (spot, percent, barData, index) {
                                      return FlDotCirclePainter(radius: 5, color: Colors.white, strokeWidth: 3, strokeColor: pinkCeria);
                                    }
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true, 
                                    gradient: LinearGradient(colors: [biruAwan.withOpacity(0.2), pinkCeria.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // --- KETERANGAN SKALA ---
                  _buildLegendBox(),
                  
                  const SizedBox(height: 10),

                  // --- LIST RIWAYAT ---
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.assessmentList.length,
                      itemBuilder: (ctx, i) {
                        var item = controller.assessmentList[i];
                        return _buildHistoryCard(item);
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // WIDGET KOMPONEN
  // ==============================================================

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    String activity = item['activity']?.toString() ?? "Kegiatan Observasi";
    String score = item['score']?.toString() ?? "-";
    String notes = item['notes']?.toString() ?? "Tidak ada catatan.";
    String dateStr = item['date'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(item['date'].toString())) : "-";

    // Menentukan warna berdasarkan skor
    Color scoreColor = biruAwan;
    IconData scoreIcon = Icons.star_rounded;
    String scoreUpper = score.toUpperCase();
    
    if (scoreUpper.contains("BSB")) { scoreColor = Colors.green.shade400; scoreIcon = Icons.workspace_premium_rounded; }
    else if (scoreUpper.contains("BSH")) { scoreColor = biruAwan; scoreIcon = Icons.thumb_up_alt_rounded; }
    else if (scoreUpper.contains("MB")) { scoreColor = orenJeruk; scoreIcon = Icons.trending_up_rounded; }
    else if (scoreUpper.contains("BB")) { scoreColor = Colors.redAccent; scoreIcon = Icons.local_florist_rounded; }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: scoreColor.withOpacity(0.4), width: 2),
        boxShadow: [BoxShadow(color: scoreColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pita Warna di Kiri
              Container(width: 12, color: scoreColor),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: bgBase, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_month_rounded, size: 12, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(dateStr, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: scoreColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                Icon(scoreIcon, size: 14, color: scoreColor),
                                const SizedBox(width: 4),
                                Text(score, style: TextStyle(fontWeight: FontWeight.w900, color: scoreColor, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(activity, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: teksGelap)),
                      const SizedBox(height: 6),
                      Text('"$notes"', style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontStyle: FontStyle.italic, height: 1.4)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_rounded, size: 18, color: orenJeruk),
              const SizedBox(width: 6),
              Text("Panduan Singkatan:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: teksGelap)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12, runSpacing: 10,
            children: [
              _legendItem("BB", "Belum Berkembang", Colors.redAccent),
              _legendItem("MB", "Mulai Berkembang", orenJeruk),
              _legendItem("BSH", "Berkembang Sesuai Harapan", biruAwan),
              _legendItem("BSB", "Berkembang Sangat Baik", Colors.green.shade400),
            ],
          )
        ],
      ),
    );
  }

  Widget _legendItem(String code, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2))]),
          child: Text(code, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: teksGelap.withOpacity(0.8))),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: pinkCeria.withOpacity(0.2), blurRadius: 20)]),
            child: Icon(Icons.auto_awesome_mosaic_rounded, size: 60, color: pinkCeria),
          ),
          const SizedBox(height: 20),
          Text("Belum ada riwayat jurnal 📝", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: teksGelap)),
          const SizedBox(height: 8),
          Text("Observasi yang dicatat oleh guru\nakan muncul di sini.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600, height: 1.5)),
        ],
      )
    );
  }
}