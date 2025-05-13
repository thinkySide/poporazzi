//
//  AlbumOptionInputViewController.swift
//  poporazzi
//
//  Created by 김민준 on 5/13/25.
//

import UIKit
import RxSwift
import RxCocoa

final class AlbumOptionInputViewController: ViewController {
    
    private let scene = AlbumOptionInputView()
    private let viewModel: AlbumOptionInputViewModel
    
    let disposeBag = DisposeBag()
    
    init(viewModel: AlbumOptionInputViewModel) {
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

extension AlbumOptionInputViewController {
    
    func bind() {
        let input = AlbumOptionInputViewModel.Input(
            backButtonTapped: scene.backButton.button.rx.tap.asSignal(),
            startButtonTapped: scene.startButton.button.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
    }
}
