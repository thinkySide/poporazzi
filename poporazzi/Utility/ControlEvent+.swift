//
//  ControlEvent+.swift
//  poporazzi
//
//  Created by 김민준 on 4/29/25.
//

import RxCocoa

extension ControlEvent {
    
    /// ControlEvent를 Void로 변환 후 Signal로 반환합니다.
    func asVoidSignal() -> Signal<Void> {
        self.map { _ in }.asSignal(onErrorJustReturn: ())
    }
}
