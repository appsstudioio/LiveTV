//
//  BaseViewController.swift
//  LiveTV
//
//  Created by 10-N3344 on 2023/06/14.
//

import UIKit
import SnapKit
import Then
import SafariServices
import Combine
import AVFoundation
import PhotosUI
import MessageUI

public class BaseViewController: UIViewController, UIGestureRecognizerDelegate {

    var cancellables: Set<AnyCancellable> = []

    public override func loadView() {
        super.loadView()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.named(.backgroundGray)
        if #available(iOS 15.0, *) {
            UITableView.appearance().sectionHeaderTopPadding = .leastNonzeroMagnitude
            UITableView.appearance().fillerRowHeight = .leastNonzeroMagnitude
        }
        hideNavigationLeftButton(hidden: false, target: self, action: #selector(moveBack))
        hideNavigationRightButton(hidden: true)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
    }
}
