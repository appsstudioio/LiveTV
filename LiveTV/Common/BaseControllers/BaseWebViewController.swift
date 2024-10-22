//
//  BaseWebViewController.swift
//  LiveTV
//
//  Created by 10-N3344 on 2023/09/04.
//

import UIKit
@preconcurrency import WebKit
import SnapKit
import Then

class BaseWebViewController: BaseViewController {
    var webView: WKWebView!
    var progressView: UIProgressView!
    private var observation: NSKeyValueObservation?
    var viewModel: BaseWebViewModel

    init(viewModel: BaseWebViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setBinding()
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        let configObject = URLSessionConfiguration.ephemeral
        if configObject.httpCookieAcceptPolicy != .always {
            configObject.httpCookieAcceptPolicy = .always
        }
        loadWebView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        guard observation == nil else { return }
        observation = webView.observe(\.estimatedProgress, options: [.new]) { _, _ in
            self.progressView.progress = Float(self.webView.estimatedProgress)
            if self.webView.estimatedProgress == 1.0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                     self.progressView.isHidden = true
                }
            } else {
                self.progressView.isHidden = false
            }
        }

        if viewModel.isFilePath {
            // 파일 공유라면 공유 버튼 활성화 한다..
            setNavigationRightButton()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // AnalyticsManager.setScreenName(screenName: viewModel.naviTitle.count == 0 ? "공통웹뷰" : "공통웹뷰 - \(viewModel.naviTitle)", screenClass: BaseWebViewController.self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        observation = nil
        webView.stopLoading()
    }

    override var hidesBottomBarWhenPushed: Bool {
        get { return true }
        set { super.hidesBottomBarWhenPushed = newValue }
    }

    private func setupUI() {
        view.backgroundColor = UIColor.named(.backgroundColor)

        // 네비 UI 설정
        hideNavigationBar(hidden: viewModel.isNaviHidden , titleText: viewModel.naviTitle)

        if viewModel.isNaviHidden {
            let topSafeAreaView = UIView()
            topSafeAreaView.backgroundColor = UIColor.named(.mainColor)
            view.addSubview(topSafeAreaView)
            topSafeAreaView.snp.makeConstraints {
                $0.top.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            }
            let leftButton = UIButton(type: .custom)
            leftButton.setImage(UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate), for: .normal)
            leftButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
            view.addSubview(leftButton)
            leftButton.setBackgroundColor(.white, for: .normal)
            leftButton.layer.cornerRadius = 32/2
            leftButton.layer.masksToBounds = true
            leftButton.layer.makeShadow()

            leftButton.snp.makeConstraints {
                $0.top.equalTo(topSafeAreaView.snp.bottom).offset(12)
                $0.trailing.equalToSuperview().inset(16)
                $0.width.height.equalTo(32)
            }

        } else {
            hideNavigationLeftButton(hidden: false, target: self, action: #selector(closeView))
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
        let jsCtrl = WKUserContentController()
        configuration.userContentController = jsCtrl
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.backgroundColor = UIColor.named(.backgroundColor)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        view.addSubview(webView)
#if DEVELOP
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
#endif
        webView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        progressView = UIProgressView()
        progressView.progressTintColor = UIColor.named(.r255g126b126)
        progressView.trackTintColor = UIColor.named(.backgroundColor)
        view.addSubview(progressView)

        progressView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(2)
        }
    }
    
    private func setBinding() {

        NotificationCenter.default
            .publisher(for: NSNotification.Name(rawValue: "webViewReload"))
            .sink { [weak self] notification in
                guard let self = self else { return }
                self.webViewReload()
            }.store(in: &cancellables)

    }

    private func removeConfiguration() {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "logging")
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "mobile")
    }

    func setNavigationRightButton() {
        let shareButton = UIBarButtonItem.createUIBarButtonItem(image: UIImage.getSFSymbolImage(name: "square.and.arrow.up", size: 16, weight: .regular, color: UIColor.named(.contentWhite)),
                                                                 target: self,
                                                                 action: #selector(shareFile))
        self.navigationItem.rightBarButtonItems = [shareButton]
    }
}

extension BaseWebViewController {

    @objc private func shareFile() {
        DispatchQueue.main.async { [weak self] in
            if let url = URL(string: self?.viewModel.urlString ?? "") {
                self?.showActivityViewController(activityItems: [url],
                                                sourceRect: self?.navigationItem.rightBarButtonItem?.customView?.frame ?? .zero)
            }
        }
    }

    @objc private func closeView() {
        removeConfiguration()
        NotificationCenter.default.removeObserver(self)

        self.moveBack()
    }

    private func loadWebView() {
        if viewModel.isFilePath {
            if let url = URL(string: viewModel.urlString) {
                webView.loadFileURL(url, allowingReadAccessTo: url)
            } else {
                self.closeView()
            }
        } else {
            if let request = viewModel.createRequest() {
                webView.load(request)
            }
        }
    }

    @objc private func webViewReload() {
        webView.reload()
    }
}

// MARK: - WKScriptMessageHandler
extension BaseWebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        DLog(">>>> Web Console.log : \(message.body)", level: .debug)
    }
}

// MARK: - WKNavigationDelegate
extension BaseWebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        DLog("#### \(#function) :: \(String(describing: webView.url))")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        DLog("#### \(#function) :: \(error.localizedDescription)")
        ProgressHUD.dismiss()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DLog("#### \(#function) :: \(error.localizedDescription)")
        ProgressHUD.dismiss()
        if (error as NSError).code != NSURLErrorCancelled {
            let errorHtml = """

            """
            self.webView.loadHTMLString(errorHtml, baseURL: nil)
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DLog("#### \(#function)")
        ProgressHUD.dismiss()

        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html: Any?, error: Error?) in
            if let htmlString = html as? String {
                DLog("HTML 코드: \(htmlString)")
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
extension BaseWebViewController: WKUIDelegate {
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
        alertController.addAction(UIAlertAction(title: "ok".localization, style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))

        alertController.addAction(UIAlertAction(title: "cancel".localization, style: .default, handler: { (action) in
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
        if (navigationAction.targetFrame?.isMainFrame ?? false) {
            if let urlStr = navigationAction.request.url?.absoluteString {
                UIApplication.shared.openURL(url: urlStr, completion: nil)
            }
        }
        return nil
    }
}
