//
//  LiveActivityInterface.swift
//  poporazzi
//
//  Created by 김민준 on 5/7/25.
//

import Foundation

protocol LiveActivityInterface {
    
    /// Live Activity를 시작합니다.
    func start(to album: Album)
    
    /// Live Activity를 업데이트합니다.
    func update(to album: Album, totalCount: Int)
    
    /// Live Activity를 종료합니다.
    func stop()
}
