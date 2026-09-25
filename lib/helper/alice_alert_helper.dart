import 'package:flutter/material.dart';
import 'package:flutter_alice/theme/theme.dart';

class AliceAlertHelper {
  AliceAlertHelper._();

  /// Helper method used to open dialog with given title and description.
  static void showAlert(
    BuildContext context,
    String title,
    String description, {
    String firstButtonTitle = "Accept",
    String? secondButtonTitle,
    VoidCallback? firstButtonAction,
    VoidCallback? secondButtonAction,
    Brightness? brightness,
  }) {
    final List<Widget> actions = [
      AliceButton(
        text: firstButtonTitle,
        isOutlined: secondButtonTitle != null,
        onPressed: () {
          firstButtonAction?.call();
          Navigator.of(context).pop();
        },
      ),
    ];
    if (secondButtonTitle != null) {
      actions.add(
        AliceButton(
          text: secondButtonTitle,
          onPressed: () {
            secondButtonAction?.call();
            Navigator.of(context).pop();
          },
        ),
      );
    }
    showDialog<void>(
      context: context,
      builder: (_) => Theme(
        data: aliceTheme,
        child: AlertDialog(
          title: Text(title, style: AliceStyles.titleMedium),
          content: Text(description, style: AliceStyles.body),
          actions: actions,
        ),
      ),
    );
  }
}
