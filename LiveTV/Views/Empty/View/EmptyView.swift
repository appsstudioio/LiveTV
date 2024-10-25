//
//  EmptyView.swift
//  LiveTV
//
//  Created by 10-N3344 on 10/24/24.
//

import UIKit
import SnapKit
import Then

final class EmptyView: UIView {

    let messageLabel = UILabel().then {
        $0.attributedText = "채널을 선택하세요".toAttributed(fontType: .sb20px, color: .named(.contentTertiary), alignment: .center)
        $0.numberOfLines = 0
    }

    // MARK: - init()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - functions
    private func setupUI() {
        backgroundColor = UIColor.named(.backgroundGray)
        [messageLabel].forEach {
            addSubview($0)
        }

        messageLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - extensions
extension EmptyView {
    
}
