

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/database_service.dart';
import 'auth_controller.dart';

class BudgetController extends GetxController {
  final DatabaseService _dbService = DatabaseService();
  final AuthController _authController = Get.find<AuthController>();

  final RxDouble monthlyBudget = 0.0.obs;
  final RxDouble monthlySpent = 0.0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  final RxMap<String, double> categorySpending = <String, double>{}.obs;
  final budgetInputController = TextEditingController();
  final RxString alertLevel = 'safe'.obs;

  int get _userId => _authController.currentUser.value!.id!;
  double get remainingBudget => monthlyBudget.value - monthlySpent.value;
  double get spentPercentage => monthlyBudget.value <= 0 ? 0 : (monthlySpent.value / monthlyBudget.value).clamp(0.0, 1.5);

  
  static const _alertConfig = {
    'over':    {'color': Color(0xFFFF4757), 'msg': '⚠️ تجاوزت ميزانيتك الشهرية!', 'tip': 'حاول تقليل مصاريف الترفيه والتسوق هذا الشهر.'},
    'danger':  {'color': Color(0xFFFF6B6B), 'msg': '🔴 تحذير: اقتربت من حد الميزانية', 'tip': 'تبقّى لك القليل، تجنب المصاريف غير الضرورية.'},
    'warning': {'color': Color(0xFFFFD93D), 'msg': '🟡 انتبه: أنت في منتصف ميزانيتك', 'tip': 'أنت في المسار الصحيح، حافظ على وتيرتك.'},
    'safe':    {'color': Color(0xFF43E97B), 'msg': '🟢 رائع! إنفاقك في الحدود الآمنة', 'tip': 'استمر هكذا! يمكنك ادخار المتبقي من ميزانيتك.'},
  };

  Color get alertColor => (_alertConfig[alertLevel.value]?['color'] ?? const Color(0xFF43E97B)) as Color;
  String get alertMessage => (_alertConfig[alertLevel.value]?['msg'] ?? '') as String;
  String get financialTip => (_alertConfig[alertLevel.value]?['tip'] ?? '') as String;

  @override
  void onInit() {
    super.onInit();
    loadBudgetData();
  }

  @override
  void onClose() {
    budgetInputController.dispose();
    super.onClose();
  }


  Future<void> loadBudgetData() async {
    isLoading.value = true;
    try {
      final savedBudget = await _dbService.getBudget(_userId);
      if (savedBudget != null) {
        monthlyBudget.value = savedBudget;
        budgetInputController.text = savedBudget.toStringAsFixed(0);
      }
      monthlySpent.value = await _dbService.getCurrentMonthTotal(_userId);
      categorySpending.assignAll(await _dbService.getExpensesByCategories(_userId));
      _updateAlertLevel();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل بيانات الميزانية');
    } finally {
      isLoading.value = false;
    }
  }

  
  Future<void> saveBudget() async {
    final input = double.tryParse(budgetInputController.text.trim());
    if (input == null || input <= 0) {
      Get.snackbar('تنبيه', 'الرجاء إدخال ميزانية صحيحة', snackPosition: SnackPosition.TOP);
      return;
    }

    isSaving.value = true;
    try {
      final now = DateTime.now();
      await _dbService.saveBudget(_userId, input, '${now.year}-${now.month.toString().padLeft(2, '0')}');
      monthlyBudget.value = input;
      _updateAlertLevel();
      Get.snackbar('✅ تم', 'تم حفظ الميزانية بنجاح', snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل حفظ الميزانية');
    } finally {
      isSaving.value = false;
    }
  }

  
  void _updateAlertLevel() {
    final pct = spentPercentage;
    if (pct >= 1.0){ alertLevel.value = 'over';}
    else if (pct >= 0.85) {alertLevel.value = 'danger';}
    else if (pct >= 0.65) {alertLevel.value = 'warning';}
    else{ alertLevel.value = 'safe';}
  }
}