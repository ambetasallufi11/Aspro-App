import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/laundry.dart';
import '../../models/promo_code.dart';
import '../../providers/chat_provider.dart';
import '../../providers/api_providers.dart';
import '../../providers/promo_code_provider.dart';
import '../../widgets/primary_button.dart';

class LaundryDetailsScreen extends ConsumerWidget {
  final String? laundryId;

  const LaundryDetailsScreen({super.key, required this.laundryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final laundriesAsync = ref.watch(laundriesProvider);
    final servicesAsync = ref.watch(servicesProvider);
    if (laundriesAsync.isLoading || servicesAsync.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (laundriesAsync.hasError || servicesAsync.hasError) {
      return Scaffold(
        body: Center(
          child: Text(
            'Failed to load laundry: ${laundriesAsync.error ?? servicesAsync.error}',
          ),
        ),
      );
    }

    final laundries = laundriesAsync.value ?? [];
    final services = servicesAsync.value ?? [];
    if (laundries.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No laundries found')),
      );
    }
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
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: context.l10n.t('Book Pickup'),
                  onPressed: () => context.push('/booking'),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.chat_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () async {
                    // Create a conversation with this merchant and navigate to chat
                    await ref.read(chatProvider.notifier).createConversation(laundry);
                    context.push('/chat');
                  },
                  tooltip: context.l10n.t('Chat with Merchant'),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.discount_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    context.push('/merchant/promo-codes?merchantId=${laundry.id}');
                  },
                  tooltip: context.l10n.t('Manage Promo Codes'),
                ),
              ),
            ],
          ),
          
          // Merchant promo codes section
          const SizedBox(height: 24),
          Consumer(
            builder: (context, ref, child) {
              final promoCodes = ref.watch(promoCodesProvider);
              final merchantCodes = promoCodes
                  .where((code) => code.merchantId == laundry.id && code.isValid)
                  .toList();
                  
              if (merchantCodes.isEmpty) {
                return const SizedBox.shrink();
              }
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.t('Available Promo Codes'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: merchantCodes.map((code) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.discount,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      code.code,
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Text(
                                      context.l10n.t(code.description),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                code.type == PromoCodeType.percentage
                                    ? '${code.value.toStringAsFixed(0)}% off'
                                    : '\$${code.value.toStringAsFixed(2)} off',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
