//
//  UIViewController+Extension.swift
//  LiveTV
//
//  Created by 10-N3344 on 2023/06/14.
//

import Foundation
import UIKit
import Combine
import Photos
import PhotosUI
import ProgressHUD
import LocalAuthentication

extension UIViewController {
    func showLoading(_ text: String? = nil) {
        DispatchQueue.main.async {
            ProgressHUD.animate(text, interaction: false)
        }
    }

    func hideLoading() {
        DispatchQueue.main.async {
            ProgressHUD.dismiss()
        }
    }
}

// MARK: - BaseViewController Functions
extension UIViewController {
    // MARK: - Alert
    func alertWith(title: String = CommonUtils.getAppName,
                   message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alertView, animated: true, completion: nil)
    }

    func alertConfirmWith(title: String = CommonUtils.getAppName,
                          message: String,
                          cancleButton: String = "취소",
                          okayButton: String = "확인",
                          cancleButtonStyle: UIAlertAction.Style = .cancel,
                          okayButtonStyle: UIAlertAction.Style = .default,
                          completionHandler: @escaping (Bool) -> Void) {
        var titleStr = title
        if titleStr == "" {
            titleStr = CommonUtils.getAppName
        }

        let alertView = UIAlertController(title: titleStr, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: cancleButton, style: cancleButtonStyle, handler: { (_) in
            completionHandler(false)
        }))
        alertView.addAction(UIAlertAction(title: okayButton, style: okayButtonStyle, handler: { (_) in
            completionHandler(true)
        }))
        present(alertView, animated: true, completion: nil)
    }

    func alertWith(title: String = CommonUtils.getAppName,
                   message: String,
                   okayButton: String = "확인",
                   completionHandler: @escaping (Bool) -> Void) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: okayButton, style: .default, handler: { (_) in
            completionHandler(true)
        }))
        present(alertView, animated: true, completion: nil)
    }

    func showCameraView(allowsEditing: Bool = false, mediaTypes: [String] = []) {

       DispatchQueue.main.async {
           let imagePicker = UIImagePickerController()
           imagePicker.sourceType = .camera
           imagePicker.showsCameraControls = true
           if mediaTypes.count == 0 {
               if #available(iOS 14.0, *) {
                   imagePicker.mediaTypes = [UTType.image.identifier]
               } else {
                   imagePicker.mediaTypes = ["public.image"]
               }
           } else {
               imagePicker.mediaTypes = mediaTypes
               imagePicker.videoMaximumDuration = 60
               imagePicker.videoQuality = .typeMedium
           }
           imagePicker.allowsEditing = allowsEditing
           imagePicker.delegate = self as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate)
           imagePicker.modalPresentationStyle = .overFullScreen
           self.present(imagePicker, animated: true)
       }

    }

    @available(iOS 14.0, *)
    func showMutiSelectionPhotoView(selectionLimit: Int, filter: [PHPickerFilter]?) {
        CommonUtils.photoLibraryPermissionCheck(isReadFlag: true) { isAccess, status in
            switch status {
            case .authorized, .limited:
                DispatchQueue.main.async { [weak self] in
                    var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
                    configuration.selectionLimit = selectionLimit
                    if let filter = filter {
                        configuration.filter = .any(of: filter)
                    }
                    let picker = PHPickerViewController(configuration: configuration)
                    picker.delegate = (self as? PHPickerViewControllerDelegate)
                    picker.modalPresentationStyle = .overFullScreen
                    self?.present(picker, animated: true)
                }
            default:
                self.alertWith(message: "사진 접근 권한을 설정하세요.")
                break
            }
        }
    }

    func showImagePickerView(allowsEditing: Bool = false, mediaTypes: [String] = []) {
        CommonUtils.photoLibraryPermissionCheck(isReadFlag: true) { isAccess, status in
            switch status {
            case .authorized, .limited:
                DispatchQueue.main.async {
                    let imagePicker = UIImagePickerController()
                    imagePicker.sourceType = .photoLibrary
                    if mediaTypes.count == 0 {
                        if #available(iOS 14.0, *) {
                            imagePicker.mediaTypes = [UTType.image.identifier]
                        } else {
                            imagePicker.mediaTypes = ["public.image"]
                        }
                    } else {
                        imagePicker.mediaTypes = mediaTypes
                    }
                    imagePicker.allowsEditing = allowsEditing
                    imagePicker.delegate = self as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate)
                    imagePicker.modalPresentationStyle = .overFullScreen
                    self.present(imagePicker, animated: true)
                }
            default:
                self.alertWith(message: "사진 접근 권한을 설정하세요.")
                break
            }
        }
    }

    func setNavigationBarStyle(_ backgroundColor: UIColor,
                               fontColor foregroundColor: UIColor,
                               font: UIFont = ComponentFont.sb18px.font,
                               largeFont: UIFont = ComponentFont.sb24px.font) {

        navigationController?.navigationBar.setNavigationBarStyle(UIColor.named(.mainColor),
                                                                  fontColor: UIColor.named(.contentWhite),
                                                                  font: font,
                                                                  largeFont: largeFont)
    }

    func setDefaultNavigationBarStyle() {
        navigationController?.navigationBar.setDefaultNavigationBarStyle()
    }

    // https://eunjin3786.tistory.com/409
    func presentNaviView(_ viewVC: UIViewController,
                     modalStyle: UIModalPresentationStyle = .fullScreen,
                     animated: Bool = true) {
        self.presentView(BaseNavigationController(rootViewController: viewVC), modalStyle: modalStyle, animated: animated)
    }
}

extension UIViewController {
    func onActionSheet(title: String? = nil,
                       message: String = "",
                       buttons: [UIAlertAction],
                       customView: UIView? ) {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        buttons.forEach {
            actionSheet.addAction($0)
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        actionSheet.addAction(cancel)
        if (UIDevice().userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
            actionSheet.popoverPresentationController?.sourceView = customView
            actionSheet.popoverPresentationController?.sourceRect = customView?.frame ?? .zero
            actionSheet.popoverPresentationController?.permittedArrowDirections = []
        }
        self.present(actionSheet, animated: true, completion: nil)
    }

    func settingAlertAndMoveToSettingApp(message: String) {
        self.alertConfirmWith(title:"알림",
                              message: message,
                              cancleButton: "취소",
                              okayButton: "설정이동",
                              completionHandler: { isOkay in
            if isOkay {
                CommonUtils.openSetting()
            }
        })
    }
}
