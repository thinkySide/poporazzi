//
//  HapticManager.swift
//  poporazzi
//
//  Created by 김민준 on 5/7/25.
//

import UIKit

/// 햅틱 관리용
enum HapticManager {
    
    private static let notificationGenerator = UINotificationFeedbackGenerator()
    
    /// 알림 유형의 햅틱을 실행합니다.
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationGenerator.notificationOccurred(type)
    }
    
    /// 세기 별 햅틱을 실행합니다.
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}
