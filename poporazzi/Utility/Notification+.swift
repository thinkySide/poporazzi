//
//  Notification+.swift
//  poporazzi
//
//  Created by 김민준 on 4/16/25.
//

import UIKit
import RxCocoa

extension Notification {
    
    /// 앱이 활성화되면 게시되는 알림 Signal입니다.
    static var didBecomeActive: Signal<Notification> {
        let didBecomeActiveNotification = UIApplication.didBecomeActiveNotification
        return NotificationCenter.default
            .rx.notification(didBecomeActiveNotification).asSignal(
                onErrorJustReturn: .init(name: didBecomeActiveNotification)
            )
    }
}
