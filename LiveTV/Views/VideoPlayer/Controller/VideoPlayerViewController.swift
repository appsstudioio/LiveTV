//
//  VideoPlayerViewController.swift
//  LiveTV
//
//  Created by 10-N3344 on 10/21/24.
//

import UIKit
import SnapKit
import Then
import Combine
import AVFoundation
import AVKit
import GoogleCast


final class VideoPlayerViewController: BaseViewController {

    // iOS 26: 고정 크기 customView 대신 기본 바 버튼을 써야 Liquid Glass 배경과 그룹 간격이 시스템 기준으로 적용된다.
    let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: nil, action: nil)

    let infoButton = UIBarButtonItem(image: UIImage(systemName: "list.and.film"), style: .plain, target: nil, action: nil)

    let fullScreenButton = UIBarButtonItem(image: UIImage(systemName: "arrow.up.left.and.arrow.down.right"), style: .plain, target: nil, action: nil).then {
        $0.accessibilityLabel = "전체 화면"
    }

    // 전체 화면은 AVPlayerViewController를 전체 화면 모달로 띄우는 시스템 방식으로 보여 준다(닫기·회전·PiP를 시스템이 처리).
    private var fullScreenPlayerViewController: AVPlayerViewController?

    // Cast 버튼은 SDK가 연결 상태 아이콘을 직접 그리므로 customView로 둔다.
    let castButton = GCKUICastButton().then {
        $0.tintColor = .named(.contentPrimary)
    }

    private var playerViewController: AVPlayerViewController!
    private var player: AVPlayer!
    let viewModel: VideoPlayerViewModel

    init(viewModel: VideoPlayerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        GCKCastContext.sharedInstance().sessionManager.remove(self)
    }

    override func loadView() {
        super.loadView()
    }

    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setBinding()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        // 전체 화면 모달을 닫고 돌아오면 플레이어를 다시 화면 안에 붙인다.
        restoreInlinePlayerIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 전체 화면 모달이 이 화면을 덮은 경우에는 재생을 이어 간다.
        guard presentedViewController == nil else { return }
        videoPause()
        setAudioSessionActive(false)
    }

    // 영상 위 투명한 바 아래에서 상태 바 글자가 보이도록 밝은 글자를 쓴다(BaseNavigationController가 이 값을 따른다).
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var hidesBottomBarWhenPushed: Bool {
        get { return true }
        set { super.hidesBottomBarWhenPushed = newValue }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Trait collection has already changed
        if #available(iOS 12.0, *) {
            let userInterfaceStyle = self.traitCollection.userInterfaceStyle
            if userInterfaceStyle == .dark {
//               DLog("===== Dark Mode")
            } else {
//               DLog("===== \(userInterfaceStyle.rawValue) Mode")
            }
        }
    }

    // MARK: - functions
    private func setBinding() {
        backButton.tapPublisher.sink { [weak self] in
            guard let self = self else { return }
            if self.player.timeControlStatus == .playing {
                self.alertConfirmWith(message: "티비 재생을 종료하시겠습니까?") { isOkay in
                    if isOkay {
                        self.videoPause()
                        self.moveBack()
                    }
                }
            } else {
                self.moveBack()
            }
        }.store(in: &cancellables)

        infoButton.tapPublisher.sink { [weak self] in
            guard let self = self else { return }
            self.showSafariView(urlString: self.viewModel.getTimeTableUrlLink())
        }.store(in: &cancellables)

        fullScreenButton.tapPublisher.sink { [weak self] in
            self?.showFullScreenPlayer()
        }.store(in: &cancellables)

        // 이미 연결된 상태에서 누르면 현재 채널을 다시 보낸다. 연결 전에는 SDK가 기기 선택 창을 띄우고,
        // 연결이 끝나면 sessionManager(_:didStart:)에서 전송한다.
        castButton.tapPublisher.sink { [weak self] in
            guard let self = self else { return }
            self.castMedia(url: self.viewModel.info.videoUrl, title: self.viewModel.info.titleName)
        }.store(in: &cancellables)

        // 리스너는 SDK가 약하게 보유하므로 deinit에서 해제한다.
        GCKCastContext.sharedInstance().sessionManager.add(self)

        videoPlay()
    }

    private func setupUI() {
        setNavigationBarTitle(viewModel.info.titleName)
        // 기기 종류가 아니라 실제로 어떻게 열렸는지로 정한다. 접힌 화면에서 목록 위에 push되었으면 뒤로 버튼을 두고,
        // 펼친 화면의 상세 칼럼(네비게이션의 루트)이면 돌아갈 곳이 없으므로 숨긴다.
        let isPushed = (navigationController?.viewControllers.first !== self)
        if isPushed {
            navigationItem.hidesBackButton = true
            navigationItem.leftBarButtonItem = backButton
        } else {
            hideNavigationLeftButton(hidden: true)
        }

        let castItem = UIBarButtonItem(customView: castButton)
        navigationItem.rightBarButtonItems = [infoButton, castItem, fullScreenButton]
        setTransparentNavigationBar()

        guard let url = URL(string: viewModel.info.videoUrl) else {
            self.alertWith(message: "재생 가능한 동영상을 찾을 수 없습니다!") { _ in
                self.moveBack()
            }
            return
        }
        player = AVPlayer(url: url)
        // AirPlay 활성화
        player.allowsExternalPlayback = true
        // YES: 외부 화면 모드가 활성화되면, 플레이어가 자동으로 외부 재생 모드로 전환됩니다. 재생이 완료되면 다시 외부 화면 모드로 돌아갑니다. 이 과정에서 외부 디스플레이에 짧은 전환이 보일 수 있습니다.
        player.usesExternalPlaybackWhileExternalScreenIsActive = true
        player.volume = 0.1  // 0.0 ~ 1.0
        // 음소거 설정
        player.isMuted = false
        playerViewController = AVPlayerViewController()
        playerViewController.player = player
        // 이 속성은 비디오 프레임 분석을 허용할지 여부를 결정합니다. 주로 비디오 콘텐츠 분석을 위해 사용되며, 기본적으로는 false로 설정되어 있습니다.
        playerViewController.allowsVideoFrameAnalysis = true
        // 이 속성이 true이면, 재생 중인 미디어 정보가 시스템의 Now Playing 정보 센터에 자동으로 업데이트됩니다. 기본값은 true입니다.
        playerViewController.updatesNowPlayingInfoCenter = true
        // 이 속성이 true이면, 재생이 시작될 때 자동으로 전체 화면 모드로 전환됩니다. iOS 11부터 사용할 수 있습니다
        playerViewController.entersFullScreenWhenPlaybackBegins = true
        // 이 속성이 true이면, 재생이 끝날 때 자동으로 전체 화면 모드를 종료합니다. iOS 11부터 사용할 수 있습니다
        playerViewController.exitsFullScreenWhenPlaybackEnds = true

        self.addChild(playerViewController)
        self.view.addSubview(playerViewController.view)
        playerViewController.view.snp.makeConstraints {
            // 위아래는 영상이 투명한 네비게이션 바 아래까지 보이도록 화면 끝에 맞춘다.
            // 타이틀은 setTransparentNavigationBar()에서 흰색으로 바꾸고, 재생 컨트롤은 AVPlayerViewController가 safe area 안에 둔다.
            $0.top.bottom.equalToSuperview()
            // 좌우는 safe area에 맞춘다. iOS 26 split view는 상세 칼럼을 목록 칼럼 밑까지 깔고 그만큼을 safe area로 비워 두므로,
            // 화면 끝에 맞추면 영상 왼쪽이 목록에 가려진다. 목록을 숨기면 safe area가 줄어 영상이 자동으로 넓어진다.
            $0.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
        }
        playerViewController.didMove(toParent: self)
        playerViewController.canStartPictureInPictureAutomaticallyFromInline = true

        self.setAudioSessionActive(true)
    }
}

// MARK: - extensions
extension VideoPlayerViewController {
    private func videoPlay() {
        player.play()
    }

    private func videoPause() {
        player.pause()
    }

    // 이 화면이 맨 위일 때만 쓰이는 바 모양이라 목록 화면의 바에는 영향을 주지 않는다.
    // 배경색 지정이 아니라 투명 배경이므로 바 버튼의 Liquid Glass는 그대로 그려진다.
    private func setTransparentNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.named(.contentWhite),
            .font: ComponentFont.sb18px.font
        ]
        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactScrollEdgeAppearance = appearance
    }

    private func showFullScreenPlayer() {
        guard let player = player, let playerViewController = playerViewController, presentedViewController == nil else { return }
        let fullScreenPlayerVC = AVPlayerViewController()
        // 같은 AVPlayer를 두 화면에 동시에 붙이지 않도록 화면 안 플레이어에서 떼고 전체 화면에 붙인다.
        playerViewController.player = nil
        fullScreenPlayerVC.player = player
        fullScreenPlayerVC.updatesNowPlayingInfoCenter = true
        fullScreenPlayerVC.modalPresentationStyle = .fullScreen
        fullScreenPlayerViewController = fullScreenPlayerVC
        present(fullScreenPlayerVC, animated: true) {
            player.play()
        }
    }

    private func restoreInlinePlayerIfNeeded() {
        guard let fullScreenPlayerVC = fullScreenPlayerViewController,
              presentedViewController !== fullScreenPlayerVC else { return }
        fullScreenPlayerVC.player = nil
        playerViewController?.player = player
        fullScreenPlayerViewController = nil
    }

    // 전체 화면 모달을 바로 닫는다. iPhone Duo를 접거나 펴서 재생 화면을 옮기기 전에 MainSplitViewController가 부른다.
    func dismissFullScreenPlayer(completion: @escaping () -> Void) {
        guard let fullScreenPlayerVC = fullScreenPlayerViewController,
              fullScreenPlayerVC.presentingViewController != nil else {
            completion()
            return
        }
        fullScreenPlayerVC.dismiss(animated: false) { [weak self] in
            self?.restoreInlinePlayerIfNeeded()
            completion()
        }
    }
}

extension VideoPlayerViewController: GCKRequestDelegate {
    func castMedia(url: String, title: String) {
        let mediaMetadata = GCKMediaMetadata(metadataType: .movie)
        mediaMetadata.setString(title, forKey: kGCKMetadataKeyTitle)

        guard let mediaURL = URL.init(string: url) else {
            DLog("invalid mediaURL")
            return
        }

        let mediaInfoBuilder = GCKMediaInformationBuilder.init(contentURL: mediaURL)
        mediaInfoBuilder.streamType = GCKMediaStreamType.live
        mediaInfoBuilder.contentType = "video/mp4"
        mediaInfoBuilder.metadata = mediaMetadata

        // Cast SDK 권장 방식: loadMedia(_:) 대신 load request data로 요청한다.
        let loadRequestBuilder = GCKMediaLoadRequestDataBuilder()
        loadRequestBuilder.mediaInformation = mediaInfoBuilder.build()
        loadRequestBuilder.autoplay = true

        if let request = GCKCastContext.sharedInstance().sessionManager.currentSession?.remoteMediaClient?.loadMedia(with: loadRequestBuilder.build()) {
            request.delegate = self
        }
    }

    func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        // Cast SDK 4.8.4+: 사용자가 Cast 이용약관을 거부하면 cancelled로 끝난다. Google 안내에 따라 자동 재시도하지 않는다.
        if error.code == GCKErrorCode.cancelled.rawValue {
            DLog("Cast 요청 취소 :: \(error.localizedDescription)")
            return
        }
        DLog("Cast 미디어 로드 실패 :: \(error)", level: .error)
    }
}

// MARK: - GCKSessionManagerListener
extension VideoPlayerViewController: GCKSessionManagerListener {
    // 기기 선택 창에서 연결이 끝나면 보고 있던 채널을 바로 보낸다.
    // TV와 기기에서 소리가 겹치지 않도록 기기 재생은 멈춘다.
    func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKSession) {
        DLog("Cast session started")
        videoPause()
        castMedia(url: viewModel.info.videoUrl, title: viewModel.info.titleName)
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didFailToStart session: GCKSession, withError error: Error) {
        // 이용약관 거부(cancelled)를 포함해 연결 실패 시 자동 재시도하지 않는다.
        DLog("Cast session 연결 실패 :: \(error)", level: .error)
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKSession, withError error: Error?) {
        DLog("Cast session ended")
    }
}
