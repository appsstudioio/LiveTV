//
//  ComponentFont+Extension.swift
//  LiveTV
//
//  Created by 10-N3344 on 2023/09/01.
//

import Foundation
import UIKit

// lineHeight 설명
// https://sujinnaljin.medium.com/swift-label%EC%9D%98-line-height-%EC%84%A4%EC%A0%95-%EB%B0%8F-%EA%B0%80%EC%9A%B4%EB%8D%B0-%EC%A0%95%EB%A0%AC-962f7c6e7512

extension String {
    func toAttributed(fontType: ComponentFont,
                      lineHeight: CGFloat? = nil,
                      color: UIColor?,
                      underLine: Bool = false,
                      alignment: NSTextAlignment = .left,
                      lineBreakMode: NSLineBreakMode = .byWordWrapping) -> NSMutableAttributedString {

        var baselineValue: CGFloat = 0
        let style = NSMutableParagraphStyle()
        style.alignment = alignment
        style.lineBreakMode = lineBreakMode
        if let lineHeight = lineHeight {
            if lineHeight == 0 {
                style.lineSpacing = 0
            } else {
                style.maximumLineHeight = lineHeight
                style.minimumLineHeight = lineHeight
                if lineHeight > fontType.fontSize {
                    baselineValue = ((lineHeight - fontType.fontLineHeight) / 4)
                }
            }
        } else {
            style.maximumLineHeight = fontType.lineHeight
            style.minimumLineHeight = fontType.lineHeight
            baselineValue = ((fontType.lineHeight - fontType.fontLineHeight) / 4)
        }

        var attributes: [NSAttributedString.Key: Any] = [
                            .paragraphStyle: style,
                             .baselineOffset: baselineValue,
                            .font: fontType.font,
                            .foregroundColor: (color ?? .white)
        ]

        if underLine {
            attributes[.baselineOffset] = 4
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }

        return NSMutableAttributedString(string: self, attributes: attributes)
    }

    func toAttributed(font: UIFont,
                      lineHeight: CGFloat? = nil,
                      color: UIColor?,
                      underLine: Bool = false,
                      alignment: NSTextAlignment = .left,
                      lineBreakMode: NSLineBreakMode = .byWordWrapping) -> NSMutableAttributedString {

        var baselineValue: CGFloat = 0
        let style = NSMutableParagraphStyle()
        style.alignment = alignment
        style.lineBreakMode = lineBreakMode
        if let lineHeight = lineHeight {
            if lineHeight == 0 {
                style.lineSpacing = 0
            } else {
                style.maximumLineHeight = lineHeight
                style.minimumLineHeight = lineHeight
                if lineHeight > font.pointSize {
                    baselineValue = ((lineHeight - font.lineHeight) / 4)
                }
            }
        } else {
            style.maximumLineHeight = font.lineHeight
            style.minimumLineHeight = font.lineHeight
            baselineValue = ((font.lineHeight - font.pointSize) / 4)
        }

        var attributes: [NSAttributedString.Key: Any] = [
                            .paragraphStyle: style,
                             .baselineOffset: baselineValue,
                            .font: font,
                            .foregroundColor: (color ?? .white)
        ]

        if underLine {
            attributes[.baselineOffset] = 4
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }

        return NSMutableAttributedString(string: self, attributes: attributes)
    }
}

