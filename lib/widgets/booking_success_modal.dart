import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:aspro_app/l10n/app_localizations.dart';
import '../utils/service_localization.dart';

class BookingSuccessModal extends StatefulWidget {
    final String orderNumber;
    final Set<String> services;
    final String pickupTime;
    final String deliveryTime;
    final String address;
    final VoidCallback onViewOrders;
    final VoidCallback onDone;

    const BookingSuccessModal({
        super.key,
        required this.orderNumber,
        required this.services,
        required this.pickupTime,
        required this.deliveryTime,
        required this.address,
        required this.onViewOrders,
        required this.onDone,
    });

    @override
    State<BookingSuccessModal> createState() => _BookingSuccessModalState();
}

class _BookingSuccessModalState extends State<BookingSuccessModal> with SingleTickerProviderStateMixin {
    late AnimationController _controller;
    late Animation<double> _scaleAnimation;
    late Animation<double> _fadeAnimation;
    late Animation<double> _checkAnimation;

    @override
    void initState() {
        super.initState();
        
        _controller = AnimationController(
            duration: const Duration(milliseconds: 800),
            vsync: this,
        );
        
        _scaleAnimation = CurvedAnimation(
            parent: _controller,
            curve: Curves.elasticOut,
        );
        
        _fadeAnimation = CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
        );
        
        _checkAnimation = CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
        );
        
        _controller.forward();
    }

    @override
    void dispose() {
        _controller.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        final primaryColor = const Color(0xFF2196F3); // Material Blue 500
        final theme = Theme.of(context);
        final l10n = AppLocalizations.of(context)!;
        
        return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                    return Transform.scale(
                        scale: _scaleAnimation.value * 0.3 + 0.7,
                        child: Opacity(
                            opacity: _fadeAnimation.value * 0.5 + 0.5,
                            child: child,
                        ),
                    );
                },
                child: Container(
                    padding: const EdgeInsets.all(24),
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            // Success icon
                            AnimatedBuilder(
                                animation: _checkAnimation,
                                builder: (context, child) {
                                    return Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                            color: primaryColor.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                            child: Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                    color: primaryColor,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                        BoxShadow(
                                                            color: primaryColor.withOpacity(0.3),
                                                            blurRadius: 12,
                                                            offset: const Offset(0, 4),
                                                        ),
                                                    ],
                                                ),
                                                child: Center(
                                                    child: CustomPaint(
                                                        size: const Size(30, 30),
                                                        painter: CheckmarkPainter(
                                                            progress: _checkAnimation.value,
                                                            color: Colors.white,
                                                            strokeWidth: 3,
                                                        ),
                                                    ),
                                                ),
                                            ),
                                        ),
                                    );
                                },
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Success message
                            Text(
                                l10n.bookingSuccessTitle,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                ),
                                textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                                l10n.bookingSuccessSubtitle,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey.shade700,
                                ),
                                textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 4),
                            
                            Text(
                                l10n.orderNumberLabel(widget.orderNumber),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Booking details
                            Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        // Services
                                        Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Icon(
                                                    Icons.local_laundry_service,
                                                    color: primaryColor,
                                                    size: 18,
                                                ),
                                                
                                                const SizedBox(width: 8),
                                                
                                                Expanded(
                                                    child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                            Text(
                                                                l10n.servicesLabel,
                                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                                    fontWeight: FontWeight.w600,
                                                                ),
                                                            ),
                                                            
                                                            const SizedBox(height: 4),
                                                            
                                                            Text(
                                                                widget.services
                                                                    .map((service) => localizeServiceName(l10n, service))
                                                                    .join(', '),
                                                                style: theme.textTheme.bodyMedium,
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ],
                                        ),
                                        
                                        const SizedBox(height: 12),
                                        
                                        // Pickup time
                                        Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Icon(
                                                    Icons.access_time,
                                                    color: primaryColor,
                                                    size: 18,
                                                ),
                                                
                                                const SizedBox(width: 8),
                                                
                                                Expanded(
                                                    child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                            Text(
                                                                l10n.pickupLabel,
                                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                                    fontWeight: FontWeight.w600,
                                                                ),
                                                            ),
                                                            
                                                            const SizedBox(height: 4),
                                                            
                                                            Text(
                                                                widget.pickupTime,
                                                                style: theme.textTheme.bodyMedium,
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ],
                                        ),
                                        
                                        const SizedBox(height: 12),
                                        
                                        // Delivery time
                                        Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Icon(
                                                    Icons.delivery_dining,
                                                    color: primaryColor,
                                                    size: 18,
                                                ),
                                                
                                                const SizedBox(width: 8),
                                                
                                                Expanded(
                                                    child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                            Text(
                                                                l10n.deliveryLabel,
                                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                                    fontWeight: FontWeight.w600,
                                                                ),
                                                            ),
                                                            
                                                            const SizedBox(height: 4),
                                                            
                                                            Text(
                                                                widget.deliveryTime,
                                                                style: theme.textTheme.bodyMedium,
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ],
                                        ),
                                        
                                        const SizedBox(height: 12),
                                        
                                        // Address
                                        Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Icon(
                                                    Icons.location_on,
                                                    color: primaryColor,
                                                    size: 18,
                                                ),
                                                
                                                const SizedBox(width: 8),
                                                
                                                Expanded(
                                                    child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                            Text(
                                                                l10n.addressLabel,
                                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                                    fontWeight: FontWeight.w600,
                                                                ),
                                                            ),
                                                            
                                                            const SizedBox(height: 4),
                                                            
                                                            Text(
                                                                widget.address,
                                                                style: theme.textTheme.bodyMedium,
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ],
                                ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Action buttons
                            Row(
                                children: [
                                    Expanded(
                                        child: OutlinedButton(
                                            onPressed: widget.onViewOrders,
                                            style: OutlinedButton.styleFrom(
                                                foregroundColor: primaryColor,
                                                side: BorderSide(color: primaryColor),
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                ),
                                            ),
                                            child: Text(l10n.viewMyOrders),
                                        ),
                                    ),
                                    
                                    const SizedBox(width: 12),
                                    
                                    Expanded(
                                        child: ElevatedButton(
                                            onPressed: widget.onDone,
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: primaryColor,
                                                foregroundColor: Colors.white,
                                                elevation: 2,
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                ),
                                            ),
                                            child: Text(l10n.done),
                                        ),
                                    ),
                                ],
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}

class CheckmarkPainter extends CustomPainter {
    final double progress;
    final Color color;
    final double strokeWidth;

    CheckmarkPainter({
        required this.progress,
        required this.color,
        required this.strokeWidth,
    });

    @override
    void paint(Canvas canvas, Size size) {
        final Paint paint = Paint()
            ..color = color
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke;

        final double firstLineProgress = math.min(1.0, progress * 2);
        final double secondLineProgress = math.max(0.0, (progress - 0.5) * 2);

        // First line of the checkmark (shorter line)
        if (firstLineProgress > 0) {
            canvas.drawLine(
                Offset(size.width * 0.2, size.height * 0.5),
                Offset(
                    size.width * 0.2 + (size.width * 0.2) * firstLineProgress,
                    size.height * 0.5 + (size.height * 0.2) * firstLineProgress,
                ),
                paint,
            );
        }

        // Second line of the checkmark (longer line)
        if (secondLineProgress > 0) {
            canvas.drawLine(
                Offset(size.width * 0.4, size.height * 0.7),
                Offset(
                    size.width * 0.4 + (size.width * 0.4) * secondLineProgress,
                    size.height * 0.7 - (size.height * 0.4) * secondLineProgress,
                ),
                paint,
            );
        }
    }

    @override
    bool shouldRepaint(CheckmarkPainter oldDelegate) {
        return oldDelegate.progress != progress ||
            oldDelegate.color != color ||
            oldDelegate.strokeWidth != strokeWidth;
    }
}
