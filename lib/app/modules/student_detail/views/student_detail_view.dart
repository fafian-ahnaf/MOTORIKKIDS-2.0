import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart'; 
import '../controllers/student_detail_controller.dart';

class StudentDetailView extends GetView<StudentDetailController> {
  const StudentDetailView({super.key});

  final Color bgBase = const Color(0xFFFFF8E7); 
  final Color pinkCeria = const Color(0xFFFF7E95); 
  final Color biruAwan = const Color(0xFF4FC3F7); 
  final Color orenJeruk = const Color(0xFFFFB74D);
  final Color teksGelap = const Color(0xFF4A4A4A);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String name = args['name'] ?? "Tanpa Nama";
    final String age = args['age'] ?? "5 Tahun";
    final Color color = args['color'] ?? biruAwan; 

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: bgBase,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: Text(
          "Profil Ananda 🎒", 
          style: TextStyle(color: teksGelap, fontWeight: FontWeight.w900, fontSize: 20)
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white, 
              shape: BoxShape.circle, 
              border: Border.all(color: pinkCeria, width: 2),
              boxShadow: [BoxShadow(color: pinkCeria.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.black87),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      
      body: Stack(
        children: [
          Container(color: bgBase),

          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [pinkCeria.withOpacity(0.2), pinkCeria.withOpacity(0.0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          _buildBalloonBackgroundPattern(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 120), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(name, color),

                  const SizedBox(height: 20),
                  
                  Row(
                    children: [
                      Expanded(child: _buildDetailCard(Icons.cake_rounded, orenJeruk, "Usia Ananda 🎂", age)),
                      const SizedBox(width: 16),
                      Expanded(child: Obx(() => _buildDetailCard(Icons.verified_rounded, color, "Status Capaian 📈", controller.currentStatus.value))),
                    ],
                  ),

                  const SizedBox(height: 30),
                  Text("Laporan Observasi Motorik 🧩", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: teksGelap)),
                  const SizedBox(height: 16),

                  Obx(() => _buildCombinedMotorikCard(
                    context: context,
                    age: age,
                    fineAvg: controller.fineMotorScore.value,
                    fineSum: controller.fineMotorSum.value,
                    grossAvg: controller.grossMotorScore.value,
                    grossSum: controller.grossMotorSum.value,
                  )),
                  
                  const SizedBox(height: 30),
                  
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: biruAwan.withOpacity(0.3), width: 2),
                    ),
                    child: Obx(() => Row(
                      children: [
                        _buildTabButton("Catatan Anekdot 📝", 0), 
                        _buildTabButton("Saran Stimulasi 💡", 1),
                      ],
                    )),
                  ),
                  const SizedBox(height: 16),

                  Obx(() {
                    if (controller.selectedTab.value == 0) {
                      if (controller.assessmentHistory.isEmpty) {
                        return _buildEmptyState("Belum ada catatan observasi...");
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.assessmentHistory.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          var item = controller.assessmentHistory[index];
                          return _buildHistoryItem(item, context);
                        },
                      );
                    } else {
                      if (controller.recommendationHistory.isEmpty) {
                        return _buildEmptyState("Belum ada saran stimulasi...");
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.recommendationHistory.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          var item = controller.recommendationHistory[index];
                          return _buildRecommendationItem(item);
                        },
                      );
                    }
                  }),
                ],
              ),
            ),
          ),

          Positioned(
            left: 24, right: 24, bottom: 24,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: pinkCeria.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  onPressed: () => _showAssessmentDialog(context, isEdit: false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pinkCeria,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_reaction_rounded, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text("Input Jurnal Ananda!", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalloonBackgroundPattern() {
    return Stack(
      children: [
        Positioned(top: 80, left: 40, child: Icon(Icons.circle, color: pinkCeria.withOpacity(0.15), size: 40)),
        Positioned(top: 150, right: 30, child: Icon(Icons.circle, color: biruAwan.withOpacity(0.2), size: 60)),
        Positioned(top: 280, left: -10, child: Icon(Icons.circle, color: orenJeruk.withOpacity(0.15), size: 80)),
        Positioned(top: 400, right: 50, child: Icon(Icons.circle, color: pinkCeria.withOpacity(0.1), size: 50)),
        Positioned(bottom: 180, left: 70, child: Icon(Icons.circle, color: biruAwan.withOpacity(0.15), size: 70)),
        Positioned(bottom: 50, right: -20, child: Icon(Icons.circle, color: orenJeruk.withOpacity(0.2), size: 90)),
        Positioned(bottom: 300, right: 100, child: Icon(Icons.circle, color: pinkCeria.withOpacity(0.1), size: 30)),
        Positioned(top: 120, right: 20, child: Icon(Icons.cloud_rounded, color: biruAwan.withOpacity(0.35), size: 50)),
        Positioned(top: 250, left: 15, child: Icon(Icons.cloud_rounded, color: biruAwan.withOpacity(0.25), size: 40)),
        Positioned(bottom: 100, left: -30, child: Icon(Icons.cloud_rounded, color: biruAwan.withOpacity(0.2), size: 80)),
      ],
    );
  }

  Widget _buildProfileCard(String name, Color color) {
    return Container(
      padding: const EdgeInsets.all(20), 
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(30), 
        border: Border.all(color: color.withOpacity(0.4), width: 4), 
        boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8))]
      ), 
      child: Row(
        children: [
          Container(
            width: 80, height: 80, 
            decoration: BoxDecoration(
              color: color.withOpacity(0.2), 
              shape: BoxShape.circle,
            ), 
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : "?", 
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: color)
              )
            )
          ), 
          const SizedBox(width: 20), 
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(
                  name, 
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: teksGelap), 
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis
                ), 
                const SizedBox(height: 10), 
                Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), 
                  decoration: BoxDecoration(
                    color: color, 
                    borderRadius: BorderRadius.circular(14)
                  ), 
                  child: Text(
                    controller.currentStatus.value, 
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                ))
              ]
            )
          )
        ]
      )
    );
  }

  Widget _buildDetailCard(IconData icon, Color color, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16), 
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: color.withOpacity(0.2), width: 3),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]
      ), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 26)
          ), 
          const SizedBox(height: 12), 
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: teksGelap.withOpacity(0.6))), 
          const SizedBox(height: 6),
          Text(
            value, 
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: teksGelap, height: 1.25),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )
        ]
      )
    );
  }

  Widget _buildCombinedMotorikCard({
    required BuildContext context, required String age, required double fineAvg, required double fineSum, required double grossAvg, required double grossSum
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: orenJeruk.withOpacity(0.4), width: 3),
        boxShadow: [BoxShadow(color: orenJeruk.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: orenJeruk.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(Icons.rocket_launch_rounded, color: orenJeruk, size: 26),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text("Capaian Perkembangan 🚀", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.black87)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSingleProgressRow(
            label: "Motorik Halus ✍️",
            percent: fineAvg,
            totalScore: fineSum,
            color: Colors.purple.shade400,
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1, thickness: 2, color: Color(0xFFF0F0F0)),
          ),

          _buildSingleProgressRow(
            label: "Motorik Kasar 🏃",
            percent: grossAvg,
            totalScore: grossSum,
            color: orenJeruk,
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: OutlinedButton.icon(
              onPressed: () => _showAnalysisResultDialog(context, age, fineAvg, grossAvg),
              icon: Icon(Icons.auto_awesome, size: 22, color: biruAwan),
              label: Text("Analisa Perkembangan ✨", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: biruAwan)),
              style: OutlinedButton.styleFrom(
                backgroundColor: biruAwan.withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                side: BorderSide(color: biruAwan, width: 3),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSingleProgressRow({
    required String label, 
    required double percent, 
    required double totalScore, 
    required Color color
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            Expanded(
              child: Text(
                label, 
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: teksGelap), 
                overflow: TextOverflow.ellipsis
              ),
            ), 
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15), 
                borderRadius: BorderRadius.circular(10)
              ),
              child: Text(
                "${(percent * 100).toInt()}%", 
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color)
              ),
            )
          ]
        ), 
        const SizedBox(height: 12), 
        ClipRRect(
          borderRadius: BorderRadius.circular(12), 
          child: LinearProgressIndicator(
            value: percent, 
            minHeight: 14, 
            backgroundColor: color.withOpacity(0.15), 
            valueColor: AlwaysStoppedAnimation<Color>(color)
          )
        )
      ]
    );
  }

  Widget _buildTabButton(String label, int index) {
    bool isActive = controller.selectedTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectedTab.value = index,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? biruAwan : Colors.transparent, 
            borderRadius: BorderRadius.circular(16), 
            boxShadow: isActive ? [BoxShadow(color: biruAwan.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))] : []
          ),
          child: Text(
            label, 
            textAlign: TextAlign.center, 
            style: TextStyle(
              fontWeight: FontWeight.w900, 
              fontSize: 14, 
              color: isActive ? Colors.white : teksGelap.withOpacity(0.5)
            )
          ),
        ),
      ),
    );
  }

  Widget _buildModeTabButton(String label, bool isActive, {required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? biruAwan : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive ? [BoxShadow(color: biruAwan.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))] : []
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 13,
            color: isActive ? Colors.white : teksGelap.withOpacity(0.6)
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item, BuildContext context) {
    String typeStr = (item['type'] ?? '').toString().toLowerCase();
    bool isHalus = typeStr.contains('halus');
    Color typeColor = isHalus ? Colors.purple.shade400 : orenJeruk;
    double score = (item['score'] ?? 0).toDouble();

    // =========================================================================
    // AUTO-FALLBACK DECODER (MENCEGAH TULISAN "BELUM DINILAI" MUNCUL DI UI)
    // =========================================================================
    String rawStatus = item['status'] ?? "";
    String displayStatus = rawStatus;
    
    if (rawStatus.isEmpty || 
        rawStatus.toLowerCase() == "belum dinilai" || 
        rawStatus == "-") {
      if (score >= 76) {
        displayStatus = "Berkembang Sangat Baik (BSB)";
      } else if (score >= 51) {
        displayStatus = "Berkembang Sesuai Harapan (BSH)";
      } else if (score >= 26) {
        displayStatus = "Mulai Berkembang (MB)";
      } else {
        displayStatus = "Belum Berkembang (BB)";
      }
    }

    return Dismissible(
      key: Key(item['id'] ?? item.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(
          Icons.delete_forever_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
      confirmDismiss: (direction) async {
        return await Get.defaultDialog<bool>(
          title: "Hapus Catatan?",
          titleStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          middleText: "Catatan observasi ini akan dihapus permanen.",
          textCancel: "Batal",
          textConfirm: "Hapus",
          confirmTextColor: Colors.white,
          buttonColor: Colors.red.shade400,
          onConfirm: () => Get.back(result: true),
          onCancel: () => Get.back(result: false),
        );
      },
      onDismissed: (direction) {
        controller.deleteAssessment(item);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(24), 
          border: Border.all(color: typeColor.withOpacity(0.3), width: 3),
          boxShadow: [BoxShadow(color: typeColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12), 
              decoration: BoxDecoration(color: typeColor.withOpacity(0.2), shape: BoxShape.circle), 
              child: Icon(isHalus ? Icons.edit_rounded : Icons.directions_run_rounded, color: typeColor, size: 28)
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text(item['activity'] ?? "-", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: teksGelap)),
                  const SizedBox(height: 4),
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      displayStatus, 
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: typeColor),
                    ),
                  ),
                  Text(
                    "${controller.formatDate(item['date'] ?? '')} • ${item['notes'] ?? ''}", 
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500), 
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis
                  ),
                ]
              )
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end, 
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: typeColor, borderRadius: BorderRadius.circular(12)),
                  child: Text("${score.toInt()}", style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16))
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => _showAssessmentDialog(context, isEdit: true, oldData: item), 
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), 
                        decoration: BoxDecoration(color: bgBase, borderRadius: BorderRadius.circular(8)), 
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, size: 14, color: orenJeruk), 
                            const SizedBox(width: 4), 
                            Text("Edit", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: orenJeruk))
                          ]
                        )
                      )
                    ),
                    const SizedBox(width: 6),

                    InkWell(
                      onTap: () {
                        Get.defaultDialog(
                          title: "Hapus Catatan?",
                          titleStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                          middleText: "Catatan ini akan dihapus permanen.",
                          radius: 16,
                          textCancel: "Batal",
                          textConfirm: "Hapus",
                          confirmTextColor: Colors.white,
                          buttonColor: Colors.red.shade400,
                          onConfirm: () {
                            Get.back();
                            controller.deleteAssessment(item);
                          },
                        );
                      }, 
                      child: Container(
                        padding: const EdgeInsets.all(6), 
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)), 
                        child: Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red.shade400),
                      ),
                    ),
                  ],
                ),
              ]
            ),
          ]
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(Map<String, dynamic> item) {
    bool isDone = item['is_done'] ?? false;
    String feedback = item['parent_feedback'] ?? "";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24), 
        boxShadow: [BoxShadow(color: biruAwan.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5))], 
        border: Border.all(color: biruAwan.withOpacity(0.5), width: 3)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10), 
                decoration: BoxDecoration(color: biruAwan.withOpacity(0.2), shape: BoxShape.circle), 
                child: Icon(Icons.lightbulb_rounded, size: 24, color: biruAwan)
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(item['title'] ?? "Rekomendasi Bermain", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: teksGelap))
              ),
              Text(controller.formatDate(item['date'] ?? ""), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
            ]
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgBase, borderRadius: BorderRadius.circular(16)),
            child: Text(item['desc'] ?? "-", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: teksGelap, height: 1.5)),
          ),

          if (isDone && feedback.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("💬 Respon Bunda/Ayah:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.green.shade800)),
                  const SizedBox(height: 4),
                  Text('"$feedback"', style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, fontWeight: FontWeight.w700, color: Colors.green.shade900)),
                ],
              ),
            ),
          ],
        ]
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0), 
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 15)]),
              child: Icon(Icons.auto_stories_rounded, size: 50, color: Colors.grey.shade300)
            ), 
            const SizedBox(height: 16), 
            Text(text, style: TextStyle(fontWeight: FontWeight.w800, color: Colors.grey.shade400))
          ]
        )
      )
    );
  }

  void _showAssessmentDialog(BuildContext context, {required bool isEdit, Map<String, dynamic>? oldData}) {
    RxList<String> selectedActivities = <String>[].obs;

    void generateAutoNote() {
      if (selectedActivities.isEmpty) {
        controller.notesC.clear();
        return; 
      }

      double score = controller.inputScore.value;
      int scoreInt = score.toInt();
      String autoNote = "";

      if (selectedActivities.length > 1) {
        String cleanActivities = selectedActivities
            .map((e) => e.replaceAll(RegExp(r'[^\w\s]'), '').trim().toLowerCase())
            .join(" serta ");

        if (scoreInt >= 76) {
          autoNote = "Ananda sudah mampu melakukan aktivitas $cleanActivities dengan mandiri dan terampil, namun masih perlu sedikit dorongan untuk mempertahankan konsentrasi hingga selesai. 🌟";
        } else if (scoreInt >= 51) {
          autoNote = "Ananda sudah mampu mengikuti kegiatan $cleanActivities dengan baik, namun masih membutuhkan arahan guru pada bagian-bagian yang memerlukan ketelitian ekstra. 👍";
        } else {
          autoNote = "Ananda sudah mampu menunjukkan ketertarikan pada aktivitas $cleanActivities, namun masih membutuhkan pendampingan aktif dan contoh bertahap dari guru. 💪";
        }
      } 
      else {
        String act = selectedActivities.first;

        if (act.contains("Menyusun Balok")) {
          if (scoreInt >= 76) {
            autoNote = "Ananda sudah mampu membuat gedung dan menara dengan balok secara kokoh, namun masih membutuhkan sedikit arahan saat merancang bangunan yang lebih kompleks. 🧱";
          } else if (scoreInt >= 51) {
            autoNote = "Ananda sudah mampu membuat gedung dengan balok, namun masih membutuhkan sedikit bimbingan agar susunannya lebih seimbang dan tidak mudah roboh. 👍";
          } else {
            autoNote = "Ananda sudah mampu menumpuk 2 hingga 3 balok dasar, namun masih membutuhkan pendampingan guru untuk memahami konsep keseimbangan bangunan. 💪";
          }
        } 
        else if (act.contains("Mewarnai")) {
          if (scoreInt >= 76) {
            autoNote = "Ananda sudah mampu mewarnai gambar dengan warna padat dan rapi di dalam garis, namun masih perlu dorongan untuk mencoba kombinasi warna yang lebih beragam. 🎨";
          } else {
            autoNote = "Ananda sudah mampu memegang krayon dan mewarnai area gambar dengan antusias, namun masih membutuhkan bimbingan agar goresan warna tidak keluar garis batas. ✍️";
          }
        } 
        else if (act.contains("Menggunting")) {
          if (scoreInt >= 76) {
            autoNote = "Ananda sudah mampu memotong kertas mengikuti garis lurus dan lengkung dengan baik, namun masih perlu sedikit latihan pada sudut lipatan pola yang rumit. ✂️";
          } else {
            autoNote = "Ananda sudah mampu memegang gunting dan membuat potongan sederhana, namun masih memerlukan bantuan agar potongan tepat mengikuti garis lengkung. 📄";
          }
        } 
        else if (act.contains("Meronce")) {
          if (scoreInt >= 76) {
            autoNote = "Ananda sudah mampu memasukkan benang ke lubang manik-manik dengan fokus tinggi, namun masih perlu arahan saat menyusun pola warna bertingkat. 📿";
          } else {
            autoNote = "Ananda sudah mampu memasukkan manik-manik berukuran besar ke tali, namun masih membutuhkan kesabaran dan bimbingan saat meronce lubang kecil. 🧵";
          }
        }
        else if (act.contains("Melipat Kertas")) {
          if (scoreInt >= 76) {
            autoNote = "Ananda sudah mampu melipat kertas origami dasar dengan garis lipatan yang tegas, namun masih perlu bimbingan pada pola lipatan yang membutuhkan kesimetrisan tinggi. 📄";
          } else {
            autoNote = "Ananda sudah mampu melipat kertas menjadi dua bagian, namun masih memerlukan arahan agar ujung-ujung kertas saling bertemu simetris dan rapi. 📐";
          }
        }
        else if (act.contains("Menjiplak Huruf")) {
          if (scoreInt >= 76) {
            autoNote = "Ananda sudah mampu menjiplak huruf mengikuti garis putus-putus dengan stabil, namun masih perlu latihan mengontrol tekanan pensil agar tidak terlalu keras. ✍️";
          } else {
            autoNote = "Ananda sudah mampu memegang pensil dan menjiplak garis dasar, namun masih membutuhkan bimbingan agar goresan tidak melenceng dari pola putus-putus. 📝";
          }
        }
        else if (act.contains("Melompat")) {
          if (scoreInt >= 76) {
            autoNote = "Ananda sudah mampu melompat melewati rintangan dengan tolakan kaki yang kuat, namun masih perlu latihan mendarat dengan lebih seimbang dan tenang. 🦘";
          } else {
            autoNote = "Ananda sudah mampu melompat ke depan dengan dua kaki, namun masih ragu-ragu dan kurang seimbang saat mendarat melewati rintangan. 🏃";
          }
        }
        else if (act.contains("Berlari")) {
          if (scoreInt >= 76) {
            autoNote = "Ananda sudah mampu berlari zig-zag dengan lincah menghindari rintangan, namun masih perlu berlatih mengontrol kecepatan saat berbelok tajam. ⚡";
          } else {
            autoNote = "Ananda sudah mampu berlari lurus dengan aktif dan percaya diri, namun masih memerlukan bimbingan keseimbangan saat berbelok arah secara zig-zag. 🏃‍♂️";
          }
        }
        else if (act.contains("Menangkap Bola")) {
          if (scoreInt >= 76) {
            autoNote = "Ananda sudah mampu menangkap bola dari jarak dekat dengan kedua tangan secara sigap, namun masih perlu latihan refleks pada lemparan bola cepat. 🏀";
          } else {
            autoNote = "Ananda sudah mampu merespons arah datangnya bola, namun masih sering terlambat menutup kedua tangan saat menangkap bola. 👐";
          }
        }
        else if (act.contains("Papan Titian") || act.contains("Berjalan")) {
          if (scoreInt >= 76) {
            autoNote = "Ananda sudah mampu berjalan melintasi papan titian dengan keseimbangan tubuh yang baik, namun masih perlu berlatih menjaga pandangan mata ke depan. ⚖️";
          } else {
            autoNote = "Ananda sudah mampu melangkah di atas papan titian, namun masih membutuhkan pegangan tangan guru atau berjalan perlahan untuk menjaga keseimbangan. 🚶";
          }
        }
        else if (act.contains("Senam") || act.contains("Menari")) {
          if (scoreInt >= 76) {
            autoNote = "Ananda sudah mampu menirukan gerakan senam dan tarian dengan luwes, namun masih perlu berlatih menyelaraskan ketepatan gerak dengan tempo musik. 💃";
          } else {
            autoNote = "Ananda sudah mampu mengikuti gerakan senam dasar dengan ceria, namun masih memerlukan contoh guru untuk mengoordinasikan gerakan tangan dan kaki. 🎶";
          }
        }
        else if (act.contains("Memanjat")) {
          if (scoreInt >= 76) {
            autoNote = "Ananda sudah mampu menaiki anak tangga permainan secara mandiri dengan posisi kaki bergantian, namun masih perlu berhati-hati saat menuruni tangga. 🧗";
          } else {
            autoNote = "Ananda sudah mampu menaiki tangga permainan, namun masih bergantung pada pegangan yang kuat dan melangkah perlahan satu per satu. 🪜";
          }
        }
        else {
          String cleanAct = act.replaceAll(RegExp(r'[^\w\s]'), '').trim().toLowerCase();
          autoNote = "Ananda sudah mampu berpartisipasi aktif dalam kegiatan $cleanAct, namun masih membutuhkan pendampingan serta instruksi bertahap dari guru. 💪";
        }
      }

      controller.notesC.text = autoNote;
    }

    if (isEdit && oldData != null) {
      String actString = oldData['activity'] ?? "";
      controller.activityNameC.text = actString;
      controller.notesC.text = oldData['notes'] ?? "";
      controller.inputScore.value = (oldData['score'] ?? 75.0).toDouble();
      controller.selectedMotorikType.value = oldData['type'] ?? "Halus";
      
      if (actString.isNotEmpty) {
        selectedActivities.assignAll(actString.split(", ").map((e) => e.trim()).toList());
      } else {
        selectedActivities.clear();
      }
    } else {
      controller.activityNameC.clear();
      controller.notesC.clear();
      controller.inputScore.value = 75.0; 
      controller.inputMode.value = 'manual';
      controller.aiStatusResult.value = "";
      controller.isAiAnalyzed.value = false;
      selectedActivities.clear();
    }

    List<String> halusList = ["Mewarnai 🎨", "Menggunting ✂️", "Meronce 📿", "Menyusun Balok 🧱", "Melipat Kertas 📄", "Menjiplak Huruf ✍️"];
    List<String> kasarList = ["Berlari Zig-zag 🏃", "Melompat Rintangan 🦘", "Menangkap Bola 🏀", "Berjalan di Papan Titian ⚖️", "Senam/Menari 💃", "Memanjat Tangga 🧗"];

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
            border: Border.all(color: pinkCeria, width: 4)
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: isEdit ? orenJeruk.withOpacity(0.2) : pinkCeria.withOpacity(0.2), shape: BoxShape.circle),
                    child: Icon(isEdit ? Icons.edit_note_rounded : Icons.star_rounded, color: isEdit ? orenJeruk : pinkCeria, size: 40),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    isEdit ? "✏️ Edit Jurnal Observasi" : "🌟 Catat Observasi Ananda", 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: teksGelap)
                  )
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: bgBase,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: biruAwan.withOpacity(0.3)),
                  ),
                  child: Obx(() => Row(
                    children: [
                      Expanded(
                        child: _buildModeTabButton(
                          "🖐️ Input Manual", 
                          controller.inputMode.value == 'manual', 
                          onTap: () {
                            controller.inputMode.value = 'manual';
                            controller.isAiAnalyzed.value = false;
                            controller.aiStatusResult.value = "";
                            generateAutoNote();
                          }
                        ),
                      ),
                      Expanded(
                        child: _buildModeTabButton(
                          "🤖 Input Otomatis", 
                          controller.inputMode.value == 'otomatis', 
                          onTap: () {
                            controller.inputMode.value = 'otomatis';
                            controller.notesC.clear();
                            controller.isAiAnalyzed.value = false;
                            controller.aiStatusResult.value = "";
                          }
                        ),
                      ),
                    ],
                  )),
                ),
                const SizedBox(height: 20),

                const Text("Pilih Ranah Perkembangan:", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                const SizedBox(height: 12),
                
                Obx(() => Row(
                  children: [
                    Expanded(child: _buildSelectableChip("Motorik Halus", controller.selectedMotorikType.value == "Halus", Colors.purple.shade400, onTap: () {
                      controller.selectedMotorikType.value = "Halus";
                      selectedActivities.clear();
                      controller.activityNameC.clear();
                      controller.notesC.clear(); 
                    })), 
                    const SizedBox(width: 12),
                    Expanded(child: _buildSelectableChip("Motorik Kasar", controller.selectedMotorikType.value == "Kasar", orenJeruk, onTap: () {
                      controller.selectedMotorikType.value = "Kasar";
                      selectedActivities.clear();
                      controller.activityNameC.clear();
                      controller.notesC.clear();
                    })),
                  ]
                )),
                const SizedBox(height: 20),
                
                const Text("Pilih Kegiatan Stimulasi :", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                const SizedBox(height: 12),
                
                Obx(() {
                  String currentType = controller.selectedMotorikType.value;
                  List<String> currentActivities = currentType == "Halus" ? halusList : (currentType == "Kasar" ? kasarList : []);

                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: currentActivities.map((act) {
                      bool isSelected = selectedActivities.contains(act);
                      return GestureDetector(
                        onTap: () {
                          if (isSelected) {
                            selectedActivities.remove(act);
                          } else {
                            selectedActivities.add(act);
                          }
                          controller.activityNameC.text = selectedActivities.join(", ");
                          if (controller.inputMode.value == 'manual') {
                            generateAutoNote(); 
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? biruAwan : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isSelected ? biruAwan : biruAwan.withOpacity(0.3), width: 2),
                            boxShadow: isSelected ? [BoxShadow(color: biruAwan.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))] : []
                          ),
                          child: Text(
                            act,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: isSelected ? Colors.white : teksGelap
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
                
                const SizedBox(height: 24),

                Obx(() {
                  if (controller.inputMode.value == 'manual') {
                    bool isActivitySelected = selectedActivities.isNotEmpty;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                          children: [
                            const Text("Skala Penilaian: ⭐", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: selectedActivities.isEmpty ? Colors.grey.shade300 : biruAwan, 
                                borderRadius: BorderRadius.circular(12)
                              ),
                              child: Text("${controller.inputScore.value.toInt()}", style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16))
                            ),
                          ]
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: controller.inputScore.value, 
                          min: 0, max: 100, divisions: 20, 
                          activeColor: isActivitySelected ? biruAwan : Colors.grey.shade400, 
                          inactiveColor: isActivitySelected ? biruAwan.withOpacity(0.2) : Colors.grey.shade200, 
                          onChanged: isActivitySelected ? (val) {
                            controller.inputScore.value = val.roundToDouble(); 
                            generateAutoNote(); 
                          } : null,
                        ),
                        if (!isActivitySelected)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Center(
                              child: Text(
                                "👆 Silakan pilih kegiatan di atas untuk mengaktifkan skala!", 
                                style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w900)
                              ),
                            ),
                          ),
                        Center(
                          child: Text(
                            isActivitySelected ? _getPAUDScaleLabel(controller.inputScore.value) : "-", 
                            style: TextStyle(fontWeight: FontWeight.w900, color: isActivitySelected ? biruAwan : Colors.grey)
                          )
                        ),
                        const SizedBox(height: 16),
                        _buildScoreLegend(),
                        const SizedBox(height: 8),
                        const Text("Deskripsi Anekdot Guru (Otomatis) 📝", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: controller.notesC,
                          maxLines: 4,
                          readOnly: true, 
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.4),
                          decoration: InputDecoration(
                            hintText: "Narasi observasi otomatis terbentuk berdasarkan geseran skala...", 
                            filled: true, fillColor: bgBase, 
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none)
                          ),
                        ),
                      ],
                    );
                  } 
                  else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Deskripsi Anekdot Guru 📝", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: controller.notesC,
                          maxLines: 4,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.4),
                          decoration: InputDecoration(
                            hintText: "Ketik catatan observasi anak di sini...", 
                            filled: true, fillColor: bgBase, 
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none)
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text("Nilai Observasi", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                        const SizedBox(height: 8),

                        if (controller.isAiAnalyzed.value)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.green.shade400, width: 2),
                            ),
                            child: Column(
                              children: [
                                Text("Nilai & Status Perkembangan:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.green.shade800)),
                                const SizedBox(height: 4),
                                Text(
                                  "${controller.inputScore.value.toInt()} ⭐ - ${controller.aiStatusResult.value}",
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.green.shade900),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: () => controller.hitungNilaiAIOtomatis(langsungSimpan: false),
                                  icon: Icon(Icons.refresh_rounded, size: 16, color: Colors.green.shade800),
                                  label: Text("Hitung Ulang", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.green.shade800)),
                                )
                              ],
                            ),
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: (controller.isLoading.value || selectedActivities.isEmpty)
                                  ? null
                                  : () => controller.hitungNilaiAIOtomatis(langsungSimpan: false),
                              icon: Icon(Icons.auto_awesome_rounded, color: biruAwan),
                              label: Text("Hitung Nilai Observasi ✨", style: TextStyle(fontWeight: FontWeight.w900, color: biruAwan, fontSize: 14)),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: biruAwan, width: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                          ),
                      ],
                    );
                  }
                }),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: Obx(() => ElevatedButton(
                    onPressed: (controller.isLoading.value || selectedActivities.isEmpty) ? null : () {
                      if(isEdit) {
                        controller.updateAssessment(oldData!); 
                      } else {
                        if (controller.inputMode.value == 'manual' || controller.isAiAnalyzed.value) {
                          controller.simpanObservasiBaru();
                        } else {
                          controller.hitungNilaiAIOtomatis(langsungSimpan: true);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEdit ? orenJeruk : pinkCeria, 
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 5
                    ),
                    child: controller.isLoading.value 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : Text(isEdit ? "Update Observasi!" : "Simpan Observasi!", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                  )),
                ),
                const SizedBox(height: 8),
                Center(child: TextButton(onPressed: () => Get.back(), child: const Text("Batal", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w800)))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreLegend() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: biruAwan.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: biruAwan.withOpacity(0.2))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: biruAwan),
              const SizedBox(width: 6),
              Text("Panduan Skala Nilai:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: biruAwan)),
            ]
          ),
          const SizedBox(height: 8),
          _legendRow(Colors.redAccent, "0 - 25", "Belum Berkembang (BB)"),
          _legendRow(orenJeruk, "26 - 50", "Mulai Berkembang (MB)"),
          _legendRow(biruAwan, "51 - 75", "Berkembang Sesuai Harapan (BSH)"),
          _legendRow(Colors.green.shade400, "76 - 100", "Berkembang Sangat Baik (BSB)"),
        ],
      )
    );
  }

  Widget _legendRow(Color color, String range, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(range, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: teksGelap)),
          const SizedBox(width: 6),
          Expanded(child: Text("- $label", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: teksGelap))),
        ],
      )
    );
  }

  String _getPAUDScaleLabel(double score) {
    if (score >= 76) return "Berkembang Sangat Baik (BSB)";
    if (score >= 51) return "Berkembang Sesuai Harapan (BSH)";
    if (score >= 26) return "Mulai Berkembang (MB)";
    return "Belum Berkembang (BB)";
  }

  Widget _buildSelectableChip(String label, bool isSelected, Color color, {Function()? onTap}) {
    return GestureDetector(
      onTap: onTap, 
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200), 
        padding: const EdgeInsets.symmetric(vertical: 14), 
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white, 
          borderRadius: BorderRadius.circular(20), 
          border: Border.all(color: color, width: 2),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))] : []
        ), 
        child: Center(
          child: Text(
            label, 
            style: TextStyle(color: isSelected ? Colors.white : color, fontWeight: FontWeight.w900, fontSize: 13),
            textAlign: TextAlign.center,
          )
        )
      )
    );
  }

  void _showAnalysisResultDialog(BuildContext context, String age, double fineAvg, double grossAvg) {
    String status = controller.currentStatus.value;
    Color statusColor = _getStatusColor(status);

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
            border: Border.all(color: biruAwan, width: 4)
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: biruAwan.withOpacity(0.2), shape: BoxShape.circle),
                    child: Icon(Icons.analytics_rounded, color: biruAwan, size: 40),
                  )
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    "Analisis Capaian Per Komponen 📊", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: teksGelap),
                    textAlign: TextAlign.center,
                  )
                ),
                const SizedBox(height: 20),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50, 
                    borderRadius: BorderRadius.circular(18), 
                    border: Border.all(color: Colors.purple.shade200, width: 2)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("✍️ MOTORIK HALUS (${(fineAvg * 100).toInt()}%)", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.purple.shade800)),
                      const SizedBox(height: 10),
                      _buildDynamicActivityRows("halus"),
                    ]
                  )
                ),
                const SizedBox(height: 14),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: orenJeruk.withOpacity(0.12), 
                    borderRadius: BorderRadius.circular(18), 
                    border: Border.all(color: orenJeruk.withOpacity(0.6), width: 2)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("🏃 MOTORIK KASAR (${(grossAvg * 100).toInt()}%)", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: orangeColorSafe(orenJeruk))),
                      const SizedBox(height: 10),
                      _buildDynamicActivityRows("kasar"),
                    ]
                  )
                ),

                const SizedBox(height: 20),
                
                const Text("Status SDIDTK Ananda 🎯", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: statusColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                  ),
                  child: Text(status, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5, color: Colors.white), textAlign: TextAlign.center),
                ),

                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          side: const BorderSide(color: Colors.grey, width: 2)
                        ),
                        child: const Text("Tutup", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          Get.toNamed(
                            Routes.RECOMMENDATION, 
                            arguments: {
                              'studentId': controller.studentId, 
                              'age': age,
                              'fineScore': fineAvg,
                              'grossScore': grossAvg
                            }
                          ); 
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: biruAwan,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          elevation: 3
                        ),
                        child: const Text("Saran Stimulasi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
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

  Widget _buildDynamicActivityRows(String keyword) {
    List<Map<String, dynamic>> filteredList = controller.assessmentHistory.where((item) {
      String typeStr = (item['type'] ?? '').toString().toLowerCase();
      return typeStr.contains(keyword.toLowerCase());
    }).toList();

    if (filteredList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          "Belum ada catatan observasi untuk aspek ini.",
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
        ),
      );
    }

    Map<String, double> latestScores = {};
    for (var item in filteredList) {
      String rawAct = item['activity'] ?? "";
      double score = (item['score'] ?? 75.0).toDouble();

      List<String> acts = rawAct.split(",").map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      for (String a in acts) {
        String cleanKey = a.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
        if (cleanKey.isNotEmpty && !latestScores.containsKey(a)) {
          latestScores[a] = score;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: latestScores.entries.map((entry) {
        String activityName = entry.key;
        double score = entry.value;
        String analysisText = _getPedagogicAnalysis(activityName, score);
        return _buildItemAnalysisRow(activityName, analysisText);
      }).toList(),
    );
  }

  String _getPedagogicAnalysis(String actName, double score) {
    int scoreInt = score.toInt();
    if (actName.contains("Balok")) {
      return scoreInt >= 76 
          ? "Sudah mampu membuat gedung dengan balok secara kokoh dan seimbang."
          : "Sudah mampu membuat gedung dengan balok, namun masih perlu stabilitas susunan.";
    } else if (actName.contains("Mewarnai")) {
      return scoreInt >= 76 
          ? "Sudah mampu mewarnai gambar dengan rapi dan konsisten di dalam garis."
          : "Sudah mampu mewarnai area gambar, namun masih perlu kontrol batas garis agar lebih rapi.";
    } else if (actName.contains("Menggunting")) {
      return scoreInt >= 76 
          ? "Sudah mampu memotong kertas mengikuti garis lurus maupun lengkung dengan akurat."
          : "Sudah mampu memotong garis lurus, namun masih perlu pendampingan pada pola lengkung.";
    } else if (actName.contains("Meronce")) {
      return scoreInt >= 76 
          ? "Sudah mampu memasukkan manik-manik dan meronce pola warna bertingkat dengan fokus."
          : "Sudah mampu memasukkan manik-manik, namun masih perlu ketelitian pada lubang kecil.";
    } else if (actName.contains("Melipat")) {
      return scoreInt >= 76 
          ? "Sudah mampu melipat kertas dasar dengan lipatan yang tegas dan simetris."
          : "Sudah mampu melipat kertas dasar, namun masih perlu melatih kesimetrisan ujung lipatan.";
    } else if (actName.contains("Menjiplak")) {
      return scoreInt >= 76 
          ? "Sudah mampu menjiplak huruf putus-putus dengan kontrol pensil yang stabil."
          : "Sudah mampu menjiplak huruf putus-putus, namun masih perlu kontrol tekanan pensil.";
    } else if (actName.contains("Melompat")) {
      return scoreInt >= 76 
          ? "Sudah mampu melompat melewati rintangan dengan tolakan dan mendarat seimbang."
          : "Sudah mampu melompat ke depan, namun masih ragu-ragu saat mendarat melewati rintangan.";
    } else if (actName.contains("Berlari")) {
      return scoreInt >= 76 
          ? "Sudah mampu berlari zig-zag dengan lincah dan stabil menghindari rintangan."
          : "Sudah mampu berlari lincah, namun masih perlu latihan keseimbangan saat berbelok zig-zag.";
    } else if (actName.contains("Menangkap")) {
      return scoreInt >= 76 
          ? "Sudah mampu merespons arah bola dan menangkapnya dengan kedua tangan sigap."
          : "Sudah mampu merespons arah bola, namun masih sering terlambat menutup tangkapan.";
    } else if (actName.contains("Titian") || actName.contains("Berjalan")) {
      return scoreInt >= 76 
          ? "Sudah mampu melangkah di papan titian dengan keseimbangan tubuh yang konsisten."
          : "Sudah mampu melangkah di papan titian, namun masih butuh arahan kestabilan mata.";
    } else if (actName.contains("Senam") || actName.contains("Menari")) {
      return scoreInt >= 76 
          ? "Sudah mampu menirukan gerakan senam secara luwes sesuai irama musik."
          : "Sudah mampu menirukan gerakan senam, namun masih perlu penyesuaian tempo irama.";
    } else if (actName.contains("Memanjat")) {
      return scoreInt >= 76 
          ? "Sudah mampu menaiki anak tangga secara mandiri dengan kaki bergantian."
          : "Sudah mampu menaiki anak tangga secara mandiri, namun masih perlu kontrol saat turun.";
    } else {
      return scoreInt >= 76 
          ? "Sudah mampu mengikuti kegiatan $actName dengan mandiri dan capaian optimal."
          : "Sudah mampu mengikuti kegiatan $actName, namun masih membutuhkan bimbingan guru.";
    }
  }

  Widget _buildItemAnalysisRow(String activityName, String analysisText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: teksGelap, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 12, color: teksGelap, height: 1.4),
                children: [
                  TextSpan(text: "$activityName : ", style: const TextStyle(fontWeight: FontWeight.w900)),
                  TextSpan(text: analysisText, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color orangeColorSafe(Color c) => Colors.orange.shade800;

  String _analyzeFineMotor(double score) {
    if (score >= 0.76) return "Sangat terampil dan mandiri dalam aktivitas presisi (koordinasi mata dan tangan) seperti menggambar atau menggunting.";
    if (score >= 0.51) return "Kemampuan motorik halus berkembang baik dan sesuai harapan. Sudah bisa diarahkan untuk kegiatan detail.";
    if (score >= 0.26) return "Mulai menunjukkan minat pada aktivitas yang melibatkan jari-jemari, namun masih butuh banyak contoh dan arahan.";
    return "Masih membutuhkan stimulasi intensif dan kesabaran ekstra untuk melenturkan otot-otot jari serta tangannya.";
  }

  String _analyzeGrossMotor(double score) {
    if (score >= 0.76) return "Sangat lincah, seimbang, dan memiliki kontrol yang sangat baik atas gerakan fisik tubuh besarnya.";
    if (score >= 0.51) return "Keseimbangan dan kekuatan otot kaki/tangan berkembang sesuai tahap usianya.";
    if (score >= 0.26) return "Mulai berani melakukan aktivitas fisik bergerak, namun keseimbangan tubuhnya masih perlu dilatih.";
    return "Belum terlalu aktif bergerak dan membutuhkan banyak dorongan untuk melakukan aktivitas fisik dasar.";
  }

  Color _getStatusColor(String status) {
    if (status.contains("BSB") || status.contains("Sangat") || status.contains("Baik")) return Colors.green.shade400;
    if (status.contains("BSH") || status.contains("Harapan")) return biruAwan;
    if (status.contains("MB") || status.contains("Mulai") || status.contains("Stimulasi")) return orenJeruk;
    if (status.contains("BB") || status.contains("Belum") || status.contains("Pendampingan")) return Colors.redAccent;
    return biruAwan;
  }
}