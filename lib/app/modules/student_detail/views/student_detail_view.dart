import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart'; 
import '../controllers/student_detail_controller.dart';

class StudentDetailView extends GetView<StudentDetailController> {
  const StudentDetailView({super.key});

  // --- PALET WARNA CERIA ---
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
          // ============================================================
          // --- BACKGROUND BARU: POLA BALON & AWAN ---
          // ============================================================
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

          // ============================================================
          // --- KONTEN UTAMA ---
          // ============================================================
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

          // --- TOMBOL TAMBAH MELAYANG ---
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

  // ==============================================================
  // WIDGET BARU UNTUK BACKGROUND BALON
  // ==============================================================
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

  // ==============================================================
  // WIDGET-WIDGET KOMPONEN
  // ==============================================================

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
                const SizedBox(height: 8), 
                Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), 
                  decoration: BoxDecoration(
                    color: color, 
                    borderRadius: BorderRadius.circular(16)
                  ), 
                  child: Text(
                    controller.currentStatus.value, 
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)
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
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: teksGelap)),
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

  Widget _buildSingleProgressRow({required String label, required double percent, required double totalScore, required Color color}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: teksGelap), overflow: TextOverflow.ellipsis)), 
            Row(
              children: [
                Text("${totalScore.toInt()} Poin", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color)), 
                const SizedBox(width: 6), 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text("${(percent * 100).toInt()}%", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color))
                )
              ]
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

  Widget _buildHistoryItem(Map<String, dynamic> item, BuildContext context) {
    bool isHalus = item['type'] == 'Halus';
    Color typeColor = isHalus ? Colors.purple.shade400 : orenJeruk;
    double score = (item['score'] ?? 0).toDouble();

    return Container(
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
                const SizedBox(height: 6),
                Text("${controller.formatDate(item['date'])} • ${item['notes'] ?? ''}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500), maxLines: 2, overflow: TextOverflow.ellipsis),
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
              InkWell(
                onTap: () => _showAssessmentDialog(context, isEdit: true, oldData: item), 
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), 
                  decoration: BoxDecoration(color: bgBase, borderRadius: BorderRadius.circular(10)), 
                  child: Row(
                    children: [
                      Icon(Icons.edit_rounded, size: 12, color: orenJeruk), 
                      const SizedBox(width: 4), 
                      Text("Edit", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: orenJeruk))
                    ]
                  )
                )
              ),
            ]
          ),
        ]
      ),
    );
  }

  Widget _buildRecommendationItem(Map<String, dynamic> item) {
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgBase, borderRadius: BorderRadius.circular(16)),
            child: Text(item['desc'] ?? "-", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: teksGelap, height: 1.5)),
          )
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

  // ==============================================================
  // DIALOGS & AUTO-FILL LOGIC (DENGAN RENTANG NILAI BARU)
  // ==============================================================

  void _showAssessmentDialog(BuildContext context, {required bool isEdit, Map<String, dynamic>? oldData}) {
    RxString localActivity = "".obs;

    // --- FUNGSI PINTAR: GENERATOR CATATAN OBSERVASI GURU PAUD ---
    void generateAutoNote() {
      String act = controller.activityNameC.text;
      if (act.isEmpty) {
        controller.notesC.clear();
        return; 
      }

      String cleanAct = act.replaceAll(RegExp(r'[^\w\s]'), '').trim().toLowerCase();
      double score = controller.inputScore.value;
      int scoreInt = score.toInt();
      
      int variasi = scoreInt % 3; 

      String autoNote = "";

      // 76 - 100 : BSB (Berkembang Sangat Baik)
      if (scoreInt >= 76) {
        if (variasi == 0) {
          autoNote = "Alhamdulillah, capaian motorik Ananda Berkembang Sangat Baik (BSB). Ananda sudah sangat mandiri dan konsisten saat kegiatan $cleanAct. 🌟";
        } else if (variasi == 1) {
          autoNote = "Masya Allah, Ananda Berkembang Sangat Baik (BSB) dalam aktivitas $cleanAct. Kelincahan dan fokusnya patut diapresiasi. 🎉";
        } else {
          autoNote = "Ananda menunjukkan kemandirian yang luar biasa. Keterampilan $cleanAct Ananda Berkembang Sangat Baik (BSB). 🚀";
        }
      } 
      // 51 - 75 : BSH (Berkembang Sesuai Harapan)
      else if (scoreInt >= 51) {
        if (variasi == 0) {
          autoNote = "Ananda Berkembang Sesuai Harapan (BSH) saat $cleanAct. Ananda sudah bisa melakukan tugasnya dengan instruksi minimal dari guru. 👍";
        } else if (variasi == 1) {
          autoNote = "Perkembangan yang bagus! Ananda Berkembang Sesuai Harapan (BSH) dalam bermain $cleanAct, rasa percaya dirinya mulai terlihat jelas. ✨";
        } else {
          autoNote = "Kemampuan Ananda Berkembang Sesuai Harapan (BSH). Keterampilan $cleanAct-nya sudah baik, tinggal dibiasakan agar lebih optimal. 😊";
        }
      } 
      // 26 - 50 : MB (Mulai Berkembang)
      else if (scoreInt >= 26) {
        if (variasi == 0) {
          autoNote = "Capaian Ananda Mulai Berkembang (MB). Ananda tampak antusias dengan $cleanAct, namun masih membutuhkan contoh dan arahan perlahan. 💪";
        } else if (variasi == 1) {
          autoNote = "Ananda Mulai Berkembang (MB) dalam keberaniannya mencoba kegiatan $cleanAct. Yuk, kita beri lebih banyak kesempatan berlatih! 🎈";
        } else {
          autoNote = "Ada progres positif! Kemampuan Ananda Mulai Berkembang (MB) pada aktivitas $cleanAct. Perlu stimulasi rutin agar lebih seimbang. 🌱";
        }
      } 
      // 0 - 25 : BB (Belum Berkembang)
      else {
        if (variasi == 0) {
          autoNote = "Kemampuan Ananda Belum Berkembang (BB) pada aktivitas $cleanAct. Membutuhkan pendekatan personal, stimulasi aktif, dan kesabaran ekstra. 🤝";
        } else if (variasi == 1) {
          autoNote = "Ananda Belum Berkembang (BB) optimal untuk $cleanAct. Mari kita berikan contoh secara perlahan dan dampingi terus dengan penuh kasih sayang. ❤️";
        } else {
          autoNote = "Fase pengenalan. Ananda Belum Berkembang (BB) dalam $cleanAct. Dukungan penuh dan pujian atas usahanya akan sangat membantu Ananda. 🌻";
        }
      }

      controller.notesC.text = autoNote;
    }

    if (isEdit && oldData != null) {
      controller.activityNameC.text = oldData['activity'] ?? "";
      controller.notesC.text = oldData['notes'] ?? "";
      controller.inputScore.value = (oldData['score'] ?? 75.0).toDouble();
      controller.selectedMotorikType.value = oldData['type'] ?? "Halus";
      localActivity.value = oldData['activity'] ?? "";
    } else {
      controller.activityNameC.clear();
      controller.notesC.clear();
      controller.inputScore.value = 75.0; // Nilai default jatuh di BSH
      localActivity.value = "";
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
                const SizedBox(height: 24),

                const Text("Pilih Ranah Perkembangan:", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                const SizedBox(height: 12),
                
                Obx(() => Row(
                  children: [
                    Expanded(child: _buildSelectableChip("Motorik Halus", controller.selectedMotorikType.value == "Halus", Colors.purple.shade400, onTap: () {
                      controller.selectedMotorikType.value = "Halus";
                      localActivity.value = "";
                      controller.activityNameC.clear();
                      controller.notesC.clear(); 
                    })), 
                    const SizedBox(width: 12),
                    Expanded(child: _buildSelectableChip("Motorik Kasar", controller.selectedMotorikType.value == "Kasar", orenJeruk, onTap: () {
                      controller.selectedMotorikType.value = "Kasar";
                      localActivity.value = "";
                      controller.activityNameC.clear();
                      controller.notesC.clear();
                    })),
                  ]
                )),
                const SizedBox(height: 20),
                
                const Text("Pilih Kegiatan Stimulasi: 🎯", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                const SizedBox(height: 12),
                
                Obx(() {
                  String currentType = controller.selectedMotorikType.value;
                  List<String> currentActivities = currentType == "Halus" ? halusList : (currentType == "Kasar" ? kasarList : []);

                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: currentActivities.map((act) {
                      bool isSelected = localActivity.value == act;
                      return GestureDetector(
                        onTap: () {
                          localActivity.value = act;
                          controller.activityNameC.text = act; 
                          generateAutoNote(); 
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                  children: [
                    const Text("Skala Penilaian: ⭐", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                    Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: localActivity.value.isEmpty ? Colors.grey.shade300 : biruAwan, 
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Text("${controller.inputScore.value.toInt()}", style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16))
                    )),
                  ]
                ),
                const SizedBox(height: 8),
                
                // --- SLIDER NILAI YANG TERKUNCI ---
                Obx(() {
                  bool isActivitySelected = localActivity.value.isNotEmpty;
                  
                  return Column(
                    children: [
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
                          child: Text(
                            "👆 Silakan pilih jenis kegiatan di atas dahulu ya Bunda/Yanda!", 
                            style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w900)
                          ),
                        ),
                    ],
                  );
                }),
                
                Obx(() {
                  bool isActivitySelected = localActivity.value.isNotEmpty;
                  String scaleLabel = _getPAUDScaleLabel(controller.inputScore.value);
                  return Center(
                    child: Text(
                      isActivitySelected ? scaleLabel : "-", 
                      style: TextStyle(fontWeight: FontWeight.w900, color: isActivitySelected ? biruAwan : Colors.grey)
                    )
                  );
                }),

                // ==========================================================
                // KOTAK PANDUAN RENTANG NILAI
                // ==========================================================
                const SizedBox(height: 16),
                _buildScoreLegend(),
                // ==========================================================

                const SizedBox(height: 8),
                const Text("Deskripsi Anekdot Guru 📝", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.notesC,
                  maxLines: 4,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.4),
                  readOnly: localActivity.value.isEmpty, 
                  decoration: InputDecoration(
                    hintText: "Pilih kegiatan dan geser nilai untuk memunculkan narasi otomatis...", 
                    filled: true, fillColor: bgBase, 
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none)
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: Obx(() => ElevatedButton(
                    onPressed: (controller.isLoading.value || localActivity.value.isEmpty) ? null : () {
                      if(isEdit) {
                        controller.updateAssessment(oldData!); 
                      } else {
                        controller.prosesAnalisisAI();
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

  // Helper UI untuk menampilkan legend nilai
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

  // Logika pembagian rentang skala PAUD
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

  // ==============================================================
  // REVISI DOSEN PENGUJI: ANALISIS PER KOMPONEN MOTORIK
  // ==============================================================
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: biruAwan.withOpacity(0.2), shape: BoxShape.circle),
                  child: Icon(Icons.auto_awesome_rounded, color: biruAwan, size: 40),
                )
              ),
              const SizedBox(height: 16),
              Center(child: Text("Kesimpulan Observasi ✨", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: teksGelap))),
              const SizedBox(height: 24),
              
              const Text("Analisis Per Komponen:", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
              const SizedBox(height: 8),
              
              // KOTAK ANALISIS MOTORIK HALUS
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50, 
                  borderRadius: BorderRadius.circular(16), 
                  border: Border.all(color: Colors.purple.shade200)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("✍️ Motorik Halus (${(fineAvg * 100).toInt()}%)", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.purple.shade700)),
                    const SizedBox(height: 4),
                    Text(_analyzeFineMotor(fineAvg), style: TextStyle(fontSize: 13, color: teksGelap, height: 1.4)),
                  ]
                )
              ),
              const SizedBox(height: 10),

              // KOTAK ANALISIS MOTORIK KASAR
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: orenJeruk.withOpacity(0.1), 
                  borderRadius: BorderRadius.circular(16), 
                  border: Border.all(color: orenJeruk.withOpacity(0.5))
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("🏃 Motorik Kasar (${(grossAvg * 100).toInt()}%)", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.orange.shade800)),
                    const SizedBox(height: 4),
                    Text(_analyzeGrossMotor(grossAvg), style: TextStyle(fontSize: 13, color: teksGelap, height: 1.4)),
                  ]
                )
              ),

              const SizedBox(height: 20),
              
              const Text("Status Skala Capaian 🎯", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: statusColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))]
                ),
                child: Text(status, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white), textAlign: TextAlign.center),
              ),

              const SizedBox(height: 32),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        side: const BorderSide(color: Colors.grey, width: 2)
                      ),
                      child: const Text("Tutup", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 15)),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        elevation: 5
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
    );
  }

  // --- LOGIC HELPER NARASI INDIVIDUAL MOTORIK ---

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