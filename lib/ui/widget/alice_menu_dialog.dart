import 'package:flutter/material.dart';
import 'package:flutter_alice/model/alice_menu_item.dart';
import 'package:flutter_alice/theme/theme.dart';

class AliceMenuDialog extends StatelessWidget {
  final void Function(AliceMenuItem) _onMenuItemSelected;

  const AliceMenuDialog({
    super.key,
    required void Function(AliceMenuItem) onMenuItemSelected,
  }) : _onMenuItemSelected = onMenuItemSelected;

  static const _menuItems = [
    AliceMenuItem("Clear requests", Icons.delete_outline, AliceMenuAction.clear),
    AliceMenuItem("Statistics", Icons.bar_chart, AliceMenuAction.stats),
    AliceMenuItem("About", Icons.info_outline, AliceMenuAction.about),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _menuItems
              .map(
                (item) => ListTile(
                  leading: Icon(
                    item.iconData,
                    color: AliceColors.primary,
                    size: 24,
                  ),
                  title: Text(item.title, style: AliceStyles.bodyBold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _onMenuItemSelected(item);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
