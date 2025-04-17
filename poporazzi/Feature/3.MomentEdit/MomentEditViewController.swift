//
//  MomentEditViewController.swift
//  poporazzi
//
//  Created by 김민준 on 4/17/25.
//

import UIKit
import RxSwift
import RxCocoa

final class MomentEditViewController: ViewController {
    
    private let scene = MomentEditView()
    private let viewModel = MomentEditViewModel()
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        view = scene
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
}

// MARK: - Binding

extension MomentEditViewController {
    
    func bind() {
        
    }
}
