
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import 'auth_controller.dart';

class ExpenseController extends GetxController {
 
  final DatabaseService _dbService = DatabaseService();

  final AuthController _authController = Get.find<AuthController>();

  // ─── قائمة المصاريف (Observable) - يُحدِّث الـ View تلقائياً ───
  final RxList<ExpenseModel> expenses = <ExpenseModel>[].obs;
  final RxDouble totalAmount = 0.0.obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCategory = 'الكل'.obs;
  final RxString errorMessage = ''.obs;

  
  late Future<List<ExpenseModel>> expensesFuture;

  // ─── Controllers لشاشة الإضافة/التعديل ───
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString selectedCategoryForm = ExpenseModel.categories.first.obs;

  final Rxn<ExpenseModel> editingExpense = Rxn<ExpenseModel>();

  @override
  void onInit() {
    super.onInit();
  
    expensesFuture = loadExpensesFuture();
  }

  @override
  void onClose() {
    titleController.dispose();
    amountController.dispose();
    super.onClose();
  }


  UserModel get _currentUser => _authController.currentUser.value!;


  Future<List<ExpenseModel>> loadExpensesFuture() async {
    List<ExpenseModel> result;

    if (selectedCategory.value == 'الكل') {
      result = await _dbService.getExpensesByUser(_currentUser.id!);
    } else {
      result = await _dbService.getExpensesByCategory(
        _currentUser.id!,
        selectedCategory.value,
      );
    }

    
    expenses.assignAll(result);
    await _calculateTotal();

    return result;
  }


  Future<void> loadExpenses() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      List<ExpenseModel> result;

      if (selectedCategory.value == 'الكل') {
        result = await _dbService.getExpensesByUser(_currentUser.id!);
      } else {
        result = await _dbService.getExpensesByCategory(
          _currentUser.id!,
          selectedCategory.value,
        );
      }

      expenses.assignAll(result);
      await _calculateTotal();
    } catch (e) {
      errorMessage.value = 'فشل تحميل البيانات: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  
  Future<void> _calculateTotal() async {
    final total = await _dbService.getTotalExpenses(_currentUser.id!);
    totalAmount.value = total;
  }

  
  Future<void> saveExpense() async {
    if (!_validateExpenseForm()) return;

    isLoading.value = true;

    try {
      final expense = ExpenseModel(
        id: editingExpense.value?.id,
        userId: _currentUser.id!,
        title: titleController.text.trim(),
        amount: double.parse(amountController.text.trim()),
        date: selectedDate.value.toIso8601String().split('T').first,
        category: selectedCategoryForm.value,
      );

      if (editingExpense.value == null) {
        await _dbService.insertExpense(expense);
        Get.snackbar('✅ تم', 'تمت إضافة المصروف بنجاح',
            snackPosition: SnackPosition.TOP);
      } else {
        await _dbService.updateExpense(expense);
        Get.snackbar('✏️ تم', 'تم تعديل المصروف بنجاح',
            snackPosition: SnackPosition.TOP);
      }

      
      expensesFuture = loadExpensesFuture();
      
      clearForm();
      Get.back();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل حفظ المصروف: ${e.toString()}',
          snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }

  
  Future<void> deleteExpense(int id) async {
    try {
      await _dbService.deleteExpense(id);
      
      
      expenses.removeWhere((e) => e.id == id);
      await _calculateTotal();
      
      
      expensesFuture = loadExpensesFuture();
      
      Get.snackbar('🗑️ تم', 'تم حذف المصروف',
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل حذف المصروف', snackPosition: SnackPosition.TOP);
    }
  }

  
  void prepareForEdit(ExpenseModel expense) {
    editingExpense.value = expense;
    titleController.text = expense.title;
    amountController.text = expense.amount.toString();
    selectedDate.value = DateTime.parse(expense.date);
    selectedCategoryForm.value = expense.category;
  }

  
  void clearForm() {
    editingExpense.value = null;
    titleController.clear();
    amountController.clear();
    selectedDate.value = DateTime.now();
    selectedCategoryForm.value = ExpenseModel.categories.first;
  }


  void filterByCategory(String category) {
    selectedCategory.value = category;
    
    expensesFuture = loadExpensesFuture();
  }

 
  void setDate(DateTime date) => selectedDate.value = date;

  bool _validateExpenseForm() {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('تنبيه', 'الرجاء إدخال عنوان المصروف');
      return false;
    }
    if (amountController.text.trim().isEmpty ||
        double.tryParse(amountController.text.trim()) == null) {
      Get.snackbar('تنبيه', 'الرجاء إدخال مبلغ صحيح');
      return false;
    }
    return true;
  }
}