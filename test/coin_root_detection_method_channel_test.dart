import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coin_root_detection/coin_root_detection_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelCoinRootDetection platform = MethodChannelCoinRootDetection();
  const MethodChannel channel = MethodChannel('coin_root_detection');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
