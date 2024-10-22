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
        $0.tintColor = .white
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
            self.alertConfirmWith(message: "티비 재생을 종료하시겠습니까?") { isOkay in
                if isOkay {
                    self.player.pause()
                    self.moveBack()
                }
            }
        }.store(in: &cancellables)
    }

    private func setupUI() {
        setNavigationBarTitle(viewModel.titleName)
        hideNavigationLeftButton(hidden: false, button: backButton, buttonSize: CGSize(width: 24, height: 24))

        guard let url = URL(string: viewModel.videoUrl) else {
            self.alertWith(message: "재생 가능한 동영상을 찾을 수 없습니다!") { _ in
                self.moveBack()
            }
            return
        }
        player = AVPlayer(url: url)
        // AirPlay 활성화
        player.allowsExternalPlayback = true
        player.volume = 0.1  // 0.0 ~ 1.0
        // 음소거 설정
        player.isMuted = false
        playerViewController = AVPlayerViewController()
        playerViewController.player = player

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

extension VideoPlayerViewController {
}
