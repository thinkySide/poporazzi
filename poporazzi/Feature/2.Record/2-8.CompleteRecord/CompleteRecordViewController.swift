//
//  CompleteRecordViewController.swift
//  poporazzi
//
//  Created by 김민준 on 6/17/25.
//

import UIKit
import RxSwift
import RxCocoa

final class CompleteRecordViewController: ViewController {
    
    private let scene = CompleteRecordView()
    private let viewModel: CompleteRecordViewModel
    
    let disposeBag = DisposeBag()
    
    init(viewModel: CompleteRecordViewModel) {
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
        setupLoadingIndicator()
        bind()
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Binding

extension CompleteRecordViewController {
    
    func bind() {
        let input = CompleteRecordViewModel.Input(
            shareButtonTapped: scene.shareButton.rx.tap.asSignal(),
            showAlbumButtonTapped: scene.showAlbumButton.button.rx.tap.asSignal(),
            backToHomeButtonTapped: scene.backToHomeButton.button.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.record
            .bind(with: self) { owner, record in
                owner.scene.action(.updateRecordInfo(record))
            }
            .disposed(by: disposeBag)
        
        output.mediaList
            .bind(with: self) { owner, mediaList in
                owner.scene.action(.updateTitleLabel(mediaList.count))
            }
            .disposed(by: disposeBag)
        
        output.randomImageList
            .bind(with: self) { owner, imageList in
                owner.scene.action(.updateRandomImageView(imageList))
            }
            .disposed(by: disposeBag)
        
        output.toggleLoading
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, isLoading in
                owner.toggleLoadingIndicator(isLoading)
            }
            .disposed(by: disposeBag)
    }
}
