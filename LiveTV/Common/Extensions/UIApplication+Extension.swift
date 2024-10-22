//
//  UIApplication+Extension.swift
//  LiveTV
//
//  Created by 10-N3344 on 2023/06/14.
//

import UIKit

extension UIApplication {
    static var sceneDelegate: SceneDelegate? {
        return self.shared.connectedScenes.first?.delegate as? SceneDelegate
    }
}
