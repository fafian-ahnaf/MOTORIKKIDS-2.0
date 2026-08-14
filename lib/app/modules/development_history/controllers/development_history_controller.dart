import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DevelopmentHistoryController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  late String studentId;
  var studentName = "Ananda".obs;
  var studentAge = "5 Tahun".obs;
  var currentStatus = "-".obs;

  var currentTeacherName = "Guru Kelas".obs;
  var currentTeacherNip = "-".obs;

  var assessmentHistory = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      studentId = args['studentId'] ?? args['id'] ?? "";
      studentName.value = args['studentName'] ?? args['name'] ?? "Ananda";
      studentAge.value = args['studentAge'] ?? args['age'] ?? "5 Tahun";
      currentStatus.value = args['status'] ?? "-";
    }

    if (studentId.isNotEmpty) {
      _resolveTeacherSignature();
      monitorStudentHistory();
    }
  }

  // ===========================================================================
  // PEMBERSIH TEKS PDF (MENGHAPUS EMOJI & SIMBOL AGAR TIDAK MUNCUL KOTAK SILANG)
  // ===========================================================================
  String cleanPdfText(String text) {
    if (text.isEmpty) return "-";
    // Menghapus karakter emoji, simbol grafis, dan karakter yang tidak didukung font PDF
    return text
        .replaceAll(RegExp(r'[^\u0020-\u007E\u00A0-\u00FF\n\r]'), '')
        .replaceAll(RegExp(r' \s+'), ' ')
        .trim();
  }

  // ===========================================================================
  // STRICT RESOLVER NAMA GURU
  // ===========================================================================
  Future<void> _resolveTeacherSignature() async {
    String foundName = "";
    String foundNip = "-";

    try {
      if (assessmentHistory.isNotEmpty) {
        for (var item in assessmentHistory) {
          String nameInLog = (item['teacher_name'] ?? item['nama_guru'] ?? item['pengamat'] ?? "").toString().trim();
          if (nameInLog.isNotEmpty && 
              nameInLog != "Guru Kelas" && 
              !nameInLog.toLowerCase().contains("ortu") &&
              !nameInLog.toLowerCase().contains("orang tua")) {
            foundName = nameInLog;
            break;
          }
        }
      }

      if (foundName.isEmpty) {
        var studentDoc = await firestore.collection('students').doc(studentId).get();
        if (studentDoc.exists && studentDoc.data() != null) {
          var sData = studentDoc.data()!;
          String nameInStudent = (sData['teacher_name'] ?? sData['nama_guru'] ?? sData['guru'] ?? sData['wali_kelas'] ?? "").toString().trim();
          if (nameInStudent.isNotEmpty && nameInStudent != "Guru Kelas") {
            foundName = nameInStudent;
          }

          String teacherId = (sData['teacher_id'] ?? sData['id_guru'] ?? sData['uid_guru'] ?? "").toString().trim();
          if (teacherId.isNotEmpty) {
            var teacherDoc = await firestore.collection('users').doc(teacherId).get();
            if (teacherDoc.exists && teacherDoc.data() != null) {
              var tData = teacherDoc.data()!;
              String dbName = (tData['name'] ?? tData['nama'] ?? tData['nama_lengkap'] ?? "").toString().trim();
              if (dbName.isNotEmpty) foundName = dbName;
              foundNip = (tData['nip'] ?? tData['id_pegawai'] ?? "-").toString().trim();
            }
          }
        }
      }

      if (foundName.isEmpty) {
        User? user = auth.currentUser;
        if (user != null) {
          var userDoc = await firestore.collection('users').doc(user.uid).get();
          if (userDoc.exists && userDoc.data() != null) {
            var uData = userDoc.data()!;
            String roleUser = (uData['role'] ?? '').toString().toLowerCase();
            bool isParent = roleUser == 'parent' || roleUser == 'ortu' || roleUser == 'orang_tua';

            if (!isParent) {
              String dbName = (uData['name'] ?? uData['nama'] ?? uData['nama_lengkap'] ?? user.displayName ?? "").toString().trim();
              if (dbName.isNotEmpty && dbName != "Guru Kelas") {
                foundName = dbName;
                foundNip = (uData['nip'] ?? uData['id_pegawai'] ?? "-").toString().trim();
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error resolve signature: $e");
    }

    currentTeacherName.value = foundName.isNotEmpty ? foundName : "Guru Kelas";
    currentTeacherNip.value = foundNip.isNotEmpty ? foundNip : "-";
  }

  void monitorStudentHistory() {
    firestore.collection('students').doc(studentId).snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        var data = snapshot.data()!;
        List<dynamic> rawHistory = data['riwayat'] ?? [];

        List<Map<String, dynamic>> history = rawHistory.map((e) {
          var map = Map<String, dynamic>.from(e);
          double score = (map['score'] ?? 0).toDouble();
          String rawStatus = (map['status'] ?? "").toString().trim();

          if (rawStatus.isEmpty || rawStatus == "-" || rawStatus.toLowerCase().contains("belum dinilai")) {
            map['status'] = _getPAUDScaleLabel(score);
          }

          String logTeacher = (map['teacher_name'] ?? "").toString().trim();
          if (logTeacher.isNotEmpty && 
              logTeacher != "Guru Kelas" && 
              !logTeacher.toLowerCase().contains("ortu") &&
              currentTeacherName.value == "Guru Kelas") {
            currentTeacherName.value = logTeacher;
          }

          return map;
        }).toList();

        history.sort((a, b) => (b['date'] ?? "").compareTo(a['date'] ?? ""));
        assessmentHistory.value = history;

        if (data['status'] != null) {
          currentStatus.value = data['status'];
        }
        if (data['name'] != null) {
          studentName.value = data['name'];
        }

        _resolveTeacherSignature();
      }
    }, onError: (e) {
      debugPrint("Error memantau riwayat: $e");
    });
  }

  // ===========================================================================
  // CETAK PDF: TEMA ANAK CERIA & BEBAS KOTAK SILANG
  // ===========================================================================
  Future<void> cetakLaporanPDF() async {
    if (assessmentHistory.isEmpty) {
      Get.snackbar(
        "Data Kosong",
        "Belum ada catatan observasi untuk dicetak.",
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      isLoading.value = true;
      await _resolveTeacherSignature();

      final pinkCeria = PdfColor.fromHex('#FF7E95');
      final biruAwan = PdfColor.fromHex('#4FC3F7');
      final kuningSoft = PdfColor.fromHex('#FFF8E7');
      final abuGelap = PdfColor.fromHex('#4A4A4A');

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          footer: (pw.Context context) => _buildFooterNotePDF(context, pinkCeria, biruAwan),
          build: (pw.Context context) {
            return [
              _buildHeaderPDF(pinkCeria, biruAwan, abuGelap),
              pw.SizedBox(height: 16),
              _buildStudentInfoCardPDF(pinkCeria, biruAwan, kuningSoft, abuGelap),
              pw.SizedBox(height: 22),
              
              pw.Row(
                children: [
                  pw.Container(width: 6, height: 18, color: pinkCeria),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    "JURNAL OBSERVASI & STIMULASI MOTORIK ANAK",
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: abuGelap),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),

              _buildHistoryTablePDF(pinkCeria, biruAwan, abuGelap),
              pw.SizedBox(height: 30),

              _buildSignatureSectionPDF(
                teacherName: cleanPdfText(currentTeacherName.value),
                nip: cleanPdfText(currentTeacherNip.value),
                pinkCeria: pinkCeria,
                abuGelap: abuGelap,
              ),
            ];
          },
        ),
      );

      String safeName = studentName.value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      String fileName = 'Laporan_Observasi_$safeName.pdf';

      isLoading.value = false;

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: fileName,
      );

    } catch (e) {
      isLoading.value = false;
      debugPrint("Error Cetak PDF: $e");
      Get.snackbar(
        "Gagal Membuka PDF ⚠️",
        "Terjadi kesalahan teknis: $e",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  pw.Widget _buildHeaderPDF(PdfColor pinkCeria, PdfColor biruAwan, PdfColor abuGelap) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Expanded(flex: 3, child: pw.Container(height: 6, color: pinkCeria)),
            pw.Expanded(flex: 2, child: pw.Container(height: 6, color: biruAwan)),
            pw.Expanded(flex: 1, child: pw.Container(height: 6, color: PdfColor.fromHex('#FFB74D'))),
          ],
        ),
        pw.SizedBox(height: 14),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "LAPORAN PERKEMBANGAN ANAK",
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: pinkCeria),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  "Sistem Pemantauan Perkembangan Motorik Halus & Kasar Anak Usia Dini",
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#FFF0F3'),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                border: pw.Border.all(color: pinkCeria, width: 1),
              ),
              child: pw.Text(
                "RAPORT MOTORIK",
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: pinkCeria),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Divider(thickness: 1, color: PdfColor.fromHex('#E0E0E0')),
      ],
    );
  }

  pw.Widget _buildStudentInfoCardPDF(PdfColor pinkCeria, PdfColor biruAwan, PdfColor kuningSoft, PdfColor abuGelap) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: kuningSoft,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(16)),
        border: pw.Border.all(color: PdfColor.fromHex('#FFE0B2'), width: 1.5),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "NAMA ANANDA",
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                cleanPdfText(studentName.value).toUpperCase(),
                style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: abuGelap),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                "Usia Anak: ${cleanPdfText(studentAge.value)}   |   Total Observasi: ${assessmentHistory.length} Catatan",
                style: pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                "STATUS CAPAIAN TERKINI",
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: pinkCeria,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                ),
                child: pw.Text(
                  cleanPdfText(currentStatus.value),
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildHistoryTablePDF(PdfColor pinkCeria, PdfColor biruAwan, PdfColor abuGelap) {
    final headers = ['Tanggal', 'Ranah', 'Kegiatan & Catatan Anekdot Guru', 'Skor', 'Status Capaian'];

    final data = assessmentHistory.map((item) {
      String dateStr = formatDate(item['date'] ?? "");
      String type = cleanPdfText(item['type'] ?? "Halus");
      // Menerapkan cleanPdfText agar emoji tidak menjadi kotak silang
      String activity = cleanPdfText(item['activity'] ?? "-");
      String notes = cleanPdfText(item['notes'] ?? "-");
      String status = cleanPdfText(item['status'] ?? "-");
      int score = (item['score'] ?? 0).toInt();

      return [
        dateStr,
        type,
        "$activity\n\"$notes\"",
        "$score",
        status,
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColor.fromHex('#F0D5DA'), width: 0.8),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5, color: PdfColors.white),
      headerDecoration: pw.BoxDecoration(color: pinkCeria),
      oddRowDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#FFF9FA')),
      cellStyle: pw.TextStyle(fontSize: 9, color: abuGelap),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
      },
      columnWidths: {
        0: const pw.FixedColumnWidth(65),
        1: const pw.FixedColumnWidth(50),
        2: const pw.FlexColumnWidth(3),
        3: const pw.FixedColumnWidth(32),
        4: const pw.FixedColumnWidth(85),
      },
    );
  }

  pw.Widget _buildSignatureSectionPDF({
    required String teacherName,
    required String nip,
    required PdfColor pinkCeria,
    required PdfColor abuGelap,
  }) {
    String tanggalCetak = DateFormat('dd MMMM yyyy').format(DateTime.now());

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text("......... , $tanggalCetak", style: pw.TextStyle(fontSize: 9.5, color: abuGelap)),
            pw.SizedBox(height: 4),
            pw.Text("Wali Kelas,", style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: abuGelap)),
            pw.SizedBox(height: 45),
            pw.Text(
              teacherName.isNotEmpty ? teacherName : "Guru Kelas",
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: abuGelap,
                decoration: pw.TextDecoration.underline,
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              nip != "-" && nip.isNotEmpty ? "NIP. $nip" : "NIP. ....................................",
              style: pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildFooterNotePDF(pw.Context context, PdfColor pinkCeria, PdfColor biruAwan) {
    return pw.Column(
      children: [
        pw.Divider(thickness: 0.5, color: PdfColor.fromHex('#E0E0E0')),
        pw.SizedBox(height: 6),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              "\"Anak ceria, bergerak aktif, tumbuh kembang optimal!\"",
              style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic, color: PdfColors.grey600),
            ),
            pw.Text(
              "Halaman ${context.pageNumber} dari ${context.pagesCount}",
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            pw.Expanded(flex: 1, child: pw.Container(height: 3, color: pinkCeria)),
            pw.Expanded(flex: 1, child: pw.Container(height: 3, color: biruAwan)),
            pw.Expanded(flex: 1, child: pw.Container(height: 3, color: PdfColor.fromHex('#FFB74D'))),
          ],
        ),
      ],
    );
  }

  String formatDate(String isoString) {
    try {
      DateTime date = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return "-";
    }
  }

  String _getPAUDScaleLabel(double score) {
    if (score >= 76) return "Berkembang Sangat Baik (BSB)";
    if (score >= 51) return "Berkembang Sesuai Harapan (BSH)";
    if (score >= 26) return "Mulai Berkembang (MB)";
    return "Belum Berkembang (BB)";
  }
}