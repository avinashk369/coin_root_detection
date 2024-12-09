import 'package:coin_root_detection/utils/security_const.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ConnectionUtil {
  static Future<bool> internetStatus() async {
    try {
      List<ConnectivityResult> connectivityResult =
          await Connectivity().checkConnectivity();
      return connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi);
    } on SocketException catch (e) {
      if (kDebugMode) {
        print("${SecurityConst.name} - SocketException caught: $e");
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print(
            "${SecurityConst.name} -  An error occurred while checking connectivity: $e");
      }
      return false;
    }
  }
}
