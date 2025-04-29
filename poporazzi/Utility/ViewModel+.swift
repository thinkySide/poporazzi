//
//  ViewModel+.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import RxSwift

/// ViewModel을 추상화하는 인터페이스
protocol ViewModel: AnyObject {
    
    /// 이벤트 액션
    associatedtype Input
    
    /// 출력
    associatedtype Output
    
    /// 이벤트 액션 바인딩
    func transform(_ input: Input) -> Output
}
