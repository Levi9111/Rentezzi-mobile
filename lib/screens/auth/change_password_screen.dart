import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/elder_button.dart';
import '../../widgets/elder_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _step = 1; // 1 = Phone, 2 = OTP, 3 = New Password
  String? _otpToken;
  int _resendTimer = 30;
  Timer? _timer;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _resendTimer = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _handleSendOtp() async {
    final app = context.read<AppProvider>();
    final auth = context.read<AuthProvider>();

    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(app.tr('phoneHint')), backgroundColor: AppColors.destructive),
      );
      return;
    }

    final success = await auth.sendOtp(_phoneController.text.trim(), purpose: 'forgot-password');
    if (success && mounted) {
      setState(() => _step = 2);
      _startTimer();
    } else if (mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage!), backgroundColor: AppColors.destructive),
      );
    }
  }

  Future<void> _handleVerifyOtp() async {
    final app = context.read<AppProvider>();
    final auth = context.read<AuthProvider>();

    if (_otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(app.tr('otpRequired')), backgroundColor: AppColors.destructive),
      );
      return;
    }

    final token = await auth.verifyOtp(
      _phoneController.text.trim(),
      _otpController.text.trim(),
      purpose: 'forgot-password',
    );

    if (token != null && mounted) {
      setState(() {
        _otpToken = token;
        _step = 3;
      });
    } else if (mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage!), backgroundColor: AppColors.destructive),
      );
    }
  }

  Future<void> _handleChangePassword() async {
    final app = context.read<AppProvider>();
    final auth = context.read<AuthProvider>();

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(app.tr('password')), backgroundColor: AppColors.destructive),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(app.tr('confirmPassword')), backgroundColor: AppColors.destructive),
      );
      return;
    }

    if (_otpToken == null) return;

    final success = await auth.changePassword(
      newPassword: _newPasswordController.text,
      otpToken: _otpToken!,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(app.tr('passwordChanged')), backgroundColor: AppColors.success),
      );
      Navigator.of(context).pop();
    } else if (mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage!), backgroundColor: AppColors.destructive),
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
        title: Text(app.tr('changePassword')),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24 * fontScale, vertical: 16 * fontScale),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: _buildCurrentStep(app, auth, fontScale, isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(AppProvider app, AuthProvider auth, double fontScale, bool isDark) {
    if (_step == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            app.tr('changePassword'),
            style: TextStyle(
              fontSize: 22 * fontScale,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 6 * fontScale),
          Text(
            app.tr('changePasswordDesc'),
            style: TextStyle(fontSize: 14.5 * fontScale, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
          ),
          SizedBox(height: 24 * fontScale),
          ElderTextField(
            label: app.tr('phone'),
            hintText: app.tr('phoneHint'),
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
          ),
          SizedBox(height: 24 * fontScale),
          ElderButton(
            label: app.tr('sendOtpBtn'),
            icon: Icons.send_rounded,
            isLoading: auth.isLoading,
            onPressed: _handleSendOtp,
          ),
        ],
      );
    } else if (_step == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            app.tr('verifyOtp'),
            style: TextStyle(
              fontSize: 22 * fontScale,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 6 * fontScale),
          Text(
            '${app.tr('otpSentTo')} ${_phoneController.text}',
            style: TextStyle(fontSize: 14.5 * fontScale, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
          ),
          SizedBox(height: 24 * fontScale),
          ElderTextField(
            label: app.tr('otpRequired'),
            hintText: '1 2 3 4 5 6',
            controller: _otpController,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.security,
          ),
          SizedBox(height: 24 * fontScale),
          ElderButton(
            label: app.tr('verifyBtn'),
            icon: Icons.check_circle_outline,
            isLoading: auth.isLoading,
            onPressed: _handleVerifyOtp,
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            app.tr('setNewPassword'),
            style: TextStyle(
              fontSize: 22 * fontScale,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 24 * fontScale),
          ElderTextField(
            label: app.tr('newPassword'),
            hintText: '••••••••',
            controller: _newPasswordController,
            obscureText: _obscurePassword,
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          SizedBox(height: 16 * fontScale),
          ElderTextField(
            label: app.tr('confirmPassword'),
            hintText: '••••••••',
            controller: _confirmPasswordController,
            obscureText: _obscurePassword,
            prefixIcon: Icons.lock_clock_outlined,
          ),
          SizedBox(height: 24 * fontScale),
          ElderButton(
            label: app.tr('confirm'),
            icon: Icons.check,
            isLoading: auth.isLoading,
            onPressed: _handleChangePassword,
          ),
        ],
      );
    }
  }
}
