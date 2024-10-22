//
//  UITextView+Extension.swift
//  LiveTV
//
//  Created by 10-N3344 on 4/9/24.
//

import Foundation
import UIKit

extension UITextView {
    func calculateMaxLines(widthSize: CGFloat, font: ComponentFont) -> Int {
        let maxSize = CGSize(width: widthSize, height: CGFloat(Float.infinity))
        let charSize: CGFloat = font.lineHeight

        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize,
                                         options: .usesLineFragmentOrigin,
                                         attributes: [NSAttributedString.Key.font: font.font as Any],
                                         context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
}
