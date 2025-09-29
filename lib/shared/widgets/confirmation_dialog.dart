import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final Color? confirmColor;
  final bool isConfirming;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.confirmColor,
    this.isConfirming = false,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    String? cancelText,
    Color? confirmColor,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText ?? '',
        confirmColor: confirmColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(maxWidth: screenWidth * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            if (title.isNotEmpty) ...[
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],

            // Message
            Text(
              message,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(cancelText),
                ),

                const SizedBox(width: 12),

                // Confirm Button
                ElevatedButton(
                  onPressed: isConfirming
                      ? null
                      : () {
                          if (onConfirm != null) {
                            onConfirm!();
                          } else {
                            Navigator.of(context).pop(true);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: confirmColor ?? theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isConfirming
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          confirmText,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
