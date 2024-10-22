//
//  BaseViewModel.swift
//  LiveTV
//
//  Created by 10-N3344 on 2023/06/16.
//

import Foundation
import Combine
import UIKit
import Network

class BaseViewModel: ObservableObject {

    struct BaseAction {
    }

    struct BaseState {
        var apiResult = PassthroughSubject<(Bool, Any, Any?), Never>() // 서버 결과
        var apiErrorMessage = PassthroughSubject<(Bool, Any, String), Never>() // 서버 에러메시지.
    }

    // MARK: - variables
    var baseAction = BaseAction()
    var baseState = BaseState()
    var cancellables: Set<AnyCancellable> = []

    init() {
        baseBinding()
    }
    
    deinit {
    }

    private func baseBinding() {
    }
    
}
