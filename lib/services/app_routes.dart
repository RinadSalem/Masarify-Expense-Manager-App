

import 'package:get/get.dart';
import '../views/splash_screen.dart';
import '../views/auth_screen.dart';
import '../views/home_screen.dart';
import '../views/budget_screen.dart';
import '../bindings/auth_binding.dart';
import '../bindings/home_binding.dart';
import '../bindings/budget_binding.dart';

class AppRoutes {
  static const String splash     = '/';
  static const String auth       = '/auth';
  static const String home       = '/home';
  static const String statistics = '/statistics';
  static const String budget     = '/budget';

  static final List<GetPage> pages = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: auth, page: () => const AuthScreen(), binding: AuthBinding(), transition: Transition.fadeIn),
    GetPage(name: home, page: () => const HomeScreen(), binding: HomeBinding(), transition: Transition.rightToLeftWithFade),
   
    GetPage(name: budget, page: () => const BudgetScreen(), binding: BudgetBinding(), transition: Transition.downToUp),
  ];
}
