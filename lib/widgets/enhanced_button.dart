import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EnhancedButton extends StatelessWidget {
    final String label;
    final VoidCallback onPressed;
    final bool isOutlined;
    final bool isFullWidth;
    final IconData? icon;
    final bool useGradient;
    final EdgeInsetsGeometry? padding;
    final double? elevation;

    const EnhancedButton({
        super.key,
        required this.label,
        required this.onPressed,
        this.isOutlined = false,
        this.isFullWidth = true,
        this.icon,
        this.useGradient = true,
        this.padding,
        this.elevation,
    });

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);
        final primaryColor = theme.colorScheme.primary;
        
        // Use default padding or custom padding if provided
        final buttonPadding = padding ?? 
            const EdgeInsets.symmetric(vertical: 16, horizontal: 24);
        
        // Use default elevation or custom elevation if provided
        final buttonElevation = elevation ?? (isOutlined ? 0.0 : 4.0);

        if (isOutlined) {
            return _buildOutlinedButton(primaryColor, buttonPadding, buttonElevation);
        } else {
            return _buildFilledButton(primaryColor, buttonPadding, buttonElevation);
        }
    }
    
    Widget _buildFilledButton(Color primaryColor, EdgeInsetsGeometry buttonPadding, double buttonElevation) {
        if (useGradient) {
            return isFullWidth
                ? SizedBox(width: double.infinity, child: _buildGradientButton(buttonPadding, buttonElevation))
                : _buildGradientButton(buttonPadding, buttonElevation);
        } else {
            final buttonStyle = ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: buttonElevation,
                shadowColor: primaryColor.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                ),
                padding: buttonPadding,
            );
            
            return isFullWidth
                ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: onPressed,
                        style: buttonStyle,
                        child: _buildButtonContent(),
                    ),
                )
                : ElevatedButton(
                    onPressed: onPressed,
                    style: buttonStyle,
                    child: _buildButtonContent(),
                );
        }
    }
    
    Widget _buildOutlinedButton(Color primaryColor, EdgeInsetsGeometry buttonPadding, double buttonElevation) {
        final buttonStyle = OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: BorderSide(color: primaryColor, width: 1.5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
            ),
            padding: buttonPadding,
            elevation: buttonElevation,
        );
        
        return isFullWidth
            ? SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                    onPressed: onPressed,
                    style: buttonStyle,
                    child: _buildButtonContent(),
                ),
            )
            : OutlinedButton(
                onPressed: onPressed,
                style: buttonStyle,
                child: _buildButtonContent(),
            );
    }
    
    Widget _buildGradientButton(EdgeInsetsGeometry buttonPadding, double buttonElevation) {
        return Material(
            color: Colors.transparent,
            elevation: buttonElevation,
            shadowColor: Colors.blue.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(20),
                child: Ink(
                    decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: buttonElevation > 0 
                            ? [
                                BoxShadow(
                                    color: Colors.blue.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                ),
                            ] 
                            : null,
                    ),
                    child: Container(
                        padding: buttonPadding,
                        child: _buildButtonContent(isGradient: true),
                    ),
                ),
            ),
        );
    }
    
    Widget _buildButtonContent({bool isGradient = false}) {
        return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                if (icon != null) ...[
                    Icon(
                        icon, 
                        size: 20,
                        color: isGradient ? Colors.white : null,
                    ),
                    const SizedBox(width: 8),
                ],
                Text(
                    label,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isGradient ? Colors.white : null,
                    ),
                ),
            ],
        );
    }
}
