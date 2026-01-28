import 'package:flutter/material.dart';

import '../models/order.dart';

class StatusTimeline extends StatelessWidget {
  final OrderStatus status;

  const StatusTimeline({super.key, required this.status});

  int get _currentIndex {
    switch (status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.pickedUp:
        return 1;
      case OrderStatus.washing:
        return 2;
      case OrderStatus.ready:
        return 3;
      case OrderStatus.delivered:
        return 4;
      case OrderStatus.cancelled:
        return -1; // Special case for cancelled orders
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      'Pending',
      'Picked up',
      'Washing',
      'Ready',
      'Delivered',
    ];

    // Special case for cancelled orders
    if (status == OrderStatus.cancelled) {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Cancelled',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              'This order has been cancelled',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: List.generate(steps.length, (index) {
        final isActive = index <= _currentIndex;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
                if (index != steps.length - 1)
                  Container(
                    width: 2,
                    height: 32,
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade200,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                steps[index],
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
