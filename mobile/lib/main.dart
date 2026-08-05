import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'utils/theme.dart';
import 'controllers/auth_controller.dart';
import 'controllers/language_controller.dart';
import 'views/auth/login_screen.dart';

void main() {
  Get.put(AuthController());
  Get.put(LanguageController());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final langCtrl = Get.find<LanguageController>();
    langCtrl.loadLanguage();

    return GetMaterialApp(
      title: 'PMCFMS',
      theme: AppTheme.darkTheme,
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
