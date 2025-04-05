//
//  MomentRecordViewController.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import UIKit
import RxSwift
import RxCocoa

final class MomentRecordViewController: ViewController {
    
    let uuid = UUID()
    private let viewModel = MomentRecordViewModel()
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
}

// MARK: - Binding

extension MomentRecordViewController {
    
    func bind() {
        
    }
}
