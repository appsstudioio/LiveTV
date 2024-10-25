//
//  VideoPlayerViewModel.swift
//  LiveTV
//
//  Created by 10-N3344 on 10/21/24.
//

import Foundation
import Combine

final class VideoPlayerViewModel {

    // MARK: - variables
    let info: VideoPlayerModel

    // MARK: - functions
    init(item: VideoPlayerModel) {
        self.info = item
    }
}

extension VideoPlayerViewModel {
    func getTimeTableUrlLink() -> String {
        let query = "\(info.titleName) 편성표".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return "https://m.search.naver.com/search.naver?query=\(query)"
    }
}
