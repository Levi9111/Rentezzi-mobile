import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/services/haptic_service.dart';
import '../providers/app_provider.dart';

class ElderButton extends StatelessWidget {
  final String? label;
  final String? text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isOutlined;
  final double? height;

  const ElderButton({
    super.key,
    this.label,
    this.text,
    this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.isOutlined = false,
    this.height,
  });

  String get _buttonText => text ?? label ?? '';

  void _handlePress() {
    HapticService.selection();
    if (onPressed != null) {
      onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final fontScale = app.fontScale;
    final minHeight = height ?? (54 * fontScale);

    if (isOutlined) {
      return SizedBox(
        width: double.infinity,
        height: minHeight,
        child: OutlinedButton(
          onPressed: (isLoading || onPressed == null) ? null : _handlePress,
          style: OutlinedButton.styleFrom(
            foregroundColor: foregroundColor ?? AppColors.primary,
            side: BorderSide(
              color: backgroundColor ?? AppColors.primary,
              width: 1.8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _buildChild(context, fontScale, foregroundColor ?? AppColors.primary),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: minHeight,
      child: ElevatedButton(
        onPressed: (isLoading || onPressed == null) ? null : _handlePress,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: foregroundColor ?? Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _buildChild(context, fontScale, foregroundColor ?? Colors.white),
      ),
    );
  }

  Widget _buildChild(BuildContext context, double fontScale, Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 24 * fontScale,
        width: 24 * fontScale,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: textColor,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22 * fontScale, color: textColor),
          SizedBox(width: 10 * fontScale),
          Flexible(
            child: Text(
              _buttonText,
              style: TextStyle(
                fontSize: 16.5 * fontScale,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Text(
      _buttonText,
      style: TextStyle(
        fontSize: 16.5 * fontScale,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
