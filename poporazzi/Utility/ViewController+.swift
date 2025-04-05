//
//  ViewController+.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import UIKit
import RxSwift

/// ViewController 프로토콜을 편리하게 사용하기 위한 별칭
typealias ViewController = UIViewController & ViewControllerProtocol

/// ViewController 구현 시 필요한 필수 구현 프로토콜
protocol ViewControllerProtocol: UIViewController {
    
    /// 구독권을 저장하는 변수
    var disposeBag: DisposeBag { get set }
    
    /// Input과 Ounput을 Binding합니다.
    func bind()
}
