//
//  LiveActivityService.swift
//  poporazzi
//
//  Created by 김민준 on 5/1/25.
//

import Foundation
import ActivityKit

class LiveActivityService {
    
    var activity: Activity<PoporazziWidgetAttributes>?
    
    func start(_ albumTitle: String, startDate: Date, totalCount: Int) {
        guard activity == nil else { return }
        let attributes = PoporazziWidgetAttributes()
        let contentState = PoporazziWidgetAttributes.ContentState(
            albumTitle: albumTitle,
            startDate: startDate,
            totalCount: totalCount
        )
        
        do {
            let activity = try Activity<PoporazziWidgetAttributes>.request(
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
