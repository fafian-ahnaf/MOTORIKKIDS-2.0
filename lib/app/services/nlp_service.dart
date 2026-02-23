import 'dart:convert';
import 'package:http/http.dart' as http;

class NlpService {
  // 1. Tambahkan http://, port :5000, dan path /predict sesuai kode Flask Anda
  static const String _baseUrl = 'http://192.168.48.192:5000/predict'; 

  static Future<Map<String, dynamic>?> analisisMotorik(String teks) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"teks": teks}),
      ).timeout(const Duration(seconds: 15)); // 2. Tambahkan timeout untuk mencegah loading selamanya

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // 3. Pastikan mengambil data['data'] jika status responsnya 'success'
        if (data['status'] == 'success') {
          return data['data']; 
        }
      }
      
      print("Server error: ${response.statusCode}");
      return null;
    } catch (e) {
      // Akan menangkap error jika IP tidak ditemukan atau HP tidak satu WiFi
      print("Error NLP API: $e");
      return null;
    }
  }
}