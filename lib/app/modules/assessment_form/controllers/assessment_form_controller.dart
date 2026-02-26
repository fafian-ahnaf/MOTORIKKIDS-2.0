import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motorikkids/app/services/nlp_service.dart';

class AssessmentFormController extends GetxController {
  
  final teksObservasi = TextEditingController();
  
  
  final isLoading = false.obs;
  final hasilPrediksi = "".obs;
  final skorKeyakinan = "".obs;

  void analisisData() async {
    
    if (teksObservasi.text.isEmpty) {
      Get.snackbar(
        "Peringatan", 
        "Teks observasi tidak boleh kosong!",
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    
    isLoading.value = true;
    
    
    final hasil = await NlpService.analisisMotorik(teksObservasi.text);
    
    
    isLoading.value = false;

    if (hasil != null) {
      
      hasilPrediksi.value = hasil['prediksi_status'];
      
      
      double skor = hasil['tingkat_keyakinan'];
      skorKeyakinan.value = (skor * 100).toStringAsFixed(1) + "%";
    } else {
      Get.snackbar(
        "Error", 
        "Gagal terhubung ke Server AI. Pastikan server Flask menyala.",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    teksObservasi.dispose(); 
    super.onClose();
  }
}