//
//  TabBarAnimation+.swift
//  poporazzi
//
//  Created by 김민준 on 6/1/25.
//

import UIKit

/// TabBar 애니메이션을 비활성화하기 위한 클래스
final class NoTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return 0.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        transitionContext.completeTransition(true)
    }
}
