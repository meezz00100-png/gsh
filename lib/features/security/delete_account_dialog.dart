import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/shared/localization/app_localizations.dart';

class DeleteAccountDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  const DeleteAccountDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.translate('deleteAccount')),
      content: Text(context.translate('deleteAccountConfirmation')),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.translate('cancel')),
        ),
        TextButton(
          onPressed: onConfirm,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text(context.translate('delete')),
        ),
      ],
    );
  }
}
