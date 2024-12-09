import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'coin_root_detection_platform_interface.dart';

/// An implementation of [CoinRootDetectionPlatform] that uses method channels.
class MethodChannelCoinRootDetection extends CoinRootDetectionPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('coin_root_detection');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
