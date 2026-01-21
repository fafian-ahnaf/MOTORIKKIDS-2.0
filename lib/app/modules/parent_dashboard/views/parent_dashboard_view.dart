import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/parent_dashboard_controller.dart';

class ParentDashboardView extends GetView<ParentDashboardController> {
  const ParentDashboardView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ParentDashboardView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ParentDashboardView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
