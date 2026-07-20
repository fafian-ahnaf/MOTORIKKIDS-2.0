import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfReportService {
  static final PdfColor biruAwan = PdfColor.fromHex('#4FC3F7');
  static final PdfColor pinkCeria = PdfColor.fromHex('#FF7E95');
  static final PdfColor orenJeruk = PdfColor.fromHex('#FFB74D');
  static final PdfColor teksGelap = PdfColor.fromHex('#4A4A4A');
  static final PdfColor bgHeader = PdfColor.fromHex('#FFF8E7');

  static Future<void> generateAndPrintReport({
    required String namaAnak,
    required String namaGuru,
    required List<dynamic> riwayatData,
  }) async {
    final pdf = pw.Document();
    final tanggalCetak = DateFormat('dd MMMM yyyy').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildKopLaporan(),
            pw.SizedBox(height: 20),
            _buildIdentitasAnak(namaAnak, tanggalCetak),
            pw.SizedBox(height: 20),
            _buildTabelRiwayat(riwayatData),
            pw.SizedBox(height: 15),
            _buildKeteranganSkala(),
            pw.SizedBox(height: 40),
            _buildFooterTandaTangan(namaGuru, tanggalCetak),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan_Motorik_$namaAnak.pdf',
    );
  }

  static pw.Widget _buildKopLaporan() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(color: biruAwan, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(16))),
      child: pw.Column(
        children: [
          pw.Text('LAPORAN PERKEMBANGAN MOTORIK ANAK', textAlign: pw.TextAlign.center, style: pw.TextStyle(color: PdfColors.white, fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text('Aplikasi MotorikKids', style: pw.TextStyle(color: PdfColors.white, fontSize: 12)),
        ],
      ),
    );
  }

  static pw.Widget _buildIdentitasAnak(String nama, String tanggal) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(color: bgHeader, border: pw.Border.all(color: orenJeruk, width: 2), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12))),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Nama Ananda:', style: pw.TextStyle(color: teksGelap, fontSize: 10)),
              pw.Text(nama, style: pw.TextStyle(color: teksGelap, fontSize: 14, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Tanggal Cetak:', style: pw.TextStyle(color: teksGelap, fontSize: 10)),
              pw.Text(tanggal, style: pw.TextStyle(color: teksGelap, fontSize: 12, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTabelRiwayat(List<dynamic> data) {
    String getPredikat(dynamic rawScore) {
      double score = 0.0;
      if (rawScore != null) {
        if (rawScore is num) score = rawScore.toDouble();
        else score = double.tryParse(rawScore.toString()) ?? 0.0;
      }
      if (score >= 76) return "BSB";
      if (score >= 51) return "BSH";
      if (score >= 26) return "MB";
      if (score > 0) return "BB";
      return "-";
    }

    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
      headerDecoration: pw.BoxDecoration(color: pinkCeria),
      cellStyle: pw.TextStyle(color: teksGelap, fontSize: 11),
      cellAlignment: pw.Alignment.centerLeft,
      columnWidths: {
        0: const pw.FixedColumnWidth(60),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FixedColumnWidth(40),
        3: const pw.FlexColumnWidth(3),
      },
      headers: ['Tanggal', 'Kegiatan', 'Hasil', 'Catatan'],
      data: data.map((item) {
        var mapItem = item as Map<String, dynamic>;
        String dateStr = mapItem['date'] != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(mapItem['date'].toString())) : "-";
        return [dateStr, mapItem['activity']?.toString() ?? "Observasi", getPredikat(mapItem['score']), mapItem['notes']?.toString() ?? "-"];
      }).toList(),
    );
  }

  static pw.Widget _buildKeteranganSkala() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
        children: [
          pw.Text('BB: Belum Berkembang', style: pw.TextStyle(fontSize: 9, color: teksGelap)),
          pw.Text('MB: Mulai Berkembang', style: pw.TextStyle(fontSize: 9, color: teksGelap)),
          pw.Text('BSH: Berkembang Sesuai Harapan', style: pw.TextStyle(fontSize: 9, color: teksGelap)),
          pw.Text('BSB: Berkembang Sangat Baik', style: pw.TextStyle(fontSize: 9, color: teksGelap)),
        ],
      ),
    );
  }

  // --- PERBAIKAN FITUR TANDA TANGAN ---
  static pw.Widget _buildFooterTandaTangan(String namaGuru, String tanggal) {
    // Mengecek apakah nama valid (bukan kosong dan bukan tulisan 'Guru Kelas')
    bool isNamaValid = namaGuru.trim().isNotEmpty && namaGuru.toLowerCase() != 'guru kelas';

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text('Mengetahui,', style: pw.TextStyle(fontSize: 11)),
            pw.Text('Guru Kelas', style: pw.TextStyle(fontSize: 11)),
            pw.SizedBox(height: 50),
            // Jika valid cetak nama, jika tidak cetak titik-titik
            pw.Text(
              isNamaValid ? namaGuru : '(...........................................)', 
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)
            ),
          ],
        )
      ],
    );
  }
}