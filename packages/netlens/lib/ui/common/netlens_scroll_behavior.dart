import 'dart:ui';

import 'package:flutter/material.dart';

/// Scroll behavior for NetLens.
class NetLensScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
