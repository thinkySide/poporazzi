//
//  MockLiveActivityService.swift
//  poporazzi
//
//  Created by 김민준 on 5/7/25.
//

import Foundation

struct MockLiveActivityService: LiveActivityInterface {
    func start(to album: Record) {
        print("[Live Activity 시작] - \(album.title), \(album.startDate.description)")
    }
    
    func update(to album: Record, totalCount: Int) {
        print("[Live Activity 업데이트] - \(album.title), \(album.startDate.description), 총\(totalCount)개")
    }
    
    func stop() {
        print("[Live Activity 종료]")
    }
}
