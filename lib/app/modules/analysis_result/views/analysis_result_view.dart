import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/analysis_result_controller.dart';

class AnalysisResultView extends GetView<AnalysisResultController> {
  const AnalysisResultView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AnalysisResultView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AnalysisResultView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
