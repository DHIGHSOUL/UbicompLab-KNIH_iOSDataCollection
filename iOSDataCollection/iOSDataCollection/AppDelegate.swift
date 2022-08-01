//
//  AppDelegate.swift
//  iOSDataCollection
//
//  Created by ROLF J. on 2022/07/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NotificationManager.shared.notificationCenter.delegate = self
        NotificationManager.shared.requestNotificationAuthorization()
        NetWorkManager.shared.startMonitoring()
        CSVFileManager.shared.createCSVFolder()
        DataCollectionManager.shared.dataCollectionManagerMethod()
        DataCollectionManager.shared.checkAndReUploadFiles()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
//        NotificationManager.shared.setTerminateNotification()
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // 백그라운드에서 알림을 클릭하면 앞으로 보낼 알림, 이미 보내진 알림을 모두 삭제함
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        NotificationManager.shared.notificationCenter.removeAllPendingNotificationRequests()
        NotificationManager.shared.notificationCenter.removeAllDeliveredNotifications()
        completionHandler()
    }
    
}
