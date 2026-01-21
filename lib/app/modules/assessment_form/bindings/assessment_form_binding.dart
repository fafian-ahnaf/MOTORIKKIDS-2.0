import 'package:get/get.dart';

import '../controllers/assessment_form_controller.dart';

class AssessmentFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AssessmentFormController>(
      () => AssessmentFormController(),
    );
  }
}
