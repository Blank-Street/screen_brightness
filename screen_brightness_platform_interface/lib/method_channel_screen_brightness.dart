import 'dart:async';

import 'package:flutter/services.dart';
import 'package:screen_brightness_platform_interface/extension/num_extension.dart';
import 'package:screen_brightness_platform_interface/screen_brightness_platform_interface.dart';

import 'constant/brightness.dart';
import 'constant/method_name.dart';
import 'constant/plugin_channel.dart';

/// Implementation of screen brightness platform interface
class MethodChannelScreenBrightness extends ScreenBrightnessPlatform {
  /// Private stream which is listened to event channel for preventing
  Stream<double>? _onCurrentBrightnessChanged;

  /// Returns system screen brightness which is set when application is started.
  ///
  /// The value should be within 0.0 - 1.0. Otherwise, [RangeError.range] will
  /// be throw.
  ///
  /// This parameter is useful for user to get screen brightness value after
  /// calling [resetScreenBrightness]
  ///
  /// When [_channel.invokeMethod] fails to get current brightness, it throws
  /// [PlatformException] with code and message:
  ///
  /// Code: -9, Message: Brightness value returns null
  @override
  Future<double> get system async {
    final systemBrightness = await pluginMethodChannel
        .invokeMethod<double>(methodNameGetSystemScreenBrightness);
    if (systemBrightness == null) {
      throw PlatformException(
          code: "-9", message: "Brightness value returns null");
    }

    if (!systemBrightness.isInRange(minBrightness, maxBrightness)) {
      throw RangeError.range(systemBrightness, minBrightness, maxBrightness);
    }

    return systemBrightness;
  }

  /// Returns current screen brightness which is current screen brightness value.
  ///
  /// The value should be within 0.0 - 1.0. Otherwise, [RangeError.range] will
  /// be throw.
  ///
  /// This parameter is useful for user to get screen brightness value after
  /// calling [setScreenBrightness]
  ///
  /// Calling this method after calling [resetScreenBrightness] may return wrong
  /// value in iOS because UIScreen.main.brightness returns old brightness value
  ///
  /// When [_channel.invokeMethod] fails to get current brightness, it throws
  /// [PlatformException] with code and message:
  ///
  /// Code: -9, Message: Brightness value returns null
  ///
  /// (Android only) Code: -10, Message: Unexpected error on activity binding
  /// Unexpected error when getting activity, activity may be null
  ///
  /// (Android only) Code: -11, Message: Could not found system setting screen
  /// brightness value
  /// Unexpected error when getting brightness from Setting using
  /// Settings.System.SCREEN_BRIGHTNESS
  @override
  Future<double> get current async {
    final currentBrightness = await pluginMethodChannel
        .invokeMethod<double>(methodNameGetScreenBrightness);
    if (currentBrightness == null) {
      throw PlatformException(
          code: "-9", message: "Brightness value returns null");
    }

    if (!currentBrightness.isInRange(minBrightness, maxBrightness)) {
      throw RangeError.range(currentBrightness, minBrightness, maxBrightness);
    }

    return currentBrightness;
  }

  /// Set screen brightness with double value.
  ///
  /// The value should be within 0.0 - 1.0. Otherwise, [RangeError.range] will
  /// be throw.
  ///
  /// This method is useful for user to change screen brightness.
  ///
  /// When [_channel.invokeMethod] fails to get current brightness, it throws
  /// [PlatformException] with code and message:
  ///
  /// Code: -2, Message: Unexpected error on null brightness
  /// Cannot read parameter from method channel map, or parameter is null
  ///
  /// Code: -1, Message: Unable to change screen brightness
  /// Compare changed value with set value fail
  ///
  /// Code: -10, Message: Unexpected error on activity binding
  /// Unexpected error when getting activity, activity may be null
  @override
  Future<void> setScreenBrightness(double brightness) async {
    if (!brightness.isInRange(minBrightness, maxBrightness)) {
      throw RangeError.range(brightness, minBrightness, maxBrightness);
    }

    await pluginMethodChannel.invokeMethod(
        methodNameSetScreenBrightness, {"brightness": brightness});
  }

  /// Reset screen brightness with (Android)-1 or (iOS)system brightness value.
  ///
  /// This method is useful for user to reset screen brightness when user leave
  /// the page which has change the brightness value.
  ///
  /// When [_channel.invokeMethod] fails to get current brightness, it throws
  /// [PlatformException] with code and message:
  ///
  /// Code: -2, Message: Unexpected error on null brightness
  /// System brightness in plugin is null
  ///
  /// Code: -1, Message: Unable to change screen brightness
  /// Compare changed value with set value fail
  ///
  /// Code: -10, Message: Unexpected error on activity binding
  /// Unexpected error when getting activity, activity may be null
  @override
  Future<void> resetScreenBrightness() async {
    await pluginMethodChannel.invokeMethod(methodNameResetScreenBrightness);
  }

  /// A stream return with screen brightness changes including
  /// [ScreenBrightness.setScreenBrightness],
  /// [ScreenBrightness.resetScreenBrightness], system control center or system
  /// setting.
  ///
  /// This stream is useful for user to listen to brightness changes.
  @override
  Stream<double> get onCurrentBrightnessChanged {
    _onCurrentBrightnessChanged ??= pluginEventChannelCurrentBrightnessChange
        .receiveBroadcastStream()
        .cast<double>();
    return _onCurrentBrightnessChanged!;
  }
}
