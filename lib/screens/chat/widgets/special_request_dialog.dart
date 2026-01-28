import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/chat_provider.dart';

class SpecialRequestDialog extends ConsumerStatefulWidget {
  final Function(String) onRequestSelected;
  final bool isSupport;

  const SpecialRequestDialog({
    super.key,
    required this.onRequestSelected,
    this.isSupport = false,
  });

  @override
  ConsumerState<SpecialRequestDialog> createState() => _SpecialRequestDialogState();
}

class _SpecialRequestDialogState extends ConsumerState<SpecialRequestDialog> {
  final TextEditingController _customRequestController = TextEditingController();
  bool _isCustomRequest = false;

  @override
  void dispose() {
    _customRequestController.dispose();
    super.dispose();
  }

  void _selectRequest(String request) {
    widget.onRequestSelected(request);
    Navigator.of(context).pop();
  }

  void _submitCustomRequest() {
    final request = _customRequestController.text.trim();
    if (request.isNotEmpty) {
      widget.onRequestSelected(request);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final templates = ref.watch(specialRequestTemplatesProvider);
    final theme = Theme.of(context);
    
    final dialogTitle = context.l10n.t('Special Requests');
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              dialogTitle,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.t('Select a request or create your own'),
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_isCustomRequest)
              Column(
                children: [
                  TextField(
                    controller: _customRequestController,
                    decoration: InputDecoration(
                      hintText: context.l10n.t('Enter your special request...'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isCustomRequest = false;
                          });
                        },
                        child: Text(context.l10n.t('Cancel')),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _submitCustomRequest,
                        child: Text(context.l10n.t('Submit')),
                      ),
                    ],
                  ),
                ],
              )
            else
              Column(
                children: [
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: templates.length,
                      itemBuilder: (context, index) {
                        final template = templates[index];
                        return ListTile(
                          title: Text(template),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onTap: () => _selectRequest(template),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isCustomRequest = true;
                      });
                    },
                    child: Text(widget.isSupport 
                        ? context.l10n.t('Create Custom Question')
                        : context.l10n.t('Create Custom Request')),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
