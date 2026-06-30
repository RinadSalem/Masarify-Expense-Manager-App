import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class AuthController extends GetxController {
  // ─── حقن الـ DatabaseService ───
  final DatabaseService _dbService = DatabaseService();

  // ─── متغيرات الحالة (Observable) ───
  final RxBool isLoading = false.obs;
  final RxBool isRegisterMode = false.obs;
  final RxString errorMessage = ''.obs;

  // ─── Controllers للـ TextFields ───
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController(); 
  final ageController = TextEditingController();  
  final RxBool obscurePassword = true.obs;

  // ─── المستخدم الحالي المحفوظ في الذاكرة ───
  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  @override
  void onClose() {
    nameController.dispose();
    passwordController.dispose();
    emailController.dispose(); 
    ageController.dispose();   
    super.onClose();
  }

  /// تبديل بين وضع تسجيل الدخول والتسجيل
  void toggleMode() {
    isRegisterMode.toggle();
    errorMessage.value = '';
    nameController.clear();
    passwordController.clear();
    emailController.clear();
    ageController.clear();   
  }

  /// إظهار/إخفاء كلمة المرور
  void togglePasswordVisibility() => obscurePassword.toggle();


  Future<void> login() async {
    if (!_validateInputs()) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final user = await _dbService.loginUser(
        nameController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        currentUser.value = user;
        Get.offAllNamed('/home');
      } else {
        errorMessage.value = 'اسم المستخدم أو كلمة المرور غير صحيحة';
      }
    } catch (e) {
      errorMessage.value = 'حدث خطأ: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

 
  Future<void> register() async {
    if (!_validateInputs()) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // التحقق إذا كان الاسم مستخدماً
      final exists = await _dbService.userExists(nameController.text.trim());
      if (exists) {
        errorMessage.value = 'اسم المستخدم موجود بالفعل';
        return;
      }

     
      String? emailText = emailController.text.trim();
      if (emailText.isEmpty) emailText = null;

      
      int? ageValue;
      String ageText = ageController.text.trim();
      if (ageText.isNotEmpty) {
        ageValue = int.tryParse(ageText);
      }

      // [Controller → DB] إنشاء نموذج المستخدم وحفظه مع الحقول الجديدة
      final newUser = UserModel(
        name: nameController.text.trim(),
        password: passwordController.text.trim(),
        email: emailText, 
        age: ageValue,    
      );
      final userId = await _dbService.insertUser(newUser);

      // [DB → Controller] تخزين المستخدم مع الـ id الجديد
      currentUser.value = newUser.copyWith(id: userId);
      Get.offAllNamed('/home');
    } catch (e) {
      errorMessage.value = 'حدث خطأ: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// تسجيل الخروج
  void logout() {
    currentUser.value = null;
    nameController.clear();
    passwordController.clear();
    emailController.clear(); 
    ageController.clear();   
    Get.offAllNamed('/auth');
  }

  /// التحقق من صحة المدخلات
  bool _validateInputs() {
    
    if (nameController.text.trim().isEmpty) {
      errorMessage.value = 'الرجاء إدخال اسم المستخدم';
      return false;
    }
    
    
    if (passwordController.text.trim().length < 4) {
      errorMessage.value = 'كلمة المرور يجب أن تكون 4 أحرف على الأقل';
      return false;
    }

    
    if (isRegisterMode.value) {
      String emailText = emailController.text.trim();
      if (emailText.isNotEmpty && !GetUtils.isEmail(emailText)) {
        errorMessage.value = 'صيغة البريد الإلكتروني غير صحيحة';
        return false;
      }
    }
    
    return true;
  }
}