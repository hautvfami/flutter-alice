import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alice/model/alice_menu_item.dart';

class AliceMenuDialog extends StatelessWidget {
  final void Function(AliceMenuItem) _onMenuItemSelected;
  AliceMenuDialog({
    super.key,
    required void Function(AliceMenuItem) onMenuItemSelected,
  }) : _onMenuItemSelected = onMenuItemSelected;
  final _menuItems = [
    AliceMenuItem("Clear requests", CupertinoIcons.trash),
    AliceMenuItem("Statistic", CupertinoIcons.chart_bar),
    AliceMenuItem("About", Icons.contact_emergency)
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _menuItems
              .map(
                (item) => ListTile(
                  leading: Icon(
                    item.iconData,
                    color: Colors.green.shade900,
                    size: 32,
                  ),
                  title: Text(item.title.padRight(20)),
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
