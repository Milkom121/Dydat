import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dydat/providers/theme_provider.dart';

void main() {
  group('ThemeNotifier', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state is ThemeMode.system', () {
      final notifier = ThemeNotifier();
      expect(notifier.state, ThemeMode.system);
    });

    test('setThemeMode changes state and persists', () async {
      final notifier = ThemeNotifier();

      await notifier.setThemeMode(ThemeMode.dark);
      expect(notifier.state, ThemeMode.dark);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'dark');
    });

    test('load restores persisted theme', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'light'});

      final notifier = ThemeNotifier();
      await notifier.load();

      expect(notifier.state, ThemeMode.light);
    });

    test('load with no saved value keeps system', () async {
      SharedPreferences.setMockInitialValues({});

      final notifier = ThemeNotifier();
      await notifier.load();

      expect(notifier.state, ThemeMode.system);
    });

    test('toggle switches between dark and light', () async {
      final notifier = ThemeNotifier();

      await notifier.toggle();
      expect(notifier.state, ThemeMode.dark);

      await notifier.toggle();
      expect(notifier.state, ThemeMode.light);

      await notifier.toggle();
      expect(notifier.state, ThemeMode.dark);
    });

    test('load with invalid value defaults to system', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'invalid'});

      final notifier = ThemeNotifier();
      await notifier.load();

      expect(notifier.state, ThemeMode.system);
    });
  });
}
