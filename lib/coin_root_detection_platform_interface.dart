import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'coin_root_detection_method_channel.dart';

abstract class CoinRootDetectionPlatform extends PlatformInterface {
  /// Constructs a CoinRootDetectionPlatform.
  CoinRootDetectionPlatform() : super(token: _token);

  static final Object _token = Object();

  static CoinRootDetectionPlatform _instance = MethodChannelCoinRootDetection();

  /// The default instance of [CoinRootDetectionPlatform] to use.
  ///
  /// Defaults to [MethodChannelCoinRootDetection].
  static CoinRootDetectionPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CoinRootDetectionPlatform] when
  /// they register themselves.
  static set instance(CoinRootDetectionPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
