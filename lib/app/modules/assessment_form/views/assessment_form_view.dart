import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/assessment_form_controller.dart';

class AssessmentFormView extends GetView<AssessmentFormController> {
  const AssessmentFormView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AssessmentFormView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AssessmentFormView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
