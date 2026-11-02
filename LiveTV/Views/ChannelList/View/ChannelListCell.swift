//
//  ChannelListCell.swift
//  LiveTV
//
//  Created by 10-N3344 on 10/18/24.
//

import UIKit
import Then
import SnapKit
import Combine

class ChannelListCell: UICollectionViewCell {

    let contentBoxView = UIView().then {
        $0.backgroundColor = UIColor.named(.backgroundBoxColor)
    }

    var titleLabel = UILabel().then {
        $0.numberOfLines = 1
    }

    // 목록형에서만 보이는 아래 구분선. 접고 펼 때 카드형과 오가야 하므로 draw에서 레이어를 더하지 않고 뷰로 둔다.
    let bottomLineView = UIView().then {
        $0.backgroundColor = UIColor.named(.borderOpaque)
        $0.isHidden = true
    }

    // ChannelListView.isCardStyle과 같은 값. updateUI(text:isCardStyle:)에서 받는다.
    private var isCardStyle: Bool = true

    var cancellables = Set<AnyCancellable>()

    override func prepareForReuse() {
        cancellables = Set<AnyCancellable>()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(contentBoxView)

        contentBoxView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        [titleLabel, bottomLineView].forEach {
            contentBoxView.addSubview($0)
        }

        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(12)
            $0.leading.trailing.equalToSuperview().inset(12)
        }

        bottomLineView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if isCardStyle {
            contentBoxView.layer.cornerRadius = 8
            contentBoxView.layer.borderWidth = 1
            contentBoxView.layer.borderColor = UIColor.named(.borderOpaque).cgColor
            contentBoxView.layer.makeShadow(y: 2, blur: 4)
            contentBoxView.backgroundColor = UIColor.named(.backgroundBoxColor)
        } else {
            // 카드형에서 쓰던 모서리·테두리·그림자를 지운다.
            contentBoxView.layer.cornerRadius = 0
            contentBoxView.layer.borderWidth = 0
            contentBoxView.layer.shadowOpacity = 0
            contentBoxView.backgroundColor = UIColor.named(.backgroundColor)
        }
    }
}

extension ChannelListCell {
    func updateUI(text: String, isCardStyle: Bool) {
        if self.isCardStyle != isCardStyle {
            self.isCardStyle = isCardStyle
            titleLabel.snp.updateConstraints {
                $0.leading.trailing.equalToSuperview().inset(isCardStyle ? 12 : 16)
            }
            setNeedsLayout()
        }
        bottomLineView.isHidden = isCardStyle
        titleLabel.attributedText = text.toAttributed(fontType: .sb15px, color: .named(.contentSecondary), alignment: (isCardStyle ? .center : .left))
    }
}
