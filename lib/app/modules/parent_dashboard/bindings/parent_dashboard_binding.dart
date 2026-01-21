import 'package:get/get.dart';

import '../controllers/parent_dashboard_controller.dart';

class ParentDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentDashboardController>(
      () => ParentDashboardController(),
    );
  }
}
