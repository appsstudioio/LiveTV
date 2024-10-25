//
//  MainSplitViewController.swift
//  LiveTV
//
//  Created by 10-N3344 on 10/24/24.
//

import UIKit
import SnapKit
import Then
import Combine

final class MainSplitViewController: UISplitViewController {

    private let emptyVC = EmptyViewController()
    private let channelListVC = ChannelListViewController()
    var cancellables: Set<AnyCancellable> = []

    override init(style: UISplitViewController.Style) {
        super.init(style: .doubleColumn)
        self.preferredSplitBehavior = .tile // 또는 .tile
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.preferredSplitBehavior = .tile // 또는 .tile
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
        // 레이아웃을 재조정하여 올바른 값이 반영되도록 강제 업데이트
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
    }

    override var hidesBottomBarWhenPushed: Bool {
        get { return true }
        set { super.hidesBottomBarWhenPushed = newValue }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }

    // MARK: - functions
    private func setBinding() {
        NotificationCenter.default
            .publisher(for: NotificationList.showChannelLoad.name)
            .throttle(for: .milliseconds(1000), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] notification in
                guard let self = self else { return }
                if let object = notification.object as? VideoPlayerModel {
                    self.updateDetailViewController(with: object)
                }
            }.store(in: &cancellables)
    }

    private func setupUI() {
        let listNaviNVC = BaseNavigationController(rootViewController: channelListVC)
        let emptyDetailNVC = BaseNavigationController(rootViewController: emptyVC)

        // 초기에는 빈 화면을 secondary로 설정
        self.setViewController(listNaviNVC, for: .primary)
        self.setViewController(emptyDetailNVC, for: .secondary)

        let safeAreaInsets = UIApplication.shared.safeAreaInsets
        let totalSafeAreaWidth = safeAreaInsets.left + safeAreaInsets.right
        preferredPrimaryColumnWidthFraction = 0.2
        minimumPrimaryColumnWidth = (0.2 * (UIScreen.main.bounds.size.width - totalSafeAreaWidth))
        maximumPrimaryColumnWidth = (0.2 * (UIScreen.main.bounds.size.width - totalSafeAreaWidth))

        self.preferredDisplayMode = .twoBesideSecondary
        self.delegate = self
    }
}

// MARK: - extensions
extension MainSplitViewController {
    // 추후에 디테일을 변경하는 메서드
    func updateDetailViewController(with item: VideoPlayerModel) {
        let videoViewModel = VideoPlayerViewModel(item: item)
        let videoPlayerVC = VideoPlayerViewController(viewModel: videoViewModel)
        let videoPlayerNVC = BaseNavigationController(rootViewController: videoPlayerVC)
        self.setViewController(videoPlayerNVC, for: .secondary)
    }
}

extension MainSplitViewController: UISplitViewControllerDelegate {
    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
    }
}
