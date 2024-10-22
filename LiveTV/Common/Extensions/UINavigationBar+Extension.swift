//
//  UINavigationBar+Extension.swift
//  LiveTV
//
//  Created by 10-N3344 on 10/17/24.
//

import UIKit

// https://stackoverflow.com/questions/30884170/how-can-i-set-the-uinavigationbar-with-gradient-color
extension UINavigationBar {
    func setDefaultNavigationBarStyle() {
        self.setNavigationBarStyle(UIColor.named(.backgroundColor),
                                   fontColor: UIColor.named(.contentPrimary),
                                   font: ComponentFont.sb18px.font,
                                   largeFont: ComponentFont.sb24px.font)
    }
}
