import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Extensões de [BuildContext] para acesso conciso ao tema e navegação.
extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  bool get isWide => screenSize.width >= 768;
  void goTo(String path) => go(path);
  void pushTo(String path) => push(path);
}
