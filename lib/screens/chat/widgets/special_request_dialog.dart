import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/chat_provider.dart';

class SpecialRequestDialog extends ConsumerStatefulWidget {
  final Function(String) onRequestSelected;

  const SpecialRequestDialog({
    super.key,
    required this.onRequestSelected,
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
              'Special Requests',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Select a request or create your own',
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
                      hintText: 'Enter your special request...',
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
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _submitCustomRequest,
                        child: const Text('Submit'),
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
                    child: const Text('Create Custom Request'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}