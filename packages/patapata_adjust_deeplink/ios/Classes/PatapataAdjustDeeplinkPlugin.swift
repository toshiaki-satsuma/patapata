// Copyright (c) GREE, Inc.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Flutter
import UIKit
import AdjustSdk
import app_links
import patapata_core

public class PatapataAdjustDeeplinkPlugin: NSObject, FlutterPlugin, PatapataPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
      let tInstance = PatapataAdjustDeeplinkPlugin(registrar: registrar)
      registrar.registerPatapata(plugin: tInstance)
  }
  
  fileprivate let mChannel: FlutterMethodChannel  
  fileprivate var mEnabled = false
  
  init(registrar: FlutterPluginRegistrar) {
      mChannel = FlutterMethodChannel(name: "dev.patapata.patapata_adjust_deeplink", binaryMessenger: registrar.messenger())
      
      super.init()
      
      registrar.addMethodCallDelegate(self, channel: mChannel)
      registrar.addApplicationDelegate(self)
  }

  public var patapataName = "dev.patapata.patapata_adjust_deeplink"
  
  public func patapataEnable() {
      guard !mEnabled else {
          return
      }
      
      mEnabled = true
  }
  
  public func patapataDisable() {
      guard mEnabled else {
          return
      }
      
      mEnabled = false
  }

  public func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {
    if let url = AppLinks.shared.getLink(launchOptions: launchOptions) {
      AppLinks.shared.handleLink(url: url)
      return true
    }
    return false
  }

  public func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
          let incomingURL = userActivity.webpageURL,
          let deeplink = ADJDeeplink(deeplink: incomingURL) else {
      return false
    }

    guard mEnabled else { 
      return true 
    }

    Adjust.processAndResolve(deeplink, withCompletionHandler: { [weak self] resolved in
      self?.mChannel.invokeMethod(
        "processAdjustDeepLink",
        arguments: resolved
      )
    })
    return true
  }
}