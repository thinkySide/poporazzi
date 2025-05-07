//
//  HapticService.swift
//  poporazzi
//
//  Created by 김민준 on 5/7/25.
//

import UIKit

enum HapticService {
    
    private static let notificationGenerator = UINotificationFeedbackGenerator()
    
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationGenerator.notificationOccurred(type)
    }
    
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}
