import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  // ⚠️ GANTI DENGAN API KEY KAMU DARI https://aistudio.google.com/
  final String _apiKey = 'AIzaSyCIkkqyNmgiczwINoaAtKO9JpnjSGCAXj4'; 

  Future<Map<String, String>> getRecommendation({
    required String age, // Parameter bernama 'age'
    required double fineScore,
    required double grossScore,
  }) async {
    try {
      final model = GenerativeModel(
        // Gunakan model yang stabil dan kuota besar
        model: 'gemini-2.5-flash', 
        apiKey: _apiKey,
      );

      // --- PROMPT YANG DISESUAIKAN DENGAN BAHASA KURIKULUM PAUD ---
      final prompt = '''
        Berperanlah sebagai Konsultan Pendidikan Anak Usia Dini (PAUD) yang ahli dalam Kurikulum Merdeka.
        
        Analisa Profil Perkembangan Ananda:
        - Usia: $age
        - Capaian Motorik Halus: ${(fineScore * 100).toInt()}%
        - Capaian Motorik Kasar: ${(grossScore * 100).toInt()}%

        Instruksi:
        Rancanglah 1 (satu) Kegiatan Main Bermakna (Play-based Learning) untuk menstimulasi aspek perkembangan motorik yang memiliki skor terendah. Kegiatan harus dapat dilakukan baik oleh Guru di sekolah maupun Orang Tua di rumah.

        Panduan Gaya Bahasa (PENTING):
        1. Gunakan Bahasa Indonesia yang baku, formal, dan santun sesuai kaidah pendidikan masa kini.
        2. Gunakan istilah pedagogis yang umum di TK/PAUD (contoh: "menstimulasi", "koordinasi mata dan tangan", "melatih motorik", "Ananda").
        3. Hindari bahasa gaul atau terlalu santai. Nada bicara harus profesional namun hangat membimbing.

        Format Output WAJIB JSON murni tanpa markdown (tanpa ```json), dengan kunci persis:
        {
          "title": "Judul Kegiatan (Formal & Edukatif, Contoh: 'Eksplorasi Keseimbangan Tubuh')",
          "desc": "Penjelasan singkat mengenai urgensi dan manfaat kegiatan bagi tumbuh kembang fisik motorik Ananda.",
          "tujuan": "Tujuan Pembelajaran (Contoh: 'Mengembangkan kemampuan manipulatif dan koordinasi visuo-motorik')",
          "cara": "Langkah-langkah pelaksanaan yang terstruktur (Contoh: '1. Siapkan media... 2. Ajak Ananda untuk...')",
          "durasi": "Estimasi waktu (Contoh: '15-20 Menit')",
          "lokasi": "Lingkungan belajar (Contoh: 'Area luar ruang atau halaman rumah yang aman')"
        }
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      // Bersihkan format jika AI memberikan markdown
      String jsonText = response.text!
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
          
      final Map<String, dynamic> data = jsonDecode(jsonText);
      
      return data.map((key, value) => MapEntry(key, value.toString()));
      
    } catch (e) {
      print("Error AI: $e");
      // Fallback jika error (Bahasa Formal)
      return {
        "title": "Stimulasi Gerak Dasar",
        "desc": "Mohon maaf, terjadi kendala koneksi pada sistem cerdas kami.",
        "tujuan": "Memelihara kebugaran jasmani dan koordinasi tubuh Ananda.",
        "cara": "Lakukan gerakan sederhana seperti berjalan lurus atau meremas bola lembut.",
        "durasi": "10-15 Menit",
        "lokasi": "Ruang Kelas atau Ruang Keluarga"
      };
    }
  }
}