

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import '../../controllers/expense_controller.dart';
import '../../models/expense_model.dart';
import '../../services/app_theme.dart';

class AddExpenseScreen extends GetView<ExpenseController> {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             
            _buildSectionTitle(context, ' عنوان المصروف'),
            const SizedBox(height: 10),
            _buildTitleField(),

            const SizedBox(height: 24),

            
            _buildSectionTitle(context, ' المبلغ (ريال سعودي)'),
            const SizedBox(height: 10),
            _buildAmountField(),

            const SizedBox(height: 24),

             
            _buildSectionTitle(context, ' التاريخ'),
            const SizedBox(height: 10),
            _buildDatePicker(context),

            const SizedBox(height: 24),

            
            _buildSectionTitle(context, ' التصنيف'),
            const SizedBox(height: 12),
            _buildCategorySelector(),

            const SizedBox(height: 40),

             
            _buildSaveButton(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.bgColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: AppTheme.textPrimary),
        onPressed: () {
          controller.clearForm();
          Get.back();
        },
      ),
      title: Obx(() => Text(
            controller.editingExpense.value == null
                ? 'إضافة مصروف جديد'
                : 'تعديل المصروف',
            style: Theme.of(context).textTheme.titleLarge,
          )),
      centerTitle: true,
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: controller.titleController,
      textDirection: ui.TextDirection.rtl,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: const InputDecoration(
        hintText: 'مثال: غداء، وقود، فاتورة كهرباء...',
        hintStyle: TextStyle(color: AppTheme.textSecondary),
        prefixIcon: Icon(Icons.edit_note_rounded),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildAmountField() {
    return TextField(
      controller: controller.amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(
          color: AppTheme.primaryColor,
          fontSize: 22,
          fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        hintText: '0.00',
        hintStyle: TextStyle(
            color: AppTheme.textSecondary.withOpacity(0.5), fontSize: 22),
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'ر.س',
            style: TextStyle(
                color: AppTheme.primaryColor, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildDatePicker(BuildContext context) {
    return Obx(() => GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: controller.selectedDate.value,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (ctx, child) => Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppTheme.primaryColor,
                    surface: AppTheme.cardColor,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) controller.setDate(picked);
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  DateFormat('EEEE، dd MMMM yyyy', 'ar')
                      .format(controller.selectedDate.value),
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down_rounded,
                    color: AppTheme.textSecondary),
              ],
            ),
          ),
        ));
  }

  Widget _buildCategorySelector() {
    return Obx(() => Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ExpenseModel.categories.map((category) {
            final isSelected =
                controller.selectedCategoryForm.value == category;
            final colorValue =
                ExpenseModel.categoryColors[category] ?? 0xFF636E72;
            final color = Color(colorValue);

            return GestureDetector(
              onTap: () => controller.selectedCategoryForm.value = category,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.25)
                      : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        isSelected ? color : color.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
  ExpenseModel.categoryIcons[category] ?? Icons.inventory_2,
  color: Color(ExpenseModel.categoryColors[category] ?? 0xFF636E72), // اختياري لتلوين الأيقونة
),
                    const SizedBox(width: 6),
                    Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? color : AppTheme.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ));
  }

  Widget _buildSaveButton() {
    return Obx(() => controller.isLoading.value
        ? const Center(
            child:
                CircularProgressIndicator(color: AppTheme.primaryColor))
        : Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppTheme.gradientPrimary,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: controller.saveExpense,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                minimumSize: const Size(double.infinity, 58),
              ),
              icon: Obx(() => Icon(
                    controller.editingExpense.value == null
                        ? Icons.add_circle_rounded
                        : Icons.save_rounded,
                    color: Colors.white,
                  )),
              label: Obx(() => Text(
                    controller.editingExpense.value == null
                        ? 'إضافة المصروف'
                        : 'حفظ التعديلات',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700),
                  )),
            ),
          )).animate().slideY(begin: 0.2, duration: 400.ms).fadeIn(delay: 300.ms);
  }
}
