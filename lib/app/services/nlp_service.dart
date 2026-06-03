import 'dart:convert';
import 'package:http/http.dart' as http;

class NlpService {
  
  static const String _baseUrl = 'http://10.88.77.217:5000/predict'; 

  static Future<Map<String, dynamic>?> analisisMotorik(String teks) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"teks": teks}),
      ).timeout(const Duration(seconds: 15)); 

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        
        if (data['status'] == 'success') {
          return data['data']; 
        }
      }
      
      print("Server error: ${response.statusCode}");
      return null;
    } catch (e) {
      
      print("Error NLP API: $e");
      return null;
    }
  }
}