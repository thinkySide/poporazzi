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

extension AlbumOptionInputViewController {
    
    func bind() {
        let input = AlbumOptionInputViewModel.Input(
            backButtonTapped: scene.backButton.button.rx.tap.asSignal(),
            allFetchChoiceChipTapped: scene.allFetchChoiceChip.button.rx.tap.asSignal(),
            photoFetchChoiceChipTapped: scene.photoFetchChoiceChip.button.rx.tap.asSignal(),
            videoFetchChoiceChipTapped: scene.videoFetchChoiceChip.button.rx.tap.asSignal(),
            selfShootingFilterCheckBoxTapped: scene.selfShootingFilterCheckBox.tapGesture.rx.event.asVoidSignal(),
            downloadFilterCheckBox: scene.downloadFilterCheckBox.tapGesture.rx.event.asVoidSignal(),
            screenshotFilterCheckBox: scene.screenshotFilterCheckBox.tapGesture.rx.event.asVoidSignal(),
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
        
        output.isStartButtonEnabled
            .bind(with: self) { owner, isValid in
                owner.scene.action(.toggleStartButton(isValid))
            }
            .disposed(by: disposeBag)
    }
}
