//
//  LiveActivityService.swift
//  poporazzi
//
//  Created by 김민준 on 5/1/25.
//

import Foundation
import ActivityKit

class LiveActivityService {
    
    var activity: Activity<PoporazziLiveActivityAttributes>?
    
    func start() {
        guard activity == nil else { return }
        let attributes = PoporazziLiveActivityAttributes(name: "테스트")
        let contentState = PoporazziLiveActivityAttributes.ContentState(value: 5)
        
        do {
            let activity = try Activity<PoporazziLiveActivityAttributes>.request(
                attributes: attributes,
                contentState: contentState
            )
        } catch {
            print(error)
        }
    }
    
    func stop() {
        
    }
}
