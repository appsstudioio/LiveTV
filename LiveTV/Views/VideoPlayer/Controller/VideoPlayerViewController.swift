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

final class VideoPlayerViewController: BaseViewController {

    let backButton = UIButton(type: .custom).then {
        $0.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
        $0.tintColor = .named(.contentPrimary)
    }

    let infoButton = UIButton(type: .custom).then {
        $0.setImage(UIImage(systemName: "list.and.film"), for: .normal)
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player.pause()
        setAudioSessionActive(false)
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
                        self.player.pause()
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
    }

    private func setupUI() {
        setNavigationBarTitle(viewModel.titleName)
        hideNavigationLeftButton(hidden: false, button: backButton, buttonSize: CGSize(width: 24, height: 24))
        hideNavigationRightButton(hidden: false, button: infoButton, buttonSize: CGSize(width: 24, height: 24))

        guard let url = URL(string: viewModel.videoUrl) else {
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
            $0.edges.equalToSuperview()
        }
        playerViewController.didMove(toParent: self)
        playerViewController.canStartPictureInPictureAutomaticallyFromInline = true

        self.setAudioSessionActive(true)
    }
}

// MARK: - extensions
extension VideoPlayerViewController {

}
