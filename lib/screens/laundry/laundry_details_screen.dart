import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/mock_providers.dart';
import '../../widgets/primary_button.dart';

class LaundryDetailsScreen extends ConsumerWidget {
  final String? laundryId;

  const LaundryDetailsScreen({super.key, required this.laundryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final laundries = ref.watch(laundriesProvider);
    final services = ref.watch(servicesProvider);
    final laundry = laundries.firstWhere(
      (item) => item.id == laundryId,
      orElse: () => laundries.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.t('Laundry Details')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: laundry.imageUrl != null
                ? Image.asset(
                    laundry.imageUrl!,
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: Icon(
                      Icons.local_laundry_service,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            laundry.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.star, color: Theme.of(context).colorScheme.primary, size: 18),
              const SizedBox(width: 4),
              Text('${laundry.rating} • ${laundry.distanceKm} km'),
              const SizedBox(width: 12),
              Text(laundry.priceRange),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.t('Services'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: laundry.services
                .map((service) => Chip(label: Text(context.l10n.t(service))))
                .toList(),
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.t('Price list'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          ...services.map(
            (service) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.t(service.name)),
              subtitle: Text(context.l10n.t(service.description)),
              trailing: Text('\$${service.price.toStringAsFixed(0)}'),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.timer_outlined, color: Theme.of(context).colorScheme.primary, size: 18),
              const SizedBox(width: 6),
              Text('${context.l10n.t('Estimated delivery')}: ${context.l10n.t(laundry.eta)}'),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: context.l10n.t('Book Pickup'),
            onPressed: () => context.push('/booking'),
          ),
        ],
      ),
    );
  }
}
