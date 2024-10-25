//
//  CommonFunctions.swift
//  LiveTV
//
//  Created by 10-N3344 on 10/17/24.
//

import Foundation
import UIKit
import SystemConfiguration
@_exported import Combine
#if canImport(CommonUtils)
@_exported import CommonUtils
#endif
#if canImport(SnapKit)
@_exported import SnapKit
#endif
#if canImport(Then)
@_exported import Then
#endif
#if canImport(Kingfisher)
@_exported import Kingfisher
#endif
#if canImport(ProgressHUD)
@_exported import ProgressHUD
#endif
#if canImport(Network)
@_exported import Network
#endif
#if canImport(SwiftSoup)
@_exported import SwiftSoup
#endif

func DLog(_ message: Any? = "",
          level: DebugLogLevel = .info,
          file: String = #file,
          funcName: String = #function,
          line: Int = #line,
          param: [String: Any] = [:]) {
#if DEBUG
    DebugLog(message, level: level, file: file, funcName: funcName, line: line, param: param)
#else
    if level == .error {
//        let logMessage = message
//        let reasonParam: [String: Any] = param
//        CrashlyticsManager.crashlyticLog(.error,
//                                         message: logMessage as? String,
//                                         param: reasonParam,
//                                         file: file,
//                                         funcName: funcName,
//                                         line: line)
    }
#endif
}

class CommonFunctions {

   static func showAlertGoToSetting() {
       guard let viewVC = UIApplication.shared.topViewController() else { return }
       viewVC.alertConfirmWith(title: "알림",
                               message: "현재 카메라 사용에 대한 접근 권한이 없습니다.\n설정에서 접근을 활성화 할 수 있습니다.",
                               cancleButton: "닫기",
                               okayButton: "설정") { isOkay in
           if isOkay {
               CommonUtils.openSetting()
           }
       }
   }

    static var isIOS: Bool {
        return (UIDevice.current.userInterfaceIdiom == .phone)
    }
}

// MARK: - SDK Config & app setting
extension CommonFunctions {

   static func kingfisherConfig() {
       /* Kingfisher Image Cache config */
       // Limit memory cache size to 200 MB.(200 * 1024 * 1024)
       ImageCache.default.memoryStorage.config.totalCostLimit = 200 * 1024 * 1024
       // Limit memory cache to hold 10 images at most.
       ImageCache.default.memoryStorage.config.countLimit = 10
       // Limit disk cache size to 2 GB.
       ImageCache.default.diskStorage.config.sizeLimit = 2000 * 1024 * 1024
       // Memory image expires after 1 minutes.
       ImageCache.default.memoryStorage.config.expiration = .seconds(60 * 1)
       // Disk image never expires.
       ImageCache.default.diskStorage.config.expiration = .days(10)
       // Remove only expired.
       ImageCache.default.cleanExpiredCache {
           DLog("cleanExpiredCache")
           ImageCache.default.calculateDiskStorageSize { result in
               switch result {
               case .success(let size):
                   DLog("======= Disk cache size: \(Double(size) / 1024 / 1024) MB")
               case .failure(let error):
                   DLog(error)
               }
           }
       }
   }

   static func progressHUDConfig() {
       ProgressHUD.animationType = .circleStrokeSpin
       ProgressHUD.colorHUD = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
       ProgressHUD.colorBackground = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 0.15)
       ProgressHUD.colorAnimation = UIColor.named(.mainColor)
       ProgressHUD.colorProgress = UIColor.named(.mainColor)
       ProgressHUD.colorStatus = .label
       ProgressHUD.fontStatus = ComponentFont.font(weight: .semibold, size: 16)
   }
}
