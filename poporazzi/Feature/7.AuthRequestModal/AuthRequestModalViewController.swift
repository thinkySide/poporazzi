//
//  AuthRequestModalViewController.swift
//  poporazzi
//
//  Created by 김민준 on 5/21/25.
//

import UIKit
import RxSwift
import RxCocoa

final class AuthRequestModalViewController: ViewController {
    
    private let scene = AuthRequestModalView()
    private let viewModel: AuthRequestModalViewModel
    
    let disposeBag = DisposeBag()
    
    init(viewModel: AuthRequestModalViewModel) {
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

extension AuthRequestModalViewController {
    
    func bind() {
        let input = AuthRequestModalViewModel.Input(
            
        )
        let output = viewModel.transform(input)
        
    }
}

