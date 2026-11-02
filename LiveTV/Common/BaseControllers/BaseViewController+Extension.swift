//
//  BaseViewController+Extension.swift
//  LiveTV
//
//  Created by 10-N3344 on 9/2/24.
//

import UIKit
import SafariServices
import AVFoundation
import PhotosUI
import MessageUI

// AVAudioSession의 카테고리 설정과 활성화는 동기(블로킹) 호출이라 메인 스레드에서 부르면 UI가 멈출 수 있다.
// 호출 순서(활성화 → 비활성화)를 지키기 위해 전용 직렬 큐에서 처리한다.
private let audioSessionQueue = DispatchQueue(label: "io.appstudio.LiveTV.audioSession", qos: .userInitiated)

// MARK: - SFSafariViewControllerDelegate
extension BaseViewController: SFSafariViewControllerDelegate {

    func showSafariView(urlString: String, modalPresentationStyle: UIModalPresentationStyle = .overFullScreen) {
        guard let url = URL(string: urlString), url.scheme != nil else {
            DLog(">>> 정상적인 링크가 아닙니다.!! :: \(urlString)", level: .error)
            return
        }

        if url.scheme?.lowercased() == "http" || url.scheme?.lowercased() == "https" {
            let safariVC = SFSafariViewController(url: url)
            safariVC.delegate = self
            safariVC.modalPresentationStyle = modalPresentationStyle
            self.present(safariVC, animated: true)
        } else {
            UIApplication.shared.openURL(url: urlString, completion: nil)
        }
    }

    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true)
    }
}

extension BaseViewController {
    func showCameraAndPictureSelectActionSheet(isProfileEditor: Bool = false, handler: @escaping (Int?) -> Void) {
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "사진 찍기", style: .default, handler: { action in
            handler(1)
        }))

        actionSheet.addAction(UIAlertAction(title: "앨범에서 사진 선택", style: .default, handler: { action in
            handler(2)
        }))

        if isProfileEditor {
            actionSheet.addAction(UIAlertAction(title: "사진 삭제", style: .default, handler: { action in
                handler(3)
            }))
        }

        actionSheet.addAction( UIAlertAction(title: "cancel".localization, style: .cancel, handler: { action in
            handler(nil)
        }))

        // 넓은 화면(iPad, 펼친 iPhone Duo)에서는 액션 시트가 팝오버로 바뀌므로 기기 종류와 관계없이 기준 뷰를 지정한다.
        actionSheet.popoverPresentationController?.sourceView = view
        actionSheet.popoverPresentationController?.sourceRect = view.frame
        actionSheet.popoverPresentationController?.permittedArrowDirections = []

        self.present(actionSheet, animated: true, completion: nil)
    }

    func showFileAndVideoSelectActionSheet(handler: @escaping (Int?) -> Void) {
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "파일 추가하기", style: .default, handler: { action in
            handler(1)
        }))

        actionSheet.addAction(UIAlertAction(title: "동영상 추가하기", style: .default, handler: { action in
            handler(2)
        }))

        actionSheet.addAction( UIAlertAction(title: "cancel".localization, style: .cancel, handler: { action in
            handler(nil)
        }))

        // 넓은 화면(iPad, 펼친 iPhone Duo)에서는 액션 시트가 팝오버로 바뀌므로 기기 종류와 관계없이 기준 뷰를 지정한다.
        actionSheet.popoverPresentationController?.sourceView = view
        actionSheet.popoverPresentationController?.sourceRect = view.frame
        actionSheet.popoverPresentationController?.permittedArrowDirections = []

        self.present(actionSheet, animated: true, completion: nil)
    }

    func setAudioSessionActive(_ isActive: Bool, category: AVAudioSession.Category = .playback) {
        audioSessionQueue.async {
            let session = AVAudioSession.sharedInstance()
            // 기존 동작처럼 카테고리 설정이 실패해도 활성화는 시도한다.
            do {
                try session.setCategory(category, mode: .moviePlayback, options: [AVAudioSession.CategoryOptions.allowBluetoothHFP, .allowAirPlay, .allowBluetoothA2DP])
            } catch {
                DLog("AVAudioSession 카테고리 설정 실패 :: \(error)", level: .error)
            }

            do {
                if category == .playAndRecord || category == .record {
                    try session.setActive(isActive, options: .notifyOthersOnDeactivation)
                } else {
                    try session.setActive(isActive)
                }
            } catch {
                DLog("AVAudioSession \(isActive ? "활성화" : "비활성화") 실패 :: \(error)", level: .error)
            }
        }
    }

    func showWebView(viewModel: BaseWebViewModel, isPush: Bool = true) {
        let webVC = BaseWebViewController(viewModel: viewModel)
        if isPush {
            self.pushView(webVC, animated: true)
        } else {
            self.presentNaviView(webVC)
        }

    }
}

extension BaseViewController: MFMailComposeViewControllerDelegate {

    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }

    func showEmailView(address: [String], subject: String, message: String, isHTML: Bool = false ) {
        if !MFMailComposeViewController.canSendMail() {
            alertWith(title: "알림", message: "메일 앱이 없거나 메일 설정이 되지 않아 사용이 불가능합니다.")
            return
        }

        let composeVC = MFMailComposeViewController()
        composeVC.setToRecipients(address)
        composeVC.setSubject(subject)
        composeVC.setMessageBody(message, isHTML: isHTML)
        composeVC.modalPresentationStyle = .overFullScreen
        composeVC.mailComposeDelegate = self
        self.present(composeVC, animated: true, completion: nil)
    }
}

extension BaseViewController: UIDocumentInteractionControllerDelegate {
    public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }

    public func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        controller.dismissPreview(animated: true)
    }
}
