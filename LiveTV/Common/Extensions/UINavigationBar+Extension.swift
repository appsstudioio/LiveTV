//
//  UINavigationBar+Extension.swift
//  LiveTV
//
//  Created by 10-N3344 on 10/17/24.
//

import UIKit

extension UINavigationBar {
    func setDefaultNavigationBarStyle() {
        // iOS 26: 불투명 배경이나 배경색을 지정하면 Liquid Glass와 스크롤 엣지 효과가 적용되지 않는다.
        // 배경은 시스템 기본값에 맡기고 타이틀 글꼴·색상과 tintColor만 지정한다.
        // CommonUtils의 setNavigationBarStyle(_:fontColor:font:largeFont:)은 불투명 배경을 쓰므로 호출하지 않는다.
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.named(.contentPrimary),
            .font: ComponentFont.sb18px.font
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.named(.contentPrimary),
            .font: ComponentFont.sb24px.font
        ]

        standardAppearance = appearance
        tintColor = UIColor.named(.contentPrimary)
    }
}
