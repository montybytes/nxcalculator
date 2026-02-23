import "package:flutter/services.dart";

class ScreenTimeoutService {
  static const _channel = MethodChannel("calculator/keep_screen_on");

  static Future<void> setKeepScreenOn(bool enabled) async {
    await _channel.invokeMethod(enabled ? "enable" : "disable");
  }
}
