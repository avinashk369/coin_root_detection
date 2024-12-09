import 'package:flutter_test/flutter_test.dart';
import 'package:coin_root_detection/coin_root_detection.dart';
import 'package:coin_root_detection/coin_root_detection_platform_interface.dart';
import 'package:coin_root_detection/coin_root_detection_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCoinRootDetectionPlatform
    with MockPlatformInterfaceMixin
    implements CoinRootDetectionPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final CoinRootDetectionPlatform initialPlatform = CoinRootDetectionPlatform.instance;

  test('$MethodChannelCoinRootDetection is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCoinRootDetection>());
  });

  test('getPlatformVersion', () async {
    CoinRootDetection coinRootDetectionPlugin = CoinRootDetection();
    MockCoinRootDetectionPlatform fakePlatform = MockCoinRootDetectionPlatform();
    CoinRootDetectionPlatform.instance = fakePlatform;

    expect(await coinRootDetectionPlugin.getPlatformVersion(), '42');
  });
}
