//
//  RecordViewController.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import UIKit
import RxSwift
import RxCocoa

final class RecordViewController: ViewController {
    
    private let scene = RecordView()
    private let viewModel: RecordViewModel
    
    let disposeBag = DisposeBag()
    
    init(viewModel: RecordViewModel) {
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

extension RecordViewController {
    
    func bind() {
        let input = RecordViewModel.Input(
            viewDidLoad: .just(()),
            selectButtonTapped: scene.selectButton.button.rx.tap.asSignal(),
            selectCancelButtonTapped: scene.selectCancelButton.button.rx.tap.asSignal(),
            finishButtonTapped: scene.finishRecordButton.button.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.album
            .bind(with: self) { owner, album in
                owner.scene.action(.setAlbumTitleLabel(album.title))
                owner.scene.action(.setStartDateLabel(album.trackingStartDate.startDateFormat))
            }
            .disposed(by: disposeBag)
        
        output.mediaList
            .bind(to: scene.recordCollectionView.rx.items(
                cellIdentifier: MomentRecordCell.identifier,
                cellType: MomentRecordCell.self
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
        
        output.setupSeeMoreMenu
            .bind(with: self) { owner, menus in
                owner.scene.seemoreButton.button.menu = menus.toUIMenu
            }
            .disposed(by: disposeBag)
        
        output.switchSelectMode
            .bind(with: self) { owner, bool in
                owner.scene.action(.toggleSelectMode(bool))
            }
            .disposed(by: disposeBag)
        
        output.alertPresented
            .bind(with: self) { owner, alert in
                owner.showAlert(alert)
            }
            .disposed(by: disposeBag)
    }
}
