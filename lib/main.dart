import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'controllers/auth_controller.dart';
import 'services/app_theme.dart';
import 'services/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  await initializeDateFormatting('ar', null);

 
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

   
  Get.put<AuthController>(AuthController(), permanent: true);

  runApp(const ExpenseManagerApp());
}

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'مصاريفي',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
       
      locale: const Locale('ar', 'SA'),
      textDirection: TextDirection.rtl,
      defaultTransition: Transition.fadeIn,
    );
  }
}
