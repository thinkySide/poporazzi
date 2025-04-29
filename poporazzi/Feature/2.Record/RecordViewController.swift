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
    private let disposeBag = DisposeBag()
    
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
}

// MARK: - Binding

extension RecordViewController {
    
    func bind() {
        let input = RecordViewModel.Action(
            viewDidLoad: .just(()),
            viewBecomeActive: Notification.didBecomeActive,
            refresh: scene.albumCollectionView.refreshControl?.rx.controlEvent(.valueChanged).asSignal() ?? .empty(),
            seemoreButtonTapped: scene.seemoreButton.button.rx.tap.asSignal(),
            finishButtonTapped: scene.finishRecordButton.button.rx.tap.asSignal()
        )
        let state = viewModel.transform(input)
        
        state.record
            .bind(with: self) { owner, record in
                owner.scene.action(.setAlbumTitleLabel(record.title))
                owner.scene.action(.setTrackingStartDateLabel(record.trackingStartDate.startDateFormat))
            }
            .disposed(by: disposeBag)
        
        state.mediaList
            .bind(to: scene.albumCollectionView.rx.items(
                cellIdentifier: MomentRecordCell.identifier,
                cellType: MomentRecordCell.self
            )) { [weak self] index, media, cell in
                cell.action(.setImage(media.thumbnail))
                cell.action(.setMediaType(media.mediaType))
                self?.scene.albumCollectionView.refreshControl?.endRefreshing()
            }
            .disposed(by: disposeBag)
        
        state.mediaList
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, medias in
                owner.scene.action(.setTotalImageCountLabel(medias.count))
                owner.scene.albumCollectionView.refreshControl?.endRefreshing()
            }
            .disposed(by: disposeBag)
        
//        effect.seemoreMenuPresented
//            .bind(with: self) { owner, menu in
//                owner.scene.seemoreButton.button.menu = menu
//            }
//            .disposed(by: disposeBag)
//        
//        effect.finishAlertPresented
//            .bind(with: self) { owner, alert in
//                owner.showAlert(alert)
//            }
//            .disposed(by: disposeBag)
//        
//        effect.saveCompleteAlertPresented
//            .observe(on: MainScheduler.instance)
//            .bind(with: self) { owner, alert in
//                owner.showAlert(alert)
//            }
//            .disposed(by: disposeBag)
    }
}
