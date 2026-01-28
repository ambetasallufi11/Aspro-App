import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/promo_code.dart';
import '../../providers/promo_code_provider.dart';
import '../../widgets/coupon_success_modal.dart';

class AvailableCouponsScreen extends ConsumerWidget {
  const AvailableCouponsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promoCodes = ref.watch(promoCodesProvider);
    final validCodes = promoCodes.where((code) => code.isValid).toList();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.t('Available Coupons')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: validCodes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.t('No coupons available'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.t('Check back later for new offers'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  context.l10n.t('Redeem these coupons for discounts on your next order'),
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ...validCodes.map((code) => _CouponCard(code: code)),
              ],
            ),
    );
  }
}

class _CouponCard extends ConsumerStatefulWidget {
  final PromoCode code;

  const _CouponCard({required this.code});

  @override
  ConsumerState<_CouponCard> createState() => _CouponCardState();
}

class _CouponCardState extends ConsumerState<_CouponCard> {
  bool _isRedeeming = false;

  void _redeemCoupon() {
    setState(() {
      _isRedeeming = true;
    });

    // Apply the promo code
    ref.read(appliedPromoCodeProvider.notifier).applyPromoCode(widget.code.code);

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isRedeeming = false;
        });

        // Show animated success modal
        CouponSuccessModal.show(
          context,
          couponCode: widget.code.code,
          merchantId: widget.code.merchantId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Coupon header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.discount,
                  color: primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.code.code,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        context.l10n.t(widget.code.description),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    widget.code.type == PromoCodeType.percentage
                        ? '${widget.code.value.toStringAsFixed(0)}% OFF'
                        : '\$${widget.code.value.toStringAsFixed(2)} OFF',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Coupon details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Merchant name
                Row(
                  children: [
                    Icon(
                      Icons.store,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.t('Valid at: ${_getMerchantName(widget.code.merchantId)}'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Expiration date
                if (widget.code.expirationDate != null)
                  Row(
                    children: [
                      Icon(
                        Icons.event,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${context.l10n.t('Expires')}: ${DateFormat('MMM d, yyyy').format(widget.code.expirationDate!)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 16),

                // Redeem button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _isRedeeming ? null : _redeemCoupon,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isRedeeming
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(context.l10n.t('Redeem Now')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMerchantName(String merchantId) {
    switch (merchantId) {
      case 'l1':
        return 'FreshFold Laundry Co.';
      case 'l2':
        return 'Sunrise Suds';
      case 'l3':
        return 'CloudClean Express';
      default:
        return 'All Merchants';
    }
  }
}