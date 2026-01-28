import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/promo_code.dart';
import '../../providers/promo_code_provider.dart';
import '../../data/mock/mock_data.dart';

class PromoCodeGeneratorScreen extends ConsumerStatefulWidget {
  final String merchantId;

  const PromoCodeGeneratorScreen({
    super.key,
    required this.merchantId,
  });

  @override
  ConsumerState<PromoCodeGeneratorScreen> createState() => _PromoCodeGeneratorScreenState();
}

class _PromoCodeGeneratorScreenState extends ConsumerState<PromoCodeGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();
  final _usageLimitController = TextEditingController();
  
  PromoCodeType _type = PromoCodeType.percentage;
  DateTime? _expirationDate;
  bool _isForRecurringCustomers = false;
  bool _isGenerating = false;

  @override
  void dispose() {
    _codeController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  Future<void> _selectExpirationDate() async {
    final now = DateTime.now();
    final initialDate = _expirationDate ?? now.add(const Duration(days: 30));
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _expirationDate = pickedDate;
      });
    }
  }

  void _generatePromoCode() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    // Simulate API call
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      // Create a new promo code
      final newPromoCode = PromoCode(
        id: 'p${MockData.promoCodes.length + 1}',
        code: _codeController.text.toUpperCase(),
        merchantId: widget.merchantId,
        type: _type,
        value: double.parse(_valueController.text),
        description: _descriptionController.text,
        expirationDate: _expirationDate,
        usageLimit: _usageLimitController.text.isNotEmpty
            ? int.parse(_usageLimitController.text)
            : null,
        isForRecurringCustomers: _isForRecurringCustomers,
      );

      // Add to mock data
      MockData.promoCodes.add(newPromoCode);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Promo code ${newPromoCode.code} created successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset form
      _codeController.clear();
      _descriptionController.clear();
      _valueController.clear();
      _usageLimitController.clear();
      setState(() {
        _type = PromoCodeType.percentage;
        _expirationDate = null;
        _isForRecurringCustomers = false;
        _isGenerating = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Promo Code'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Merchant info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.store,
                      color: primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Merchant',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            MockData.laundries
                                .firstWhere((l) => l.id == widget.merchantId)
                                .name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Promo code form
              Text(
                'Promo Code Details',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              // Code
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Code',
                  hintText: 'e.g., WELCOME10, SUMMER20',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a promo code';
                  }
                  if (value.length < 3) {
                    return 'Code must be at least 3 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g., Welcome discount for new customers',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Type
              DropdownButtonFormField<PromoCodeType>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Discount Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: PromoCodeType.percentage,
                    child: Text('Percentage (%)'),
                  ),
                  DropdownMenuItem(
                    value: PromoCodeType.fixedAmount,
                    child: Text('Fixed Amount (\$)'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _type = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Value
              TextFormField(
                controller: _valueController,
                decoration: InputDecoration(
                  labelText: 'Value',
                  hintText: _type == PromoCodeType.percentage ? 'e.g., 10, 20' : 'e.g., 5, 10',
                  border: const OutlineInputBorder(),
                  prefixText: _type == PromoCodeType.fixedAmount ? '\$ ' : null,
                  suffixText: _type == PromoCodeType.percentage ? '%' : null,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  final doubleValue = double.tryParse(value);
                  if (doubleValue == null) {
                    return 'Please enter a valid number';
                  }
                  if (doubleValue <= 0) {
                    return 'Value must be greater than 0';
                  }
                  if (_type == PromoCodeType.percentage && doubleValue > 100) {
                    return 'Percentage cannot exceed 100%';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Expiration date
              GestureDetector(
                onTap: _selectExpirationDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Expiration Date (Optional)',
                      hintText: 'Select a date',
                      border: const OutlineInputBorder(),
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: primaryColor,
                      ),
                    ),
                    controller: TextEditingController(
                      text: _expirationDate != null
                          ? DateFormat('MMM d, yyyy').format(_expirationDate!)
                          : '',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Usage limit
              TextFormField(
                controller: _usageLimitController,
                decoration: const InputDecoration(
                  labelText: 'Usage Limit (Optional)',
                  hintText: 'e.g., 100, 1000',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null; // Optional field
                  }
                  final intValue = int.tryParse(value);
                  if (intValue == null) {
                    return 'Please enter a valid number';
                  }
                  if (intValue <= 0) {
                    return 'Limit must be greater than 0';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // For recurring customers
              CheckboxListTile(
                title: const Text('For recurring customers only'),
                value: _isForRecurringCustomers,
                onChanged: (value) {
                  setState(() {
                    _isForRecurringCustomers = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 24),

              // Generate button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : _generatePromoCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isGenerating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Generate Promo Code'),
                ),
              ),

              const SizedBox(height: 24),

              // Existing promo codes
              Text(
                'Existing Promo Codes',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              // List of promo codes
              Consumer(
                builder: (context, ref, child) {
                  final promoCodes = ref.watch(promoCodesProvider);
                  final merchantCodes = promoCodes
                      .where((code) => code.merchantId == widget.merchantId)
                      .toList();

                  if (merchantCodes.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No promo codes yet',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: merchantCodes.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final code = merchantCodes[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          code.code,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(code.description),
                            const SizedBox(height: 4),
                            Text(
                              code.type == PromoCodeType.percentage
                                  ? '${code.value.toStringAsFixed(0)}% off'
                                  : '\$${code.value.toStringAsFixed(2)} off',
                              style: TextStyle(
                                color: code.isValid
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (code.expirationDate != null)
                              Text(
                                'Expires: ${DateFormat('MMM d, yyyy').format(code.expirationDate!)}',
                                style: theme.textTheme.bodySmall,
                              ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: code.isValid
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                code.isValid ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: code.isValid
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}