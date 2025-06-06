//
//  LiveActivityService.swift
//  poporazzi
//
//  Created by 김민준 on 5/1/25.
//

import Foundation
import ActivityKit

final class LiveActivityService: LiveActivityInterface {
    
    private var activity: Activity<PoporazziWidgetAttributes>?
    
    init() {
        self.activity = Activity<PoporazziWidgetAttributes>.activities.first
    }
}

// MARK: - Use Case

extension LiveActivityService {
    
    /// Live Activity를 시작합니다.
    func start(to album: Record) {
        guard activity == nil else { return }
        let attributes = PoporazziWidgetAttributes()
        let contentState = PoporazziWidgetAttributes.ContentState(
            albumTitle: album.title,
            startDate: album.startDate,
            totalCount: 0
        )
        let content = ActivityContent(state: contentState, staleDate: nil)
        
        do {
            activity = try Activity<PoporazziWidgetAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        } catch {
            print(error)
        }
    }
    
    /// Live Activity를 업데이트합니다.
    func update(to album: Record, totalCount: Int) {
        guard let activity = activity else { return }
        
        let contentState = PoporazziWidgetAttributes.ContentState(
            albumTitle: album.title,
            startDate: album.startDate,
            totalCount: totalCount
        )
        let content = ActivityContent(state: contentState, staleDate: nil)
        
        Task {
            await activity.update(content)
        }
    }
    
    /// Live Activity를 종료합니다.
    func stop() {
        Task {
            await activity?.end(nil, dismissalPolicy: .immediate)
            self.activity = nil
        }
    }
}
