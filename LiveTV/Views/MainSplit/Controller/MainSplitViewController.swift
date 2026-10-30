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
        // 창에 붙은 뒤라 view 크기가 확정되어 있으므로 여기서 칼럼 폭을 계산한다.
        setPrimaryColumnWidth()
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

        preferredPrimaryColumnWidthFraction = 0.2

        self.preferredDisplayMode = .twoBesideSecondary
        self.delegate = self
    }

    // 목록 칼럼을 전체 폭의 20%로 고정한다. 기본 최소 폭보다 좁게 쓰려고 최소·최대 폭을 같은 값으로 둔다.
    // UIScreen.main(iOS 26 deprecated) 대신 창에 붙은 split view의 폭을 기준으로 한다.
    private func setPrimaryColumnWidth() {
        let safeAreaInsets = UIApplication.shared.safeAreaInsets
        let totalSafeAreaWidth = safeAreaInsets.left + safeAreaInsets.right
        let columnWidth = (0.2 * (view.bounds.width - totalSafeAreaWidth))
        guard columnWidth > 0 else { return }
        minimumPrimaryColumnWidth = columnWidth
        maximumPrimaryColumnWidth = columnWidth
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
