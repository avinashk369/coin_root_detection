import Flutter
import UIKit

public class CoinRootDetectionPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "coin_root_detection", binaryMessenger: registrar.messenger())
    let instance = CoinRootDetectionPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "root_detection":
       let jailBreakTestResult = JailBreakTestService().isJailBroken()
       print("COINCROWD \(jailBreakTestResult.msg)")
       print("COINCROWD \(jailBreakTestResult.failed)")
       result(jailBreakTestResult.failed)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
