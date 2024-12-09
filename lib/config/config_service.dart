import 'package:coin_root_detection/utils/security_const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class ConfigService {
  static const MethodChannel _channel =
      MethodChannel(SecurityConst.methodCahnnel);

  static Future<Map<String, String>> loadConfig() async {
    try {
      final config = await _channel.invokeMethod<Map>('getConfig');
      return config?.map((key, value) => MapEntry(key, value as String)) ?? {};
    } catch (e) {
      debugPrint('ConfigService: Error loading config: $e');
      return {};
    }
  }
}
