import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isOutlined;
  final bool useGradient;
  final IconData? icon;
  final double? height;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isOutlined = false,
    this.useGradient = true,
    this.icon,
    this.height,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (isOutlined) {
      return _buildOutlinedButton(colorScheme);
    } else if (useGradient) {
      return _buildGradientButton(colorScheme);
    } else {
      return _buildFilledButton(colorScheme);
    }
  }
  
  Widget _buildFilledButton(ColorScheme colorScheme) {
    final style = FilledButton.styleFrom(
      backgroundColor: colorScheme.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(vertical: 16),
      elevation: 2,
      shadowColor: colorScheme.primary.withOpacity(0.4),
    );

    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: _buildButtonContent(false),
      ),
    );
  }
  
  Widget _buildOutlinedButton(ColorScheme colorScheme) {
    final style = OutlinedButton.styleFrom(
      foregroundColor: colorScheme.primary,
      side: BorderSide(color: colorScheme.primary, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(vertical: 16),
    );

    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: _buildButtonContent(false),
      ),
    );
  }
  
  Widget _buildGradientButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
        color: Colors.transparent,
        elevation: 2,
        shadowColor: colorScheme.primary.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: _buildButtonContent(true),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildButtonContent(bool isGradient) {
    if (isLoading) {
      return Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              isGradient || !isOutlined ? Colors.white : Colors.blue,
            ),
          ),
        ),
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
