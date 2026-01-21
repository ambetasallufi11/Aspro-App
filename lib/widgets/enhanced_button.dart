import 'package:flutter/material.dart';

class EnhancedButton extends StatelessWidget {
    final String label;
    final VoidCallback onPressed;
    final bool isOutlined;
    final bool isFullWidth;
    final IconData? icon;

    const EnhancedButton({
        super.key,
        required this.label,
        required this.onPressed,
        this.isOutlined = false,
        this.isFullWidth = true,
        this.icon,
    });

    @override
    Widget build(BuildContext context) {
        final primaryColor = const Color(0xFF2196F3); // Material Blue 500

        final buttonStyle = isOutlined
            ? OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor, width: 2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            )
            : ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: primaryColor.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            );

        final buttonChild = Row(
            mainAxisSize: MainAxisSize.min,
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

        final button = isOutlined
            ? OutlinedButton(
                onPressed: onPressed,
                style: buttonStyle,
                child: buttonChild,
            )
            : ElevatedButton(
                onPressed: onPressed,
                style: buttonStyle,
                child: buttonChild,
            );

        return isFullWidth
            ? SizedBox(width: double.infinity, child: button)
            : button;
    }
}
