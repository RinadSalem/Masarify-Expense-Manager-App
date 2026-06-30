 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/auth_controller.dart';
import '../services/app_theme.dart';

class AuthScreen extends GetView<AuthController> {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0E17), Color(0xFF1C1B29), Color(0xFF0F0E17)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 60),

                 
                _buildHeader(context),

                const SizedBox(height: 50),

                
                _buildFormCard(context),

                const SizedBox(height: 24),

                 
                _buildToggleButton(context),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppTheme.gradientPrimary),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.35),
                blurRadius: 25,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            size: 44,
            color: Colors.white,
          ),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: 20),
        Obx(() => Text(
              controller.isRegisterMode.value ? 'إنشاء حساب جديد' : 'مرحباً بك',
              // ✅ تأمين الـ copyWith هنا بـ ?.
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 28,
                  ),
            ).animate().fadeIn(delay: 200.ms)),
        const SizedBox(height: 8),
        Obx(() => Text(
              controller.isRegisterMode.value
                  ? 'أنشئ حسابك وابدأ تتبع مصاريفك'
                  : 'سجّل دخولك لمتابعة مصاريفك',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            )),
      ],
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           
          Text(
            'اسم المستخدم',
          
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller.nameController,
            textDirection: TextDirection.rtl,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              hintText: 'أدخل اسمك...',
              hintStyle: TextStyle(color: AppTheme.textSecondary),
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),

          const SizedBox(height: 20),

        
          Text(
            'كلمة المرور',
            
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 8),
          Obx(() => TextField(
                controller: controller.passwordController,
                obscureText: controller.obscurePassword.value,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'أدخل كلمة المرور...',
                  hintStyle: const TextStyle(color: AppTheme.textSecondary),
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.obscurePassword.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                ),
              )),

           
          Obx(() {
            if (!controller.isRegisterMode.value) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'البريد الإلكتروني (اختياري)',
                   
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.emailController,
                  textDirection: TextDirection.ltr,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'example@email.com',
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'العمر (اختياري)',
                   
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.ageController,
                  textDirection: TextDirection.rtl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'أدخل عمرك...',
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
          }),

           
          Obx(() {
            return controller.isRegisterMode.value
                ? Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      'سيتم حفظ البيانات محلياً وآمناً.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  )
                : const SizedBox.shrink();
          }),

           
          Obx(() => controller.errorMessage.value.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppTheme.secondaryColor, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.errorMessage.value,
                            style: const TextStyle(
                                color: AppTheme.secondaryColor, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox()),

          const SizedBox(height: 24),

           
          Obx(() => controller.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                )
              : _buildSubmitButton(context)),
        ],
      ),
    ).animate().slideY(begin: 0.2, duration: 500.ms).fadeIn(delay: 300.ms);
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppTheme.gradientPrimary,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (controller.isRegisterMode.value) {
            controller.register();
          } else {
            controller.login();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 56),
        ),
        child: Obx(() => Text(
              controller.isRegisterMode.value ? 'إنشاء الحساب' : 'تسجيل الدخول',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            )),
      ),
    );
  }

  Widget _buildToggleButton(BuildContext context) {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              controller.isRegisterMode.value
                  ? 'لديك حساب بالفعل؟'
                  : 'ليس لديك حساب؟',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            TextButton(
              onPressed: controller.toggleMode,
              child: Text(
                controller.isRegisterMode.value ? 'تسجيل الدخول' : 'إنشاء حساب',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ));
  }
}