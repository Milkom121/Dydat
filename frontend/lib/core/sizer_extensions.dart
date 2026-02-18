import 'dart:ui' as ui;

/// Drop-in replacement for the `sizer` package.
/// `.w` = percentage of screen width
/// `.h` = percentage of screen height
/// `.sp` = percentage-based scalable font size (uses width)
extension SizerExt on num {
  double get w => this * _screenWidth / 100;
  double get h => this * _screenHeight / 100;
  double get sp => this * _screenWidth / 100;
}

double get _screenWidth =>
    ui.PlatformDispatcher.instance.implicitView!.physicalSize.width /
    ui.PlatformDispatcher.instance.implicitView!.devicePixelRatio;

double get _screenHeight =>
    ui.PlatformDispatcher.instance.implicitView!.physicalSize.height /
    ui.PlatformDispatcher.instance.implicitView!.devicePixelRatio;
