import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/teacher_dashboard_controller.dart';

class TeacherDashboardView extends GetView<TeacherDashboardController> {
  const TeacherDashboardView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TeacherDashboardView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'TeacherDashboardView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
