import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../controllers/expense_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/expense_model.dart';
import '../../services/app_theme.dart';
import 'add_expense_screen.dart';
import '../../services/app_routes.dart';

class HomeScreen extends GetView<ExpenseController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      extendBody: true,
      backgroundColor: AppTheme.bgColor,
      body: Stack(
        children: [
           
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.primaryColor.withOpacity(0.15), AppTheme.bgColor],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, authController),
                _buildTotalCard(context),
                const SizedBox(height: 16),
                _buildCategoryFilter(),
                const SizedBox(height: 12),
                
                 
                Expanded(child: _buildExpenseList(context)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

 
Widget _buildExpenseList(BuildContext context) {
    return Obx(() {
      
      final category = controller.selectedCategory.value;

      return FutureBuilder<List<ExpenseModel>>(
        key: ValueKey(category),
         
        future: controller.expensesFuture, 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
          }
          
          if (snapshot.hasError) {
            return _buildErrorState(category);
          }

          final expenses = snapshot.data ?? [];
          if (expenses.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
           onRefresh: () async {
  String currentCat = controller.selectedCategory.value;
  controller.selectedCategory.value = ''; 
  controller.filterByCategory(currentCat);
},
            color: AppTheme.primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
              itemCount: expenses.length,
              itemBuilder: (context, index) => _buildExpenseCard(context, expenses[index]),
            ),
          );
        },
      );
    });
  }
 
  Widget _buildExpenseCard(BuildContext context, ExpenseModel expense) {
    final color = Color(ExpenseModel.categoryColors[expense.category] ?? 0xFF636E72);
    
    return Dismissible(
      key: Key(expense.id.toString()),
      direction: DismissDirection.endToStart,
      
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context, expense.title);
      },

      onDismissed: (direction) {
        controller.deleteExpense(expense.id!);
      },

      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
      ),

      child: InkWell(
        onTap: () {
           
          controller.prepareForEdit(expense);
          Get.to(() => const AddExpenseScreen());
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardColor.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.1), width: 1),
          ),
          child: Row(
            children: [
              Container(
                height: 44, width: 44,
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Center(child: Icon(
  ExpenseModel.categoryIcons[expense.category] ?? Icons.attach_money, 
  size: 18, // بديل لـ fontSize لتحديد حجم الأيقونة
  color: Color(ExpenseModel.categoryColors[expense.category] ?? 0xFF636E72), // تلوين الأيقونة بلونها المخصص
)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expense.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(
                      DateFormat('yyyy/MM/dd').format(DateTime.parse(expense.date)),
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Text('${expense.amount.toStringAsFixed(0)} ر.س', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      ).animate().fadeIn().slideX(begin: 0.1),
    );
  }

 
  Widget _buildTotalCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppTheme.gradientPrimary),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('إجمالي المصاريف', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Obx(() => Text(
                  '${controller.totalAmount.value.toStringAsFixed(2)} ر.س',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
            child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  
  Future<bool?> _showDeleteConfirmation(BuildContext context, String title) {
    return Get.defaultDialog<bool>(
      title: "تأكيد الحذف",
      middleText: "هل أنت متأكد من حذف '$title'؟",
      textConfirm: "حذف",
      textCancel: "إلغاء",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
      backgroundColor: AppTheme.cardColor,
      titleStyle: const TextStyle(color: Colors.white, fontSize: 16),
      middleTextStyle: const TextStyle(color: Colors.white70, fontSize: 14),
    );
  }

 
  Widget _buildBottomNav() {
    return BottomAppBar(
      color: AppTheme.cardColor,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      elevation: 0,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            
            _navBtn(Icons.house, "الرئيسية", Get.currentRoute == AppRoutes.statistics, () => Get.toNamed(AppRoutes.home)),
            const SizedBox(width: 40),
            _navBtn(Icons.account_balance_wallet_rounded, "ميزانيتي", Get.currentRoute == AppRoutes.budget, () => Get.toNamed(AppRoutes.budget)),
          ],
        ),
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () {
        controller.clearForm();  
        Get.to(() => const AddExpenseScreen());
      },
      backgroundColor: Colors.transparent,
      elevation: 5,
      child: Container(
        decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: AppTheme.gradientPrimary)),
        child: const Center(child: Icon(Icons.add_rounded, size: 30, color: Colors.white)),
      ),
    );
  }

  Widget _navBtn(IconData icon, String label, bool active, VoidCallback onTap) {
    final color = active ? AppTheme.primaryColor : AppTheme.textSecondary;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          Text(label, style: TextStyle(color: color, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AuthController auth) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Text.rich(
  TextSpan(
    children: [
      TextSpan(
        text: 'مرحباً، ${auth.currentUser.value?.name ?? "ياصديق"} ',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const WidgetSpan(
        alignment: PlaceholderAlignment.middle, // لجعله متناسقاً في منتصف السطر مع النص
        child: Icon(
          Icons.waving_hand, 
          color: Colors.amber, // لون مناسب لليد
          size: 20, 
        ),
      ),
    ],
  ),
)),
          
           
          Row(
            children: [
               
            
 
              IconButton(
                onPressed: () {
                   
                  auth.logout(); 
                },
                icon: const Icon(Icons.logout_rounded, color: AppTheme.secondaryColor, size: 24),
                tooltip: 'تسجيل الخروج',
              ),
             
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final cats = ['الكل', ...ExpenseModel.categories];
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: cats.length,
        itemBuilder: (context, i) => Obx(() {
          bool sel = controller.selectedCategory.value == cats[i];
          return GestureDetector(
            onTap: () => controller.filterByCategory(cats[i]),
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: sel ? AppTheme.primaryColor : AppTheme.cardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(cats[i], style: TextStyle(color: sel ? Colors.white : AppTheme.textSecondary, fontSize: 11)),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("لا توجد بيانات حالياً", style: TextStyle(color: AppTheme.textSecondary)));
  }

  Widget _buildErrorState(String cat) {
    return Center(
      child: TextButton(onPressed: () => controller.filterByCategory(cat), child: const Text("حدث خطأ، اضغط لإعادة المحاولة")),
    );
  }


}