//
//  ToastView.swift
//  LiveTV
//
//  Created by 10-N3344 on 10/17/24.
//

import UIKit
import SnapKit
import Then
import Combine

class ToastContainerView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // DLog("### \(#line) :: \((self.frame.size.height / 2))")
        self.layer.cornerRadius = (self.frame.size.height / 2)
        self.clipsToBounds = true
    }
}

typealias ToastViewOption = ToastView.ToastViewOption
class ToastView {
    enum ToastViewPosition {
        case top, center, bottom

        var showAnimation: CATransition {
            let animation = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut )
            animation.duration = 0.3
            switch self {
            case .top:
                animation.type = .push
                animation.subtype = .fromBottom
            case .center:
                animation.type = .reveal
                animation.subtype = .fromLeft
            case .bottom:
                animation.type = .push
                animation.subtype = .fromTop
            }
            return animation
        }

        var hiddenAnimation: CATransition {
            let animation = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut )
            animation.duration = 0.3
            switch self {
            case .top:
                animation.type = .push
                animation.subtype = .fromTop
            case .center:
                animation.type = .fade
                animation.subtype = .fromRight
            case .bottom:
                animation.type = .push
                animation.subtype = .fromBottom
            }
            return animation
        }
    }

    enum ToastViewType {
        case error, success, info, warring

        var icon: UIImage? {
            switch self {
            case .success:
                return UIImage.getSFSymbolImage(name: "checkmark.circle", size: 24, weight: .regular, color: UIColor.named(.contentWhite))
            case .info:
                return UIImage.getSFSymbolImage(name: "info.circle", size: 24, weight: .regular, color: UIColor.named(.contentWhite))
            case .error:
                return UIImage.getSFSymbolImage(name: "exclamationmark.circle", size: 24, weight: .regular, color: UIColor.named(.contentWhite))
            case .warring:
                return UIImage.getSFSymbolImage(name: "exclamationmark.triangle", size: 24, weight: .regular, color: UIColor.named(.contentPrimary))
            }
        }

        var backgroundColor: UIColor {
            switch self {
            case .info:
                return UIColor.named(.success).withAlphaComponent(0.8)
            case .success:
                return UIColor.named(.success).withAlphaComponent(0.8)
            case .error:
                return UIColor.named(.error).withAlphaComponent(0.8)
            case .warring:
                return UIColor.named(.warning).withAlphaComponent(0.8)
            }
        }

        var fontColor: UIColor {
            switch self {
            case .info:
                return UIColor.named(.contentWhite)
            case .success:
                return UIColor.named(.contentWhite)
            case .error:
                return UIColor.named(.contentWhite)
            case .warring:
                return UIColor.named(.contentPrimary)
            }
        }
    }

    struct ToastViewOption {
        var delay: TimeInterval = 3.0
        var position: ToastViewPosition = .top
        var attributedText: NSMutableAttributedString?
    }

    static let toastViewTag = 0xABCD

    var cancellables = Set<AnyCancellable>() // Rx -> DisposeBag

    static func show(_ type: ToastViewType = .success, message: String, option: ToastViewOption = ToastViewOption()) {
        guard let mainWindow = UIApplication.key else { return }

        guard let container = mainWindow.viewWithTag(ToastView.toastViewTag) else {
            let container = ToastContainerView().then {
                $0.backgroundColor = type.backgroundColor
                $0.tag = ToastView.toastViewTag
                $0.isUserInteractionEnabled = true
            }

            let iconImage = UIImageView().then {
                $0.image = type.icon
                $0.tintColor = type.fontColor
            }

            let messageLabel = UILabel().then {
                $0.numberOfLines = 0
                if let attributedText = option.attributedText {
                    $0.attributedText = attributedText
                } else {
                    $0.attributedText = message.toAttributed(fontType: .r14px, color: type.fontColor, alignment: .left)
                }
            }

            container.addSubview(iconImage)
            container.addSubview(messageLabel)
            mainWindow.addSubview(container)

            iconImage.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalToSuperview().inset(24)
                $0.width.height.equalTo(24)
            }

            messageLabel.snp.makeConstraints {
                $0.top.bottom.equalToSuperview().inset(12)
                $0.leading.equalTo(iconImage.snp.trailing).offset(8)
                $0.trailing.equalToSuperview().inset(24)
                $0.height.greaterThanOrEqualTo(24)
            }

            container.snp.makeConstraints {
                $0.left.right.equalToSuperview().inset(20)
                switch option.position {
                case .top:
                    $0.top.equalToSuperview().inset(16 + UIApplication.shared.safeAreaInsets.top)
                case .center:
                    $0.centerY.equalToSuperview()
                case .bottom:
                    $0.bottom.equalToSuperview().inset(16 + UIApplication.shared.safeAreaInsets.bottom)
                }
            }
            mainWindow.bringSubviewToFront(container)

            container.layer.add(option.position.showAnimation, forKey: "SnackbarShowAnimation")

            guard option.delay > 0 else {
                return
            }

            DispatchQueue.main.asyncAfter(deadline: .now()+option.delay, execute: {
                let animaiton = option.position.hiddenAnimation
                container.layer.add(animaiton, forKey: "SnackbarHiddenAnimation")
                container.isHidden = true
                DispatchQueue.main.asyncAfter(deadline: .now()+animaiton.duration, execute: {
                    container.removeFromSuperview()
                })
            })
            return
        }
        container.backgroundColor = type.backgroundColor

        if let messageLabel = container.subviews.filter({ $0.isKind(of: UILabel.self) }).first as? UILabel {
            if let attributedText = option.attributedText {
                messageLabel.attributedText = attributedText
            } else {
                messageLabel.attributedText = message.toAttributed(fontType: .r14px, color: type.fontColor, alignment: .left)
            }
        }

        if let iconImage = container.subviews.filter({ $0.isKind(of: UIImageView.self) }).first as? UIImageView {
            iconImage.image = type.icon
        }
    }
}
