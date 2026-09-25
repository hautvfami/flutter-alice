import 'package:flutter/material.dart';

enum AliceMenuAction { clear, stats, about }

class AliceMenuItem {
  final String title;
  final IconData iconData;
  final AliceMenuAction action;

  const AliceMenuItem(this.title, this.iconData, this.action);
}
