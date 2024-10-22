//
//  AppDelegate.swift
//  LiveTV
//
//  Created by 10-N3344 on 10/17/24.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAnalytics
import FirebaseCrashlytics
import GoogleCast

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let kReceiverAppID = kGCKDefaultMediaReceiverApplicationID

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupFirebase()
        // Firebase logger setting
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        Analytics.setAnalyticsCollectionEnabled(true)
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)
        Crashlytics.crashlytics().checkForUnsentReports { hasUnsentReport in
            let hasUserConsent = false
            // ...get user consent.
            if hasUserConsent && hasUnsentReport {
                Crashlytics.crashlytics().sendUnsentReports()
            } else {
                Crashlytics.crashlytics().deleteUnsentReports()
            }
        }

        // Detect when a crash happens during your app's last run.
        if Crashlytics.crashlytics().didCrashDuringPreviousExecution() {
          // ...notify the user.
            DLog("Notify the user. didCrashDuringPreviousExecution")
        }

        CommonFunctions.kingfisherConfig()
        CommonFunctions.progressHUDConfig()

        let discoveryCriteria = GCKDiscoveryCriteria(applicationID: kReceiverAppID)
        let options = GCKCastOptions(discoveryCriteria: discoveryCriteria)
        GCKCastContext.setSharedInstanceWith(options)

        // disable autolayout logging
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate {
    private func setupFirebase() {
        // Firebase service file
        let fileName = Bundle.getInfoPlistValue(forKey: .firebaseServiceFile)
        if let filePath = Bundle.getPlistFile(fileName: fileName),
            let options = FirebaseOptions(contentsOfFile: filePath) {
            DLog(">>> filePath = \(filePath)")
            FirebaseApp.configure(options: options)
        } else {
            DLog(">>> filePath = FirebaseApp.configure()")
            FirebaseApp.configure()
        }
    }
}
