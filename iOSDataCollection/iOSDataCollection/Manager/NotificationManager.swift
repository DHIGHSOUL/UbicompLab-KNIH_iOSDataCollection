//
//  NotificationManager.swift
//  iOSDataCollection
//
//  Created by ROLF J. on 2022/08/01.
//

import Foundation
import UserNotifications

class NotificationManager {
    
    static let shared = NotificationManager()
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    // 유저에게 알림을 보낼 권한을 허용받는 메소드
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions(arrayLiteral: .alert, .sound)
        
        notificationCenter.requestAuthorization(options: authOptions) { success, error in
            if let error = error {
                print("NotificationAuthorizationError = \(error)")
                self.requestNotificationAuthorization()
            } else {
                if success {
                    print("알림 권한 획득")
                } else {
                    print("알림 권한 거부")
                    self.requestNotificationAuthorization()
                }
            }
        }
    }
    
    // 앱이 종료될 시 유저에게 보낼 알림을 설정
    func setTerminateNotification() {
        print("앱 재실행 유도 시작")
        
        let notificaitonContent = UNMutableNotificationContent()
        notificaitonContent.title = LanguageChange.NotiWord.appOpen
        notificaitonContent.body = LanguageChange.NotiWord.cantCheckData
        notificaitonContent.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        let request = UNNotificationRequest(identifier: "appTerminateNotification", content: notificaitonContent, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    // 금일 설문조사를 진행하였는지 묻는 알림을 설정(일 단위 갱신)
    func setAskSurveyNotification() {
        let notificationCenter = NotificationManager.shared.notificationCenter
        
        print("설문조사 알림 설정")
        
        let notificaitonContent = UNMutableNotificationContent()
        notificaitonContent.title = LanguageChange.NotiWord.surveyTime
        notificaitonContent.body = LanguageChange.NotiWord.finishSurvery
        notificaitonContent.sound = .default
        
        let surveyAskTime = DateComponents(hour: 23, minute: 00, second: 00)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: surveyAskTime, repeats: true)
        let request = UNNotificationRequest(identifier: "askSurveyNotification", content: notificaitonContent, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
}
