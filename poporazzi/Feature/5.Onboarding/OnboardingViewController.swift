//
//  OnboardingViewController.swift
//  poporazzi
//
//  Created by 김민준 on 6/4/25.
//

import UIKit
import RxSwift
import RxCocoa

final class OnboardingViewController: ViewController {
    
    private let scene = OnboardingView()
    private let viewModel: OnboardingViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

extension OnboardingViewController {
    
    func bind() {
        let input = OnboardingViewModel.Input(
            
            
        )
        let output = viewModel.transform(input)
    }
}
