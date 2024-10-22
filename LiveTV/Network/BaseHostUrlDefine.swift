//
//  BaseHostUrlDefine.swift
//  LiveTV
//
//  Created by 10-N3344 on 2023/09/05.
//

import Foundation

public class BaseHostUrlDefine {
    static var hostURL: String {
        return Bundle.getInfoPlistValue(forKey: .baseURL)
    }
}

enum BaseUrlPathDefine {
    case tvList
    case radioList

}

extension BaseUrlPathDefine {
    var url: String {
        let host = BaseHostUrlDefine.hostURL
        switch self {
        case .tvList:
            return host + "/index.php"
        case .radioList:
            return host + "/index3.php"
        }
    }
}
