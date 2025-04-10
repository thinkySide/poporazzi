//
//  ViewModel+.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import RxSwift

/// ViewModel을 추상화하는 인터페이스
protocol ViewModel: AnyObject {
    
    /// 이벤트 입력
    associatedtype Input
    
    /// 이벤트 출력
    associatedtype Output
    
    /// 입력을 출력으로 전환하는 함수
    func transform(_ input: Input) -> Output
}
