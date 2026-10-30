//
//  ChannelListView.swift
//  LiveTV
//
//  Created by 10-N3344 on 10/17/24.
//

import UIKit
@preconcurrency import WebKit
import SnapKit
import Then

final class ChannelListView: UIView {

    var webView: WKWebView!

    var refreshControl = UIRefreshControl()

    let collectionView = UICollectionView(frame:CGRect.zero, collectionViewLayout: UICollectionViewLayout()).then {
        $0.backgroundColor = UIColor.named(.backgroundColor)
        $0.register(ChannelListCell.self, forCellWithReuseIdentifier: ChannelListCell.identifier)
        $0.showsHorizontalScrollIndicator = false
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.isPagingEnabled = false
        $0.isUserInteractionEnabled = true
        $0.bounces = true
    }

    let dimView = UIView().then {
        $0.backgroundColor = UIColor.named(.backgroundDimm)
        $0.isHidden = true
    }

    var isShowDim: Bool = false {
        didSet {
            self.dimView.isHidden = !self.isShowDim
        }
    }

    // true: 접힌 화면(한 칸)의 카드형 그리드, false: 펼친 화면 목록 칼럼의 한 줄 목록.
    // 기기 종류가 아니라 split view의 접힘 상태로 정한다(iPhone Duo는 접고 펼 때 바뀐다).
    private(set) var isCardStyle: Bool = true

    // MARK: - init()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 18.0, *) {
            return
        } else {
            super.traitCollectionDidChange(previousTraitCollection)
            // iOS 16 이하에서만 처리
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                // 변경 되었을 경우
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - functions
    private func setupUI() {
        backgroundColor = UIColor.named(.backgroundColor)

        let config = WKWebViewConfiguration()
        let jsCtrl = WKUserContentController()
        config.userContentController = jsCtrl
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        webView = WKWebView(frame: .zero, configuration: config)
        webView.backgroundColor = UIColor.named(.backgroundColor)
        // 커스텀 User-Agent 설정 (모바일 에이전트로 고정)
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1"

        [webView, collectionView, dimView].forEach {
            addSubview($0)
        }

        webView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // 검색 바는 ChannelListViewController의 navigationItem.searchController가 담당한다.
        // 목록은 Liquid Glass 바 아래까지 스크롤되도록 상단을 뷰 끝에 맞추고, 바 높이만큼의 여백은 contentInsetAdjustmentBehavior가 계산한다.
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        dimView.snp.makeConstraints {
            $0.edges.equalTo(collectionView.snp.edges)
        }

        collectionView.refreshControl = refreshControl
        collectionView.collectionViewLayout = makeCollectionViewLayout(isCardStyle: isCardStyle)
    }

    private func makeCollectionViewLayout(isCardStyle: Bool) -> UICollectionViewFlowLayout {
        let pagerCollectionViewLayout = UICollectionViewFlowLayout()
        pagerCollectionViewLayout.scrollDirection = .vertical
        // 좌우 safe area(iPhone Duo의 세로 바 등)는 ChannelListViewController의 insetForSectionAt에서 더한다.
        if isCardStyle {
            pagerCollectionViewLayout.minimumInteritemSpacing = 16
            pagerCollectionViewLayout.minimumLineSpacing = 10
            pagerCollectionViewLayout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        } else {
            pagerCollectionViewLayout.minimumInteritemSpacing = 0
            pagerCollectionViewLayout.minimumLineSpacing = 0
            pagerCollectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        return pagerCollectionViewLayout
    }
}

// MARK: - extensions
extension ChannelListView {
    func updateLayout(isCardStyle: Bool) {
        guard self.isCardStyle != isCardStyle else { return }
        self.isCardStyle = isCardStyle
        collectionView.setCollectionViewLayout(makeCollectionViewLayout(isCardStyle: isCardStyle), animated: false)
    }
}
