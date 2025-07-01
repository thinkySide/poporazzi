//
//  UserNotificationService.swift
//  poporazzi
//
//  Created by 김민준 on 6/28/25.
//

import Foundation
import RxSwift
import UserNotifications

struct UserNotificationService: UserNotificationInterface {
    
    /// Notifiaction 권한을 요청합니다.
    func requestAuth() -> Observable<Bool> {
        Observable.create { observer in
            UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound]) { isSuccess, error in
                    observer.onNext(isSuccess)
                    observer.onCompleted()
                }
            return Disposables.create()
        }
    }
    
    /// Notification 권한을 확인합니다.
    func checkAuth() -> Observable<Bool> {
        Observable.create { observer in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                switch settings.authorizationStatus {
                case .authorized: observer.onNext(true)
                default: observer.onNext(false)
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    /// Notification을 등록합니다.
    func registerNotification(title: String, body: String, triggerDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        
        let request = UNNotificationRequest(
            identifier: "\(triggerDate.startDateFormat)-\(title)-\(body)",
            content: content,
            trigger: UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: false
            )
        )
        
        UNUserNotificationCenter.current().add(request) { _ in }
    }
    
    /// 등록된 전체 Notification을 취소합니다.
    func cancelAllNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
