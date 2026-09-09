import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/elder_button.dart';
import '../../widgets/elder_text_field.dart';
import '../main_navigation_screen.dart';
import 'change_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreeTerms = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final app = context.read<AppProvider>();
    final auth = context.read<AuthProvider>();

    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            app.tr('agreeTerms'),
            style: TextStyle(fontSize: 15 * app.fontScale),
          ),
          backgroundColor: AppColors.destructive,
        ),
      );
      return;
    }

    final success = await auth.login(
      _phoneController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } else if (mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auth.errorMessage!,
            style: TextStyle(fontSize: 15 * app.fontScale),
          ),
          backgroundColor: AppColors.destructive,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final auth = context.watch<AuthProvider>();
    final fontScale = app.fontScale;
    final isDark = app.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // One-tap Language Switch Chip
          Padding(
            padding: EdgeInsets.only(right: 16 * fontScale),
            child: ActionChip(
              avatar: Icon(Icons.language, size: 18 * fontScale, color: AppColors.primary),
              label: Text(
                app.isBengali ? 'English' : 'বাংলা',
                style: TextStyle(
                  fontSize: 13.5 * fontScale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
              onPressed: () => app.toggleLanguage(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24 * fontScale, vertical: 12 * fontScale),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Icon
                    Center(
                      child: Container(
                        width: 72 * fontScale,
                        height: 72 * fontScale,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.receipt_long_rounded,
                            size: 38 * fontScale,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 18 * fontScale),

                    // Header title
                    Text(
                      app.tr('signIn'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26 * fontScale,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 6 * fontScale),
                    Text(
                      app.tr('loginSubtitle'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15 * fontScale,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    SizedBox(height: 28 * fontScale),

                    // Phone Input
                    ElderTextField(
                      label: app.tr('phone'),
                      hintText: app.tr('phoneHint'),
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return app.tr('phone');
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 18 * fontScale),

                    // Password Input
                    ElderTextField(
                      label: app.tr('password'),
                      hintText: '••••••••',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 22 * fontScale,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (val) {
                        if (val == null || val.length < 6) {
                          return app.tr('password');
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12 * fontScale),

                    // Forgot Password Row
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                          );
                        },
                        child: Text(
                          app.tr('forgotPassword'),
                          style: TextStyle(
                            fontSize: 14.5 * fontScale,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),

                    // Terms Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _agreeTerms,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            setState(() {
                              _agreeTerms = val ?? true;
                            });
                          },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _agreeTerms = !_agreeTerms;
                              });
                            },
                            child: Text(
                              app.tr('agreeTerms'),
                              style: TextStyle(
                                fontSize: 13.5 * fontScale,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20 * fontScale),

                    // Login Button
                    ElderButton(
                      label: app.tr('login'),
                      icon: Icons.login_rounded,
                      isLoading: auth.isLoading,
                      onPressed: _handleLogin,
                    ),
                    SizedBox(height: 24 * fontScale),

                    // Sign Up Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          app.tr('noAccount'),
                          style: TextStyle(
                            fontSize: 14.5 * fontScale,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );
                          },
                          child: Text(
                            app.tr('signUp'),
                            style: TextStyle(
                              fontSize: 15 * fontScale,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
