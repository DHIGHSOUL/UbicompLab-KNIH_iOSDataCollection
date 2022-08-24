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
        if UserDefaults.standard.integer(forKey: "appAuthorization") != 1 {
            MainViewController.shared.requestLocationAuthorization()
            NotificationManager.shared.requestNotificationAuthorization()
            HealthDataManager.shared.requestHealthDataAuthorization()
        } else {
            NotificationManager.shared.notificationCenter.delegate = self
            
            MainViewController.shared.makeRealm()
            CSVFileManager.shared.createSensorCSVFolder()
            CSVFileManager.shared.createHealthCSVFolder()
            NotificationManager.shared.setAskSurveyNotification()
            NetWorkManager.shared.startMonitoring()
            HealthDataManager.shared.setHealthDataLoop()
            DataCollectionManager.shared.dataCollectionManagerMethod()
            DataCollectionManager.shared.checkAndReUploadSensorFiles()
            HealthDataManager.shared.checkAndReUploadHealthFiles()
        }
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        if UserDefaults.standard.integer(forKey: "appAuthorization") == 1 {
            NotificationManager.shared.setTerminateNotification()
        }
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Foreground 상태에서 푸시 알림을 클릭했을 때의 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner, .sound])
    }
    
    // 백그라운드에서 알림을 클릭하면 앞으로 보낼 알림, 이미 보내진 알림을 모두 삭제함
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        NotificationManager.shared.notificationCenter.removeAllPendingNotificationRequests()
        NotificationManager.shared.notificationCenter.removeAllDeliveredNotifications()
        NotificationManager.shared.setAskSurveyNotification()
        
        completionHandler()
    }
    
}
