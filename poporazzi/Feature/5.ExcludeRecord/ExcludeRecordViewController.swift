//
//  ExcludeRecordViewController.swift
//  poporazzi
//
//  Created by 김민준 on 5/5/25.
//

import UIKit
import RxSwift
import RxCocoa

final class ExcludeRecordViewController: ViewController {
    
    private let scene = ExcludeRecordView()
    private let viewModel: ExcludeRecordViewModel
    
    let disposeBag = DisposeBag()
    
    init(viewModel: ExcludeRecordViewModel) {
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

extension ExcludeRecordViewController {
    
    func bind() {
        let input = ExcludeRecordViewModel.Input(
            backButtonTapped: scene.backButton.button.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
    }
}
