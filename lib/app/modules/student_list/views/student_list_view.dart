import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/student_list_controller.dart';

class StudentListView extends GetView<StudentListController> {
  const StudentListView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudentListView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'StudentListView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
