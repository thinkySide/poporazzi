//
//  MomentRecordViewController.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import UIKit
import RxSwift
import RxCocoa

final class MomentRecordViewController: BaseViewController {
    
    private let viewModel: MomentRecordViewModel
    
    private let scene = MomentRecordView()
    private let disposeBag = DisposeBag()
    
    init(coordinator: AppCoordinator, viewModel: MomentRecordViewModel) {
        self.viewModel = viewModel
        super.init(coordinator: coordinator)
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

extension MomentRecordViewController {
    
    func bind() {
        let input = MomentRecordViewModel.Input(
            viewDidLoad: .just(()),
            viewBecomeActive: Notification.didBecomeActive,
            viewDidRefresh: scene.albumCollectionView.refreshControl?.rx.controlEvent(.valueChanged).asSignal() ?? .empty(),
            seemoreButtonTapped: scene.seemoreButton.button.rx.tap.asSignal(),
            finishButtonTapped: scene.finishRecordButton.button.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.record
            .drive(with: self) { owner, record in
                owner.scene.action(.setAlbumTitleLabel(record.title))
                owner.scene.action(.setTrackingStartDateLabel(record.trackingStartDate.startDateFormat))
            }
            .disposed(by: disposeBag)
        
        output.mediaList
            .drive(scene.albumCollectionView.rx.items(
                cellIdentifier: MomentRecordCell.identifier,
                cellType: MomentRecordCell.self
            )) { [weak self] index, media, cell in
                cell.action(.setImage(media.thumbnail))
                cell.action(.setMediaType(media.mediaType))
                self?.scene.albumCollectionView.refreshControl?.endRefreshing()
            }
            .disposed(by: disposeBag)
        
        output.mediaList
            .drive(with: self) { owner, medias in
                owner.scene.action(.setTotalImageCountLabel(medias.count))
                owner.scene.albumCollectionView.refreshControl?.endRefreshing()
            }
            .disposed(by: disposeBag)
        
        output.seemoreMenuPresented
            .emit(with: self) { owner, menu in
                owner.scene.seemoreButton.button.menu = menu
            }
            .disposed(by: disposeBag)
        
        output.finishAlertPresented
            .emit(with: self) { owner, alert in
                owner.showAlert(alert)
            }
            .disposed(by: disposeBag)
        
        output.saveCompleteAlertPresented
            .emit(with: self) { owner, alert in
                owner.showAlert(alert)
            }
            .disposed(by: disposeBag)
        
        output.navigateToHome
            .emit(with: self) { owner, _ in
                owner.coordinator?.pop()
            }
            .disposed(by: disposeBag)
        
        output.navigateToEdit
            .emit(with: self) { owner, record in
                owner.coordinator?.presentMomentEdit(record: record)
            }
            .disposed(by: disposeBag)
    }
}
