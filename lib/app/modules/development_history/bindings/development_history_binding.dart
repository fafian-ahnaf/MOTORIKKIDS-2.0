import 'package:get/get.dart';

import '../controllers/development_history_controller.dart';

class DevelopmentHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DevelopmentHistoryController>(
      () => DevelopmentHistoryController(),
    );
  }
}
