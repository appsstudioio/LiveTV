//
//  ChannelListModel.swift
//  LiveTV
//
//  Created by 10-N3344 on 10/17/24.
//

import Foundation

public struct ChannelListModel {
    var name: String
    var link: String
    var hangeulSearchText: String // 검색 키워드

    init(name: String, link: String) {
        self.name = name
        self.link = link
        self.hangeulSearchText = HangeulSearch.getJamo(name)
    }
}

enum ChannelListViewMode {
    case list
    case search
}
