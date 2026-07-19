import 'package:get/get.dart';

import '../modules/analysis_result/bindings/analysis_result_binding.dart';
import '../modules/analysis_result/views/analysis_result_view.dart';
import '../modules/assessment_form/bindings/assessment_form_binding.dart';
import '../modules/assessment_form/views/assessment_form_view.dart';
import '../modules/development_history/bindings/development_history_binding.dart';
import '../modules/development_history/views/development_history_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/parent_dashboard/bindings/parent_dashboard_binding.dart';
import '../modules/parent_dashboard/views/parent_dashboard_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/recommendation/bindings/recommendation_binding.dart';
import '../modules/recommendation/views/recommendation_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/student_detail/bindings/student_detail_binding.dart';
import '../modules/student_detail/views/student_detail_view.dart';
import '../modules/student_list/bindings/student_list_binding.dart';
import '../modules/student_list/views/student_list_view.dart';
import '../modules/teacher_dashboard/bindings/teacher_dashboard_binding.dart';
import '../modules/teacher_dashboard/views/teacher_dashboard_view.dart';
import '../modules/welcome/bindings/welcome_binding.dart';
import '../modules/welcome/views/welcome_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.WELCOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.WELCOME,
      page: () => WelcomeView(),
      binding: WelcomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.TEACHER_DASHBOARD,
      page: () => TeacherDashboardView(),
      binding: TeacherDashboardBinding(),
    ),
    GetPage(
      name: _Paths.STUDENT_LIST,
      page: () => StudentListView(),
      binding: StudentListBinding(),
    ),
    GetPage(
      name: _Paths.ASSESSMENT_FORM,
      page: () => AssessmentFormView(),
      binding: AssessmentFormBinding(),
    ),
    GetPage(
      name: _Paths.ANALYSIS_RESULT,
      page: () => AnalysisResultView(),
      binding: AnalysisResultBinding(),
    ),
    GetPage(
      name: _Paths.PARENT_DASHBOARD,
      page: () => ParentDashboardView(),
      binding: ParentDashboardBinding(),
    ),
    GetPage(
      name: _Paths.DEVELOPMENT_HISTORY,
      page: () => DevelopmentHistoryView(),
      binding: DevelopmentHistoryBinding(),
    ),
    GetPage(
      name: _Paths.RECOMMENDATION,
      page: () => RecommendationView(),
      binding: RecommendationBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.STUDENT_DETAIL,
      page: () => StudentDetailView(),
      binding: StudentDetailBinding(),
    ),
  ];
}