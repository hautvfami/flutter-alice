import 'package:flutter/material.dart';
import 'package:flutter_alice/ui/utils/alice_theme.dart';

class AliceAlertHelper {
  ///Helper method used to open alarm with given title and description.
  static void showAlert(
    BuildContext context,
    String title,
    String description, {
    String firstButtonTitle = "Accept",
    String? secondButtonTitle,
    Function? firstButtonAction,
    Function? secondButtonAction,
    Brightness? brightness,
  }) {
    List<Widget> actions = [];
    actions.add(
      ElevatedButton(
        child: Text(firstButtonTitle),
        onPressed: () {
          if (firstButtonAction != null) firstButtonAction();
          Navigator.of(context).pop();
        },
      ),
    );
    if (secondButtonTitle != null) {
      actions.add(
        ElevatedButton(
          child: Text(secondButtonTitle),
          onPressed: () {
            if (secondButtonAction != null) secondButtonAction();
            Navigator.of(context).pop();
          },
        ),
      );
    }
    showDialog(
      context: context,
      builder: (_) => Theme(
        data: aliceTheme,
        child: AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: actions,
        ),
      ),
    );
  }
}
