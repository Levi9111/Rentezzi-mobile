import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/elder_button.dart';
import '../../widgets/elder_text_field.dart';
import '../main_navigation_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isOtpStep = false;
  bool _obscurePassword = true;
  bool _agreeTerms = true;
  int _resendTimer = 30;
  Timer? _timer;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _resendTimer = 30;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    final app = context.read<AppProvider>();
    final auth = context.read<AuthProvider>();

    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(app.tr('agreeTerms')),
          backgroundColor: AppColors.destructive,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(app.tr('confirmPassword')),
          backgroundColor: AppColors.destructive,
        ),
      );
      return;
    }

    final success = await auth.sendOtp(_phoneController.text.trim(), purpose: 'register');
    if (success && mounted) {
      setState(() {
        _isOtpStep = true;
      });
      _startTimer();
    } else if (mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          backgroundColor: AppColors.destructive,
        ),
      );
    }
  }

  Future<void> _handleVerifyAndRegister() async {
    final app = context.read<AppProvider>();
    final auth = context.read<AuthProvider>();

    if (_otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(app.tr('otpRequired')),
          backgroundColor: AppColors.destructive,
        ),
      );
      return;
    }

    // Verify OTP to get otpToken
    final otpToken = await auth.verifyOtp(
      _phoneController.text.trim(),
      _otpController.text.trim(),
      purpose: 'register',
    );

    if (otpToken != null && mounted) {
      final registered = await auth.register(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        otpToken: otpToken,
      );

      if (registered && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          (route) => false,
        );
      } else if (mounted && auth.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage!),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } else if (mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24 * fontScale),
          onPressed: () {
            if (_isOtpStep) {
              setState(() {
                _isOtpStep = false;
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
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
              child: _isOtpStep ? _buildOtpView(app, auth, fontScale, isDark) : _buildFormView(app, auth, fontScale, isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(AppProvider app, AuthProvider auth, double fontScale, bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            app.tr('signUp'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26 * fontScale,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 6 * fontScale),
          Text(
            app.tr('registerSubtitle'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15 * fontScale,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          SizedBox(height: 24 * fontScale),

          // Name
          ElderTextField(
            label: app.tr('landlordName'),
            hintText: app.tr('namePlaceholder'),
            controller: _nameController,
            prefixIcon: Icons.person_outline,
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return app.tr('landlordName');
              }
              return null;
            },
          ),
          SizedBox(height: 16 * fontScale),

          // Phone
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
          SizedBox(height: 16 * fontScale),

          // Password
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
          SizedBox(height: 16 * fontScale),

          // Confirm Password
          ElderTextField(
            label: app.tr('confirmPassword'),
            hintText: '••••••••',
            controller: _confirmPasswordController,
            obscureText: _obscurePassword,
            prefixIcon: Icons.lock_clock_outlined,
            validator: (val) {
              if (val == null || val.length < 6) {
                return app.tr('confirmPassword');
              }
              return null;
            },
          ),
          SizedBox(height: 16 * fontScale),

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

          // Register / Send OTP button
          ElderButton(
            label: app.tr('register'),
            icon: Icons.person_add_rounded,
            isLoading: auth.isLoading,
            onPressed: _handleSendOtp,
          ),
          SizedBox(height: 20 * fontScale),

          // Back to login
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                app.tr('hasAccount'),
                style: TextStyle(
                  fontSize: 14.5 * fontScale,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  app.tr('signIn'),
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
    );
  }

  Widget _buildOtpView(AppProvider app, AuthProvider auth, double fontScale, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 72 * fontScale,
            height: 72 * fontScale,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.mark_email_read_outlined,
                size: 38 * fontScale,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        SizedBox(height: 20 * fontScale),
        Text(
          app.tr('verifyOtp'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24 * fontScale,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        SizedBox(height: 8 * fontScale),
        Text(
          '${app.tr('otpSentTo')} ${_phoneController.text}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15 * fontScale,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
        SizedBox(height: 28 * fontScale),

        // 6-digit OTP Field
        ElderTextField(
          label: app.tr('otpRequired'),
          hintText: '1 2 3 4 5 6',
          controller: _otpController,
          keyboardType: TextInputType.number,
          prefixIcon: Icons.security,
        ),
        SizedBox(height: 24 * fontScale),

        // Verify button
        ElderButton(
          label: app.tr('verifyBtn'),
          icon: Icons.check_circle_outline,
          isLoading: auth.isLoading,
          onPressed: _handleVerifyAndRegister,
        ),
        SizedBox(height: 20 * fontScale),

        // Resend Timer
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_resendTimer > 0)
              Text(
                '${app.tr('resendIn')} $_resendTimer ${app.tr('seconds')}',
                style: TextStyle(
                  fontSize: 14.5 * fontScale,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              )
            else
              TextButton.icon(
                onPressed: _handleSendOtp,
                icon: Icon(Icons.refresh, size: 18 * fontScale),
                label: Text(
                  app.tr('resendOtp'),
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
    );
  }
}
