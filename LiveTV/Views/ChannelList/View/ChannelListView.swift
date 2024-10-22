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

    let searchBarView = UISearchBar().then {
        $0.backgroundColor = UIColor.named(.backgroundColor)
        $0.layer.borderWidth = 0
        $0.layer.borderColor = UIColor.clear.cgColor
        $0.backgroundImage = nil
    }

    var refreshControl = UIRefreshControl()

    let collectionView = UICollectionView(frame:CGRect.zero, collectionViewLayout: UICollectionViewLayout()).then {
        $0.backgroundColor = UIColor.named(.backgroundColor)
        let pagerCollectionViewLayout = UICollectionViewFlowLayout()
        pagerCollectionViewLayout.minimumInteritemSpacing = 16
        pagerCollectionViewLayout.minimumLineSpacing = 10
        pagerCollectionViewLayout.scrollDirection = .vertical
        pagerCollectionViewLayout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        $0.collectionViewLayout = pagerCollectionViewLayout
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

    override func layoutSubviews() {
        super.layoutSubviews()

        if let textField = searchBarView.value(forKey: "searchField") as? UITextField {
            textField.layer.borderWidth = 1
            textField.layer.cornerRadius = 8
            textField.layer.borderColor = UIColor.named(.borderOpaque).cgColor
            textField.attributedPlaceholder = "채널명을 입력하세요.".toAttributed(fontType: .r17px, lineHeight: 0, color: UIColor.named(.contentPlaceHolder))
        }
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

        [webView, searchBarView, collectionView, dimView].forEach {
            addSubview($0)
        }

        webView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        searchBarView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(searchBarView.snp.bottom)
            $0.bottom.leading.trailing.equalToSuperview()
        }

        dimView.snp.makeConstraints {
            $0.edges.equalTo(collectionView.snp.edges)
        }

        if let textField = searchBarView.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = UIColor.named(.backgroundColor)
            textField.textColor = UIColor.named(.contentPrimary)
            textField.textContentType = .none
            //왼쪽 아이콘 이미지넣기
            if let leftView = textField.leftView as? UIImageView {
                leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                //이미지 틴트컬러 정하기
                leftView.tintColor = UIColor.named(.contentSecondary)
            }
        }

        collectionView.addSubview(refreshControl)
    }
}

// MARK: - extensions
extension ChannelListView {
    
}
