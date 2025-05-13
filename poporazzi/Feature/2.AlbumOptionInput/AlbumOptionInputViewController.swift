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
            allSaveChoiceChipTapped: scene.allChoiceChip.button.rx.tap.asSignal(),
            photoChoiceChipTapped: scene.photoChoiceChip.button.rx.tap.asSignal(),
            videoChoiceChipTapped: scene.videoChoiceChip.button.rx.tap.asSignal(),
            selfShootingOptionCheckBoxTapped: scene.selfShootingOptionCheckBox.button.rx.tap.asSignal(),
            downloadOptionCheckBox: scene.downloadOptionCheckBox.button.rx.tap.asSignal(),
            screenshotOptionCheckBox: scene.screenshotOptionCheckBox.button.rx.tap.asSignal(),
            startButtonTapped: scene.startButton.button.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.mediaFetchOption
            .bind(with: self) { owner, fetchOption in
                owner.scene.action(.updateMediaFetchOption(fetchOption))
            }
            .disposed(by: disposeBag)
        
        output.mediaFilterOption
            .bind(with: self) { owner, filterOption in
                owner.scene.action(.updateMediaFilterOption(filterOption))
            }
            .disposed(by: disposeBag)
    }
}
