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
        let pagerCollectionViewLayout = UICollectionViewFlowLayout()
        if CommonFunctions.isIOS {
            pagerCollectionViewLayout.minimumInteritemSpacing = 16
            pagerCollectionViewLayout.minimumLineSpacing = 10
            pagerCollectionViewLayout.scrollDirection = .vertical
            pagerCollectionViewLayout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        } else {
            pagerCollectionViewLayout.minimumInteritemSpacing = 0
            pagerCollectionViewLayout.minimumLineSpacing = 0
            pagerCollectionViewLayout.scrollDirection = .vertical
            pagerCollectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        collectionView.collectionViewLayout = pagerCollectionViewLayout
    }
}

// MARK: - extensions
extension ChannelListView {
    
}
