//
//  PermissionRequestModalViewController.swift
//  poporazzi
//
//  Created by 김민준 on 5/21/25.
//

import UIKit
import RxSwift
import RxCocoa

final class PermissionRequestModalViewController: ViewController {
    
    private let scene = PermissionRequestModalView()
    private let viewModel: PermissionRequestModalViewModel
    
    let disposeBag = DisposeBag()
    
    init(viewModel: PermissionRequestModalViewModel) {
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

extension PermissionRequestModalViewController {
    
    func bind() {
        let input = PermissionRequestModalViewModel.Input(
            requestAuthButtonTapped: scene.requestAuthButton.button.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.alertPresented
            .bind(with: self) { owner, alert in
                owner.showAlert(alert)
            }
            .disposed(by: disposeBag)
    }
}
