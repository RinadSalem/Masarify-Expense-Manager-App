 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/budget_controller.dart';
import '../../models/expense_model.dart';
import '../../services/app_theme.dart';

class BudgetScreen extends GetView<BudgetController> {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        backgroundColor: AppTheme.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text('الميزانية الذكية', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 20)),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }
        final hasBudget = controller.monthlyBudget.value > 0;
        
        return RefreshIndicator(
          onRefresh: controller.loadBudgetData,
          color: AppTheme.primaryColor,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _buildBudgetSetupCard(context),
              const SizedBox(height: 20),
              if (hasBudget) ...[
                _buildProgressCard(),
                const SizedBox(height: 20),
                _buildAlertCard(),
                const SizedBox(height: 20),
                _buildQuickStats(),
                const SizedBox(height: 20),
                _buildCategoryBreakdown(context),
              ] else 
                _buildNoBudgetPlaceholder(context),
            ],
          ),
        );
      }),
    );
  }

   
  Widget _buildBudgetSetupCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ميزانيتي الشهرية', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.budgetInputController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: AppTheme.primaryColor, fontSize: 20, fontWeight: FontWeight.w800),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5), fontSize: 20),
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                      child: const Text('ر.س', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w700)),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: AppTheme.surfaceColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: controller.saveBudget,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppTheme.gradientPrimary),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: controller.isSaving.value
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save_rounded, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  
  Widget _buildProgressCard() {
    final pct = controller.spentPercentage;
    final color = controller.alertColor;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.15), AppTheme.cardColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _amountColumn('تم إنفاق', '${controller.monthlySpent.value.toStringAsFixed(0)} ر.س', color, 26, FontWeight.w800),
              _amountColumn('الميزانية', '${controller.monthlyBudget.value.toStringAsFixed(0)} ر.س', AppTheme.textPrimary, 20, FontWeight.w700),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(height: 14, decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(10))),
              AnimatedContainer(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOut,
                height: 14,
                width: (Get.width - 80) * pct.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color.withOpacity(0.7), color]),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 2))],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(pct * 100).clamp(0, 999).toStringAsFixed(0)}% من الميزانية', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
              Text(controller.remainingBudget >= 0 ? 'متبقي: ${controller.remainingBudget.toStringAsFixed(0)} ر.س' : 'تجاوز: ${(-controller.remainingBudget).toStringAsFixed(0)} ر.س', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: 0.1, duration: 500.ms).fadeIn(delay: 100.ms);
  }

  Widget _amountColumn(String label, String amount, Color color, double size, FontWeight weight) {
    return Column(
      crossAxisAlignment: label == 'تم إنفاق' ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        Text(amount, style: TextStyle(color: color, fontSize: size, fontWeight: weight)),
      ],
    );
  }

  
  Widget _buildAlertCard() {
    final color = controller.alertColor;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.4))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(controller.alertMessage, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💬 ', style: TextStyle(fontSize: 14)),
              Expanded(child: Text(controller.financialTip, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

 
  Widget _buildQuickStats() {
    final spent = controller.monthlySpent.value;
    final daily = spent > 0 ? spent / DateTime.now().day : 0.0;
    final daysLeft = DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day - DateTime.now().day;
    final projectedEnd = spent + (daily * daysLeft);

    return Row(
  children: [
    Expanded(
      child: _miniStatCard(
        Icons.calendar_month, 
        'المتوسط اليومي', 
        '${daily.toStringAsFixed(0)} ر.س', 
        AppTheme.primaryColor,
      ),
    ),
    const SizedBox(width: 10),
    Expanded(
      child: _miniStatCard(
        Icons.auto_awesome, 
        'متوقع نهاية الشهر', 
        '${projectedEnd.toStringAsFixed(0)} ر.س', 
        projectedEnd > controller.monthlyBudget.value ? AppTheme.secondaryColor : const Color(0xFF43E97B),
      ),
    ),
    const SizedBox(width: 10),
    Expanded(
      child: _miniStatCard(
        Icons.hourglass_top, 
        'أيام متبقية', 
        '$daysLeft يوم', 
        const Color(0xFFF7B731),
      ),
    ),
  ],
).animate().slideX(begin: 0.1, duration: 400.ms).fadeIn(delay: 300.ms);
}

// تم تغيير نوع المعامل الأول إلى IconData هنا ليتوافق مع التعديل الجديد
Widget _miniStatCard(IconData icon, String label, String value, Color color) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1), 
      borderRadius: BorderRadius.circular(18), 
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // تم استبدال الـ Text بويدجت Icon وتلوينها بنفس لون الكارت
        Icon(
          icon, 
          size: 18, 
          color: color,
        ),
        const SizedBox(height: 6),
        Text(
          value, 
          style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13), 
          maxLines: 1, 
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label, 
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
        ),
      ],
    ),
  );
}

   
  Widget _buildCategoryBreakdown(BuildContext context) {
    if (controller.categorySpending.isEmpty) return const SizedBox();
    final budget = controller.monthlyBudget.value;
    final entries = controller.categorySpending.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.primaryColor.withOpacity(0.15))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('توزيع الإنفاق', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15)),
          const SizedBox(height: 16),
          ...entries.map((entry) {
            final color = Color(ExpenseModel.categoryColors[entry.key] ?? 0xFF636E72);
            final pct = budget > 0 ? (entry.value / budget).clamp(0.0, 1.0) : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
  ExpenseModel.categoryIcons[entry.key] ?? Icons.inventory_2, 
  color: Color(ExpenseModel.categoryColors[entry.key] ?? 0xFF636E72),
),
                      const SizedBox(width: 8),
                      Expanded(child: Text(entry.key, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13))),
                      Text('${entry.value.toStringAsFixed(0)} ر.س', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(width: 8),
                      Text('${(pct * 100).toStringAsFixed(0)}%', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(value: pct, backgroundColor: AppTheme.surfaceColor, valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 6),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().slideY(begin: 0.1, duration: 500.ms).fadeIn(delay: 400.ms);
  }

  Widget _buildNoBudgetPlaceholder(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Text('💡', style: TextStyle(fontSize: 64)).animate(onPlay: (c) => c.repeat(reverse: true)).scale(duration: 1000.ms, begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
          const SizedBox(height: 20),
          Text('حدّد ميزانيتك الشهرية', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
          const SizedBox(height: 10),
          const Text('أدخل ميزانيتك أعلاه وستحصل على\nتحليل ذكي لإنفاقك الشهري', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, height: 1.6)),
        ],
      ),
    );
  }
}