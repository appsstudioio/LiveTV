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
    var videoUrl: String
    var titleName: String

    // MARK: - functions
    init(videoUrl: String, titleName: String) {
        self.videoUrl = videoUrl
        self.titleName = titleName
    }
}

extension VideoPlayerViewModel {

}
