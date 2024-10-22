//
//  UIImageView+Extension.swift
//  LiveTV
//
//  Created by 10-N3344 on 2023/09/14.
//

import UIKit
#if canImport(Kingfisher)
import Kingfisher
#endif
#if canImport(CommonUtils)
import CommonUtils
#endif

extension UIImage {
    static let userPrifiledefaultImage = UIImage(named: "profile_default")
}

extension UIImageView {
#if canImport(Kingfisher)
    func stopDownloadTask() {
        self.kf.cancelDownloadTask()
    }
    
    func setUrlImage(_ urlStr: String,
                     placeholder: UIImage? = nil,
                     options: KingfisherOptionsInfo? = [ .transition(.fade(0.5))],
                     isIndicator: Bool = true) {
        guard let url = URL(string: urlStr) else {
            self.image = nil
            return
        }
        if isIndicator {
            self.kf.indicatorType = (isIndicator ? .activity : .none)
        }
        self.kf.setImage(with: url, placeholder: placeholder, options: options)
    }

    func setUrlImage(_ urlStr: String,
                     placeholder: UIImage? = nil,
                     options: KingfisherOptionsInfo? = [ .transition(.fade(0.5))],
                     isIndicator: Bool = true,
                     completionHandler: @escaping ((Result<RetrieveImageResult, KingfisherError>) -> Void)) {
        guard let url = URL(string: urlStr) else {
            self.image = nil
            return
        }

        self.kf.indicatorType = (isIndicator ? .activity : .none)
        if isIndicator {
            self.kf.indicator?.startAnimatingView()
        }
        self.kf.setImage(with: url,
                         placeholder: placeholder,
                         options: options) { [weak self] result in
            self?.kf.indicator?.stopAnimatingView()
            completionHandler(result)
        }
    }
#endif
}
