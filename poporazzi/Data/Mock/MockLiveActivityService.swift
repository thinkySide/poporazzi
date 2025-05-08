//
//  MockLiveActivityService.swift
//  poporazzi
//
//  Created by 김민준 on 5/7/25.
//

import Foundation

struct MockLiveActivityService: LiveActivityInterface {
    func start(to album: Album) {
        print("[Live Activity 시작] - \(album.title), \(album.trackingStartDate.startDateFullFormat)")
    }
    
    func update(to album: Album, totalCount: Int) {
        print("[Live Activity 업데이트] - \(album.title), \(album.trackingStartDate.startDateFullFormat), 총\(totalCount)개")
    }
    
    func stop() {
        print("[Live Activity 종료]")
    }
}
