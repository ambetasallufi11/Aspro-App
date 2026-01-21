import 'package:flutter/material.dart';

class BookingStepIndicator extends StatelessWidget {
    final int currentStep;
    final List<String> steps;

    const BookingStepIndicator({
        super.key,
        required this.currentStep,
        required this.steps,
    });

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);
        final primaryColor = const Color(0xFF2196F3); // Material Blue 500

        return Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
                children: [
                    Row(
                        children: List.generate(steps.length, (index) {
                            final isActive = index <= currentStep;
                            final isCompleted = index < currentStep;
                            
                            return Expanded(
                                child: Row(
                                    children: [
                                        if (index > 0)
                                            Expanded(
                                                child: Container(
                                                    height: 2,
                                                    color: isActive 
                                                        ? primaryColor 
                                                        : Colors.grey.shade300,
                                                ),
                                            ),
                                        Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                                color: isActive 
                                                    ? primaryColor 
                                                    : Colors.grey.shade200,
                                                shape: BoxShape.circle,
                                                border: isActive 
                                                    ? null 
                                                    : Border.all(color: Colors.grey.shade300),
                                                boxShadow: isActive 
                                                    ? [
                                                        BoxShadow(
                                                            color: primaryColor.withOpacity(0.3),
                                                            blurRadius: 8,
                                                            offset: const Offset(0, 2),
                                                        )
                                                    ] 
                                                    : null,
                                            ),
                                            child: Center(
                                                child: isCompleted
                                                    ? const Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                        size: 16,
                                                    )
                                                    : Text(
                                                        '${index + 1}',
                                                        style: TextStyle(
                                                            color: isActive 
                                                                ? Colors.white 
                                                                : Colors.grey.shade600,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 14,
                                                        ),
                                                    ),
                                            ),
                                        ),
                                        if (index < steps.length - 1)
                                            Expanded(
                                                child: Container(
                                                    height: 2,
                                                    color: isActive && index < currentStep
                                                        ? primaryColor 
                                                        : Colors.grey.shade300,
                                                ),
                                            ),
                                    ],
                                ),
                            );
                        }),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(steps.length, (index) {
                            final isActive = index <= currentStep;
                            
                            return Expanded(
                                child: Text(
                                    steps[index],
                                    textAlign: index == 0 
                                        ? TextAlign.start 
                                        : (index == steps.length - 1 
                                            ? TextAlign.end 
                                            : TextAlign.center),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        color: isActive 
                                            ? primaryColor 
                                            : Colors.grey.shade600,
                                        fontWeight: isActive 
                                            ? FontWeight.w600 
                                            : FontWeight.normal,
                                    ),
                                ),
                            );
                        }),
                    ),
                ],
            ),
        );
    }
}
