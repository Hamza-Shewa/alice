import 'package:flutter/material.dart';

/// Definition of menu item used in call details.
class NetLensCallDetailsMenuItem {
  const NetLensCallDetailsMenuItem(this.title, this.iconData);

  final String title;
  final IconData iconData;
}

/// Definition of all call details menu item types.
enum NetLensCallDetailsMenuItemType {
  sort,
  delete,
  stats,
  timeline,
  save,
  exportHar,
}
