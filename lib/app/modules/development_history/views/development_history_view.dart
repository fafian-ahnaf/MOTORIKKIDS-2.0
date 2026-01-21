import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/development_history_controller.dart';

class DevelopmentHistoryView extends GetView<DevelopmentHistoryController> {
  const DevelopmentHistoryView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DevelopmentHistoryView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'DevelopmentHistoryView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
