
import 'coin_root_detection_platform_interface.dart';

class CoinRootDetection {
  Future<String?> getPlatformVersion() {
    return CoinRootDetectionPlatform.instance.getPlatformVersion();
  }
}
