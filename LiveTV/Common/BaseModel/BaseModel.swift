//
//  BaseModel.swift
//  LiveTV
//
//  Created by 10-N3344 on 10/17/24.
//
import Foundation

// MARK: - 공통 API Model
public struct BaseResponseModel: Codable {
    var result: String?
    var error: String?
}


// NotificationCenter Name
enum NotificationList {
    case showChannelLoad // 채널 보기
}

extension NotificationList {
    var name: NSNotification.Name {
        switch self {
        case .showChannelLoad:
            return NSNotification.Name(rawValue: "ShowChannelLoad")
        }
    }
}
