//
//  BaseWebViewModel.swift
//  LiveTV
//
//  Created by 10-N3344 on 2023/09/05.
//

import Foundation
import Combine

final class BaseWebViewModel: BaseViewModel {

    struct State {
        var reloadView = PassthroughSubject<(Void), Never>()
    }

    var urlString: String = ""
    var naviTitle: String = ""
    var isNaviHidden: Bool = false
    var isRewrite: String? = nil
    var filePath: String? = nil // 파일공유
    var isFilePath: Bool = false // 로컬 파일
    var isReload: Bool = false // 이전 화면 갱신 필요
    var state = State()
    
    override init() {
        super.init()
    }

    convenience init(_ urlString: String,
         naviTitle: String,
         isFilePath:Bool = false,
         isNaviHidden: Bool = false,
         isReload: Bool = false) {
        self.init()

        self.urlString = urlString
        self.naviTitle = naviTitle
        self.isFilePath = isFilePath
        self.isNaviHidden = isNaviHidden
        self.isReload = isReload
    }

    func createRequest() -> URLRequest? {
        guard let url = URL(string: urlString) else { return nil }
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        return request
    }
}
