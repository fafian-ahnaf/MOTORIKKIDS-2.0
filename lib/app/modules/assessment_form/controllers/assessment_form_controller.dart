import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motorikkids/app/services/nlp_service.dart';

class AssessmentFormController extends GetxController {
  // Controller untuk input teks di layar
  final teksObservasi = TextEditingController();
  
  // State variables (menggunakan .obs agar reaktif di layar)
  final isLoading = false.obs;
  final hasilPrediksi = "".obs;
  final skorKeyakinan = "".obs;

  void analisisData() async {
    // Cek jika teks kosong
    if (teksObservasi.text.isEmpty) {
      Get.snackbar(
        "Peringatan", 
        "Teks observasi tidak boleh kosong!",
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    // Ubah status jadi loading (UI akan otomatis menampilkan loading)
    isLoading.value = true;
    
    // Panggil API Python
    final hasil = await NlpService.analisisMotorik(teksObservasi.text);
    
    // Ubah status loading selesai
    isLoading.value = false;

    if (hasil != null) {
      // Masukkan hasil dari API ke state variable
      hasilPrediksi.value = hasil['prediksi_status'];
      
      // Format skor desimal (0.9231) menjadi persentase (92.3%)
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
    teksObservasi.dispose(); // Jangan lupa bersihkan memori
    super.onClose();
  }
}