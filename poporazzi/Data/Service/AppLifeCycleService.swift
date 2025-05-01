//
//  AppLifeCycleService.swift
//  poporazzi
//
//  Created by 김민준 on 5/1/25.
//

import UIKit
import RxSwift
import RxCocoa

/// 앱 전반의 라이프 사이클을 관리하기 위한 객체
final class AppLifeCycleService {
    
    static let shared = AppLifeCycleService()
    private init() {}
    
    var disposeBag = DisposeBag()
    
    /// 앱 화면 진입 시 호출되는 LifeCycle
    let didBecomeActive = PublishRelay<Void>()
    
    func dispose() {
        disposeBag = DisposeBag()
    }
}
