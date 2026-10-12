import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_controller.g.dart';

@riverpod
class ThemeModeController extends _$ThemeModeController {
  @override
  ThemeMode build() => ThemeMode.system;

  void toggle(Brightness platformBrightness) {
    final effective = state == ThemeMode.system
        ? (platformBrightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light)
        : state;
    state = effective == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}
