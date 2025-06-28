//
//  UserNotificationInterface.swift
//  poporazzi
//
//  Created by 김민준 on 6/28/25.
//

import Foundation
import RxSwift

protocol UserNotificationInterface {
    
    /// Notifiaction 권한을 요청합니다.
    func requestAuth() -> Observable<Bool>
    
    /// Notification 권한을 확인합니다.
    func checkAuth() -> Observable<Bool>
    
    /// Notification을 등록합니다.
    func registerNotification(title: String, body: String, triggerDate: Date)
}
