//
//  ChannelListViewController.swift
//  LiveTV
//
//  Created by 10-N3344 on 10/17/24.
//

import UIKit
@preconcurrency import WebKit
import SnapKit
import Then
import Combine

final class ChannelListViewController: BaseViewController {

    let subViews = ChannelListView()
    let viewModel = ChannelListViewModel()
    var videoWebView: WKWebView? // 비디오 플레이어 웹뷰

    override func loadView() {
        super.loadView()
        setupUI()
    }

    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()

        setBinding()

        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        let configObject = URLSessionConfiguration.ephemeral
        if configObject.httpCookieAcceptPolicy != .always {
            configObject.httpCookieAcceptPolicy = .always
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // AnalyticsManager.setScreenName(screenName: ChannelList, screenClass: ChannelListViewController.self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override var hidesBottomBarWhenPushed: Bool {
        get { return true }
        set { super.hidesBottomBarWhenPushed = newValue }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Trait collection has already changed
        if #available(iOS 12.0, *) {
            self.viewModel.state.updateUI.send()
        }
    }

    // MARK: - functions
    private func setBinding() {

        keyboardHeight().sink { [weak self] keyboardHeight in
            guard let self = self else { return }
            self.subViews.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: (keyboardHeight == 0 ? 60 : keyboardHeight), right: 0)
        }.store(in: &cancellables)

        subViews.searchBarView.searchTextField.textPublisher.sink { [weak self] searchText in
            guard let self = self else { return }
            guard self.viewModel.viewMode == .search else { return }
            let keyword = searchText?.stringTrim ?? ""
            DLog("#### searchText :: \(keyword)")
            self.subViews.isShowDim = (keyword.count == 0)
            self.viewModel.setSearchText(keyword)
        }.store(in: &cancellables)

        viewModel.state.updateUI.sink { [weak self] _ in
            self?.subViews.collectionView.reloadData()
        }.store(in: &cancellables)

        loadWebView()
    }

    private func createVideoWebView(urlString: String) {
        if videoWebView != nil {
            videoWebView?.removeFromSuperview()
            videoWebView = nil
        }

        let configuration = WKWebViewConfiguration()
        // 1. 인라인 미디어 재생 허용 (true = HTML5 비디오가 전체 화면 모드로 전환되지 않고 인라인으로 재생됩니다)
        configuration.allowsInlineMediaPlayback = false
        // 2. 자동 재생 설정 (빈 배열로 설정하면 사용자 상호작용 없이 자동 재생이 가능해집니다)
        // configuration.mediaTypesRequiringUserActionForPlayback = []
        // 사용자 상호작용 없이는 비디오가 자동으로 재생되지 않도록 설정
        configuration.mediaTypesRequiringUserActionForPlayback = .all
        // 3. 화면 모드 설정 (iOS 9.0 이상, Picture-in-Picture 모드를 허용합니다.)
        configuration.allowsPictureInPictureMediaPlayback = true
        // 4. 에어플레이 허용 (true = AirPlay를 통한 미디어 재생을 허용합니다.)
        configuration.allowsAirPlayForMediaPlayback = true

        let contentController = WKUserContentController()
        contentController.add(self, name: "metaRefreshHandler")
        // 메타 리프레시 감지 스크립트 주입
        let metaRefreshScript = """
        document.querySelectorAll('video').forEach(video => {
            video.autoplay = false;
            video.pause();
            // 현재 비디오 소스의 URL 가져오기
            var videoURL = video.src;
            window.webkit.messageHandlers.metaRefreshHandler.postMessage({
                'url': videoURL
            });
        });
        """
        let userScript = WKUserScript(source: metaRefreshScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(userScript)
        configuration.userContentController = contentController
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        videoWebView = WKWebView(frame: view.frame, configuration: configuration)

        if let webView = videoWebView {
            webView.backgroundColor = .clear
            webView.scrollView.isScrollEnabled = false
            // 커스텀 User-Agent 설정 (모바일 에이전트로 고정)
            webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1"
            view.addSubview(webView)
            view.sendSubviewToBack(webView)

            webView.navigationDelegate = self
            webView.allowsBackForwardNavigationGestures = false
#if DEVELOP
            if #available(iOS 16.4, *) {
                webView.isInspectable = true
            }
#endif
            if let request = viewModel.createRequest(urlSring: urlString) {
                webView.load(request)
            } else {
                ToastView.show(.error, message: "잘못된 링크 입니다.!!!")
            }
        }
    }

    private func setupUI() {
        view.backgroundColor = .named(.backgroundColor)
        view.addSubview(subViews)
        hideNavigationLeftButton(hidden: true)
        setNavigationBarTitle("채널 목록")

        subViews.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        subViews.webView.navigationDelegate = self
        subViews.webView.uiDelegate = self
        subViews.webView.allowsBackForwardNavigationGestures = true
#if DEVELOP
        if #available(iOS 16.4, *) {
            subViews.webView.isInspectable = true
        }
#endif
        subViews.searchBarView.delegate = self
        subViews.collectionView.delegate = self
        subViews.collectionView.dataSource = self

        subViews.refreshControl.addTarget(self, action: #selector(loadWebView), for: UIControl.Event.valueChanged)
    }

    private func endRefreshTableReload() {
        DispatchQueue.main.async { [weak self] in
            if self?.subViews.refreshControl.isRefreshing == true {
                self?.subViews.refreshControl.endRefreshing()
            }
            ProgressHUD.dismiss()
            self?.viewModel.state.updateUI.send()
        }
    }
}

// MARK: - extensions
extension ChannelListViewController {

    @objc private func loadWebView() {
        if let request = viewModel.createRequest() {
            subViews.webView.load(request)
        }
    }

    private func callJavaScript(script: String) {
        subViews.webView.evaluateJavaScript(script) { (result, error) in
          if let result = result {
              DLog("### 결과: \(result)")
          } else if let error = error {
              DLog("### 오류: \(error)")
          }
        }
    }
}

// MARK: - UISearchBarDelegate
extension ChannelListViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.searchMode(viewMode: .search)
        return true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.closeKeyboard()
        searchBar.text = ""
        self.searchMode(viewMode: .list)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text?.stringTrim, keyword.count > 0 else {
            searchBar.layer.shakingAnimation()
            UIDevice.vibrate()
            return
        }

        viewModel.setSearchText(keyword)
        self.closeKeyboard()
    }
}

extension ChannelListViewController: UIScrollViewDelegate {

    func searchMode(viewMode: ChannelListViewMode) {
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([.foregroundColor: UIColor.named(.mainColor)], for: .normal)

        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self = self else { return }
            self.subViews.isShowDim = (viewMode == .search)
            self.viewModel.changeViewMode(viewMode: viewMode)
            self.hideNavigationBar(hidden: (viewMode == .search), animate: true)
            self.viewModel.state.updateUI.send()
            self.subViews.searchBarView.showsCancelButton = (viewMode == .search)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        if translation.y > 0 && subViews.searchBarView.isFirstResponder {
            self.closeKeyboard()
        }
    }
}

// MARK: - extensions
extension ChannelListViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewModel.viewMode == .search {
            return viewModel.searchLists.count
        }
        return viewModel.listData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChannelListCell.identifier, for: indexPath) as! ChannelListCell
        if viewModel.viewMode == .search {
            guard viewModel.searchLists.count > indexPath.item else { return cell }
            cell.updateUI(text: viewModel.searchLists[indexPath.item].name)
        } else {
            guard viewModel.listData.count > indexPath.item else { return cell }
            cell.updateUI(text: viewModel.listData[indexPath.item].name)
        }
        return cell
    }
}

extension ChannelListViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var script: String = ""
        var selectChannel: ChannelListModel?

        if viewModel.viewMode == .search {
            guard viewModel.searchLists.count > indexPath.item else { return }
            selectChannel = viewModel.searchLists[indexPath.item]
            script = viewModel.searchLists[indexPath.item].link
            // 리스트 모드로 변경..
            subViews.searchBarView.text = ""
            closeKeyboard()
            searchMode(viewMode: .list)
        } else {
            guard viewModel.listData.count > indexPath.item else { return }
            selectChannel = viewModel.listData[indexPath.item]
            script = viewModel.listData[indexPath.item].link
        }
        viewModel.setSelectChannel(selectChannel)
        callJavaScript(script: script)
    }

}

extension ChannelListViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        let boxSize = ((UIScreen.main.bounds.width - (16*3)) / 2)
        return CGSize.init(width: boxSize, height: boxSize/2)
    }
}

// MARK: - WKScriptMessageHandler
extension ChannelListViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        DLog(">>>> Web Console.log -> \(message.name) :: \(message.body)", level: .debug)

        if message.name == "metaRefreshHandler" {
            if let body = message.body as? [String: Any],
               let videoUrl = body["url"] as? String {
                DLog("메타 리프레시 감지: \(videoUrl)")
                // 추가 처리 로직 구현 가능
                let titleName = viewModel.selectedChannel?.name ?? ""
                let videoViewModel = VideoPlayerViewModel(videoUrl: videoUrl, titleName: titleName)
                let videoPlayerVC = VideoPlayerViewController(viewModel: videoViewModel)
                self.pushView(videoPlayerVC)
            }
        }
    }
}

// MARK: - WKNavigationDelegate
extension ChannelListViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        DLog("#### \(#function) :: \(String(describing: webView.url))")
        if subViews.refreshControl.isRefreshing == false {
            ProgressHUD.animate(interaction: false)
        }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // 오류 발생 시 자동으로 리로드되는 것을 방지
        DLog("#### \(#function) :: \(error.localizedDescription)")
        endRefreshTableReload()
        if (error as NSError).code == NSURLErrorCancelled {
            return
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DLog("#### \(#function) :: \(error.localizedDescription)")
        endRefreshTableReload()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        endRefreshTableReload()
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html: Any?, error: Error?) in
            if let htmlString = html as? String {
                DLog("HTML 코드: \(htmlString)")
                if webView == self.videoWebView {
                    // self.viewModel.getVideoLink(htmlString)
                    guard self.viewModel.isVideoLink(htmlString) == false else {
                        return
                    }
                    DispatchQueue.main.async {
                        if let url =  webView.url {
                            self.showSafariView(urlString: url.absoluteString)
                        }
                    }
                    return
                }

                // 여기서 HTML 코드를 처리할 수 있습니다.
                self.viewModel.htmlToDataModel(htmlString)
            } else if let error = error {
                DLog("Error: \(error.localizedDescription)")
                ToastView.show(.error, message: "오류 발생: \(error.localizedDescription)")
            }
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        DLog("#### \(navigationAction.request.url?.absoluteString ?? "")")
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        let scheme = url.scheme ?? ""
        DLog("### \(scheme)")

        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let statusCode = (navigationResponse.response as? HTTPURLResponse)?.statusCode {
            DLog("#### \(#function) :: statusCode :: \(statusCode)")
        }
        decisionHandler(.allow)
    }
}

// MARK: - WKUIDelegate
extension ChannelListViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        self.alertConfirmWith(title: "alert_title".localization, message: message) { isOkay in
            completionHandler(isOkay)
        }
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {

        let alertController = UIAlertController(title: "", message: prompt, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))

        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in
            completionHandler(nil)
        }))

        self.present(alertController, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        self.alertWith(title: "", message: message) { _ in
            completionHandler()
        }
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        DLog("#### \(#function) :: \(navigationAction.request.url?.absoluteString ?? "")")
        DLog("#### \(#function) :: \(String(describing: navigationAction.request.httpBody))")
        if (navigationAction.targetFrame == nil) {
            if let url = navigationAction.request.url {
                // ProgressHUD.animate("", interaction: false)
                DispatchQueue.main.async {
                    self.createVideoWebView(urlString: url.absoluteString)
                }
            }
        }
        return nil
    }
}
