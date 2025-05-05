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
            viewDidLoad: .just(()),
            backButtonTapped: scene.backButton.button.rx.tap.asSignal(),
            selectButtonTapped: scene.selectButton.button.rx.tap.asSignal(),
            selectCancelButtonTapped: scene.selectCancelButton.button.rx.tap.asSignal(),
            recordCellSelected: scene.recordCollectionView.rx.modelSelected(Media.self).asSignal(),
            recordCellDeselected: scene.recordCollectionView.rx.modelDeselected(Media.self).asSignal(),
            recoverButtonTapped: scene.recoverButton.button.rx.tap.asSignal(),
            removeButtonTapped: scene.removeButton.button.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.mediaList
            .observe(on: MainScheduler.instance)
            .bind(to: scene.recordCollectionView.rx.items(
                cellIdentifier: RecordCell.identifier,
                cellType: RecordCell.self
            )) { index, media, cell in
                cell.action(.setImage(media.thumbnail))
                cell.action(.setMediaType(media.mediaType))
            }
            .disposed(by: disposeBag)
        
        output.mediaList
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, medias in
                owner.scene.action(.setTotalImageCountLabel(medias.count))
            }
            .disposed(by: disposeBag)
        
        output.selectedRecordCells
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, selectedMedias in
                owner.scene.action(.updateSelectedCountLabel(selectedMedias.count))
            }
            .disposed(by: disposeBag)
        
        output.switchSelectMode
            .bind(with: self) { owner, bool in
                owner.scene.action(.toggleSelectMode(bool))
            }
            .disposed(by: disposeBag)
        
        output.alertPresented
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, alert in
                owner.showAlert(alert)
            }
            .disposed(by: disposeBag)
        
        output.actionSheetPresented
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, actionSheet in
                owner.showActionSheet(actionSheet)
            }
            .disposed(by: disposeBag)
        
        output.toggleLoading
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, isActive in
                owner.scene.action(.toggleLoading(isActive))
            }
            .disposed(by: disposeBag)
    }
}
