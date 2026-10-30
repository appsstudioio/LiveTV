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

    // iPhone Duo는 사용 중에 접고 펴면서 크기가 바뀌므로, 칼럼 폭은 레이아웃이 바뀔 때마다 다시 계산한다.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
    // 앱 창이 화면 전체와 같지 않을 수 있으므로(iPhone Duo, 멀티태스킹) 앱 전체가 아닌 split view 자신의 폭과 safe area를 쓴다.
    private func setPrimaryColumnWidth() {
        let safeAreaInsets = view.safeAreaInsets
        let totalSafeAreaWidth = safeAreaInsets.left + safeAreaInsets.right
        let columnWidth = (0.2 * (view.bounds.width - totalSafeAreaWidth))
        guard columnWidth > 0 else { return }
        // 값을 바꾸면 레이아웃이 다시 돌므로 같은 값이면 건너뛴다.
        guard minimumPrimaryColumnWidth != columnWidth || maximumPrimaryColumnWidth != columnWidth else { return }
        minimumPrimaryColumnWidth = columnWidth
        maximumPrimaryColumnWidth = columnWidth
    }

    private func setEmptyDetailViewController() {
        // emptyVC는 처음 만든 네비게이션에 붙어 있을 수 있으므로 새로 만든다.
        self.setViewController(BaseNavigationController(rootViewController: EmptyViewController()), for: .secondary)
    }
}

// MARK: - extensions
extension MainSplitViewController {
    // 펼친 상태(목록 | 상세)에서 상세 칼럼을 재생 화면으로 바꾼다.
    func updateDetailViewController(with item: VideoPlayerModel) {
        let videoViewModel = VideoPlayerViewModel(item: item)
        let videoPlayerVC = VideoPlayerViewController(viewModel: videoViewModel)
        let videoPlayerNVC = BaseNavigationController(rootViewController: videoPlayerVC)
        self.setViewController(videoPlayerNVC, for: .secondary)
    }

    // 접힌 상태에서는 목록 네비게이션에 재생 화면을 push한다.
    private func pushVideoPlayer(with item: VideoPlayerModel) {
        guard let listNVC = viewController(for: .primary) as? UINavigationController else { return }
        let videoViewModel = VideoPlayerViewModel(item: item)
        let videoPlayerVC = VideoPlayerViewController(viewModel: videoViewModel)
        listNVC.pushViewController(videoPlayerVC, animated: false)
    }

    private var detailVideoPlayer: VideoPlayerViewController? {
        let detailNVC = viewController(for: .secondary) as? UINavigationController
        return detailNVC?.topViewController as? VideoPlayerViewController
    }
}

// MARK: - UISplitViewControllerDelegate
extension MainSplitViewController: UISplitViewControllerDelegate {
    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
    }

    // 접힐 때 상세 칼럼을 목록 위에 자동으로 합치지 않고 목록을 보여 준다. 보던 채널은 splitViewControllerDidCollapse에서 push로 옮긴다.
    func splitViewController(_ svc: UISplitViewController,
                             topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
        return .primary
    }

    // iPhone Duo를 접었을 때: 상세에서 보던 채널을 목록 위에 push해서 이어서 보여 준다.
    func splitViewControllerDidCollapse(_ svc: UISplitViewController) {
        channelListVC.updateLayoutStyle()
        guard let item = detailVideoPlayer?.viewModel.info else { return }
        // 기존 재생 화면을 먼저 떼어 내야 viewDidDisappear의 오디오 세션 비활성화가 새 화면의 활성화보다 먼저 큐에 들어간다.
        setEmptyDetailViewController()
        DispatchQueue.main.async { [weak self] in
            self?.pushVideoPlayer(with: item)
        }
    }

    // iPhone Duo를 펼쳤을 때: 목록 위에 push되어 있던 재생 화면을 상세 칼럼으로 옮긴다.
    func splitViewControllerDidExpand(_ svc: UISplitViewController) {
        channelListVC.updateLayoutStyle()
        guard let listNVC = viewController(for: .primary) as? UINavigationController,
              let videoPlayerVC = listNVC.viewControllers.last(where: { $0 is VideoPlayerViewController }) as? VideoPlayerViewController else {
            // 접힌 동안 재생 화면을 닫았다면, 펼친 뒤 예전 채널이 남지 않도록 빈 화면으로 되돌린다.
            if detailVideoPlayer != nil {
                setEmptyDetailViewController()
            }
            return
        }
        let item = videoPlayerVC.viewModel.info
        listNVC.popToRootViewController(animated: false)
        DispatchQueue.main.async { [weak self] in
            self?.updateDetailViewController(with: item)
        }
    }
}
