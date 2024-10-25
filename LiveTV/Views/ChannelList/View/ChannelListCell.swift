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

        [titleLabel].forEach {
            contentBoxView.addSubview($0)
        }

        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(12)
            $0.leading.trailing.equalToSuperview().inset((CommonFunctions.isIOS ? 12 : 16))
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if !CommonFunctions.isIOS {
            contentBoxView.layer.addBorder([.bottom], color: UIColor.named(.borderOpaque), width: 1)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if CommonFunctions.isIOS {
            contentBoxView.layer.cornerRadius = 8
            contentBoxView.layer.borderWidth = 1
            contentBoxView.layer.borderColor = UIColor.named(.borderOpaque).cgColor
            contentBoxView.layer.makeShadow(y: 2, blur: 4)
            contentBoxView.backgroundColor = UIColor.named(.backgroundBoxColor)
        } else {
            contentBoxView.backgroundColor = UIColor.named(.backgroundColor)
        }
    }
}

extension ChannelListCell {
    func updateUI(text: String) {
        if CommonFunctions.isIOS {
            titleLabel.attributedText = text.toAttributed(fontType: .sb15px, color: .named(.contentSecondary), alignment: .center)
        } else {
            titleLabel.attributedText = text.toAttributed(fontType: .sb15px, color: .named(.contentSecondary), alignment: .left)
        }
    }
}
