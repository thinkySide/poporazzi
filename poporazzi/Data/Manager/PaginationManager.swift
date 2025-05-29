//
//  PaginationManager.swift
//  poporazzi
//
//  Created by 김민준 on 5/29/25.
//

import Foundation

final class PaginationManager {
    
    /// 기본 페이지네이션 사이즈
    private let pageSize: Int
    
    /// 페이지네이션 임계값
    private let threshold: Int
    
    /// 마지막으로 업데이트 된 인덱스
    private var lastFetchIndex = 0
    
    init(
        pageSize: Int,
        threshold: Int
    ) {
        self.pageSize = pageSize
        self.threshold = threshold
    }
}

// MARK: - UseCase

extension PaginationManager {
    
    /// 현재 인덱스를 기준으로 페이지네이션 여부를 확인합니다.
    func isPagination(to currentIndex: Int) -> Bool {
        currentIndex >= lastFetchIndex + pageSize - threshold
    }
    
    /// 페이지네이션 리스트를 계산 후 반환합니다.
    func paginationList<Element>(from targetList: [Element]) -> [Element] {
        let start = min(lastFetchIndex, targetList.count)
        let end = min(pageSize + start, targetList.count)
        return Array(targetList[start..<end])
    }
    
    /// 다음 페이지네이션을 위해 정보를 업데이트합니다.
    func updateForNextPagination() {
        lastFetchIndex += pageSize
    }
    
    /// 페이지네이션 정보를 초기화합니다.
    func reset() {
        lastFetchIndex = 0
    }
}
