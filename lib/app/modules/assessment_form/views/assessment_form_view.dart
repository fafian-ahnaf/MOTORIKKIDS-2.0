import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/assessment_form_controller.dart';

class AssessmentFormView extends GetView<AssessmentFormController> {
  const AssessmentFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Observasi Motorik')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: controller.teksObservasi, 
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Ketik catatan observasi anak di sini...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            
            
            Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : () => controller.analisisData(),
              child: controller.isLoading.value 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Analisis dengan AI"),
            )),

            const SizedBox(height: 30),

            
            Obx(() {
              if (controller.hasilPrediksi.value.isNotEmpty) {
                return Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text("Hasil Analisis NLP:"),
                        Text(
                          controller.hasilPrediksi.value,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        Text("Akurasi: ${controller.skorKeyakinan.value}"),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink(); 
            })
          ],
        ),
      ),
    );
  }
}