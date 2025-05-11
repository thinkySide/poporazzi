//
//  FinishModalViewController.swift
//  poporazzi
//
//  Created by 김민준 on 5/11/25.
//

import UIKit
import RxSwift
import RxCocoa

final class FinishModalViewController: ViewController {
    
    private let scene = FinishModalView()
    private let viewModel: FinishModalViewModel
    
    let disposeBag = DisposeBag()
    
    init(viewModel: FinishModalViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        view = scene
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Binding

extension FinishModalViewController {
    
    func bind() {
        
    }
}
