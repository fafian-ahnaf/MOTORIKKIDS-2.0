import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/recommendation_controller.dart';

class RecommendationView extends GetView<RecommendationController> {
  const RecommendationView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RecommendationView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'RecommendationView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
