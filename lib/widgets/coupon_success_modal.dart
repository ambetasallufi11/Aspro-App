import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';

class CouponSuccessModal extends StatefulWidget {
  final String couponCode;
  final String merchantId;
  final VoidCallback? onDismiss;

  const CouponSuccessModal({
    super.key,
    required this.couponCode,
    required this.merchantId,
    this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required String couponCode,
    required String merchantId,
    VoidCallback? onDismiss,
  }) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return CouponSuccessModal(
          couponCode: couponCode,
          merchantId: merchantId,
          onDismiss: onDismiss,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.elasticOut,
            ),
          ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<CouponSuccessModal> createState() => _CouponSuccessModalState();
}

class _CouponSuccessModalState extends State<CouponSuccessModal> with SingleTickerProviderStateMixin {
  late AnimationController _confettiController;
  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Generate confetti particles
    for (int i = 0; i < 50; i++) {
      _particles.add(_ConfettiParticle(
        position: Offset(_random.nextDouble() * 400 - 200, -50),
        color: _getRandomColor(),
        size: _random.nextDouble() * 10 + 5,
        velocity: Offset(_random.nextDouble() * 6 - 3, _random.nextDouble() * 3 + 2),
        rotation: _random.nextDouble() * 2 * pi,
        rotationSpeed: _random.nextDouble() * 0.2 - 0.1,
      ));
    }

    _confettiController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        if (widget.onDismiss != null) {
          widget.onDismiss!();
        }
      },
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent taps from closing the modal when tapping on the card
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Confetti animation
                  SizedBox(
                    height: 150,
                    width: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Badge background
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryColor.withOpacity(0.8),
                                primaryColor,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                        ),
                        
                        // Star shape
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                        
                        // Confetti animation
                        AnimatedBuilder(
                          animation: _confettiController,
                          builder: (context, child) {
                            for (var particle in _particles) {
                              particle.update(_confettiController.value);
                            }
                            return CustomPaint(
                              size: const Size(300, 300),
                              painter: _ConfettiPainter(particles: _particles),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Congratulations text
                  Text(
                    context.l10n.t('Congratulations'),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    context.l10n.t('Coupon ${widget.couponCode} redeemed successfully!'),
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Book button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (widget.onDismiss != null) {
                          widget.onDismiss!();
                        }
                        context.push('/laundry?id=${widget.merchantId}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        context.l10n.t('Book'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Confetti particle class
class _ConfettiParticle {
  Offset position;
  final Color color;
  final double size;
  final Offset velocity;
  double rotation;
  final double rotationSpeed;

  _ConfettiParticle({
    required this.position,
    required this.color,
    required this.size,
    required this.velocity,
    required this.rotation,
    required this.rotationSpeed,
  });

  void update(double progress) {
    position += velocity * 10 * progress;
    rotation += rotationSpeed;
  }
}

// Confetti painter
class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;

  _ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    for (var particle in particles) {
      final paint = Paint()..color = particle.color;
      
      canvas.save();
      canvas.translate(center.dx + particle.position.dx, center.dy + particle.position.dy);
      canvas.rotate(particle.rotation);
      
      // Draw a rectangle for confetti
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size * 0.8),
        paint,
      );
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}