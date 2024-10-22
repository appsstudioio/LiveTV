//
//  ChannelListViewModel.swift
//  LiveTV
//
//  Created by 10-N3344 on 10/17/24.
//

import Foundation
import Combine

final class ChannelListViewModel: BaseViewModel {
    
//    struct Action {
//        var checkValue = PassthroughSubject<(Bool), Never>()
//    }
    
    struct State {
        var updateUI = PassthroughSubject<(Void), Never>()
    }

    // MARK: - variables
//    var action = Action()
    var state = State()
    var listData: [ChannelListModel] = []
    var searchLists: [ChannelListModel] = []
    var viewMode: ChannelListViewMode = .list
    var selectedChannel: ChannelListModel?

    // MARK: - functions
    override init() {
        super.init()
        binding()
    }
    
//    convenience init() {
//        self.init()
//    }

    private func binding() {
//        action.checkValue.sink { [weak self] isPopup in
//            guard let self = self else { return }
//            self.state.checkResult.send(self.checkValue(isPopup))
//        }.store(in: &cancellables)
    }

//    func checkValue(_ isPopup: Bool) -> (Bool, String?) {
//        // return (false, (isPopup ? "1~36 숫자만 입력 가능 합니다." : nil))
//        return (true, (isPopup ? "success" : nil) )
//    }
}

extension ChannelListViewModel {

    func setSelectChannel(_ channel: ChannelListModel?) {
        self.selectedChannel = channel
    }

    // 뷰 상태 변경
    func changeViewMode(viewMode: ChannelListViewMode) {
        self.viewMode = viewMode
        if viewMode == .list {
            self.searchLists.removeAll()
        }
    }

    func setSearchText(_ searchText: String) {
        let isChosung = HangeulSearch.isChosung(searchText.lowercased())
        self.searchLists = listData.filter({ info in
            if isChosung {
                // DLog(">>>> \(contact.USER_NAME ?? "") :: \(HangeulSearch.getCho(contact.USER_NAME ?? ""))")
                return HangeulSearch.getCho(info.name.lowercased()).hasPrefix(searchText.lowercased()) // contains(searchText)
            } else {
                if ((info.hangeulSearchText.lowercased()).contains(HangeulSearch.getJamo(searchText.lowercased()))) {
                    // 이름 검색
                    return true
                } else {
                    // 부서 검색
                    return ((info.name.lowercased()).contains(searchText.lowercased()))
                }
            }
        })
        state.updateUI.send()
    }

    func htmlToDataModel(_ html: String) {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            if let div: Element = try doc.select("div.adsbygoogle").first() {
                listData.removeAll()
                let tables: Elements = try div.select("table")
                let els: Elements = try tables.select("a")
                for link: Element in els.array() {
                    let linkClick: String = try link.attr("onclick")
                    let linkText: String = try link.text()
                    self.listData.append(.init(name: linkText, link: linkClick.replacingOccurrences(of: " return false;", with: "")))
                }
                state.updateUI.send()
            }
        } catch Exception.Error(_, let message) {
            DLog(message)
        } catch {
            DLog("error")
        }
    }

    func isVideoLink(_ html: String) -> Bool {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            if try doc.select("body > div").first() != nil {
                return false
            }
        } catch Exception.Error(_, let message) {
            DLog(message)
        } catch {
            DLog("error")
        }
        return true
    }

    func createRequest() -> URLRequest? {
        guard let url = URL(string: BaseUrlPathDefine.tvList.url) else { return nil }
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        return request
    }

    func createRequest(urlSring: String) -> URLRequest? {
        guard let url = URL(string: urlSring) else { return nil }
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        return request
    }
    
    func getFinalURL(for initialURL: URL, completion: @escaping (URL?, Error?) -> Void) {
        let session = URLSession(configuration: .default)
        session.configuration.timeoutIntervalForRequest = 10
        session.configuration.timeoutIntervalForResource = 10
        var request = URLRequest(url: initialURL)
        request.httpMethod = "HEAD"  // HEAD 메소드를 사용하여 헤더만 가져옵니다
        request.timeoutInterval = 10

        let task = session.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            if let httpResponse = response as? HTTPURLResponse,
               let finalURL = httpResponse.url {
                completion(finalURL, nil)
            } else {
                completion(initialURL, nil)  // 리다이렉트가 없으면 원래 URL 반환
            }
        }
        task.resume()
    }
}
