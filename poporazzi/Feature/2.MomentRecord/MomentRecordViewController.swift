//
//  MomentRecordViewController.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import UIKit
import RxSwift
import RxCocoa

final class MomentRecordViewController: ViewController {
    
    private let screen = MomentRecordView()
    private let viewModel = MomentRecordViewModel()
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        view = screen
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
            viewDidRefresh: screen.albumCollectionView.refreshControl?.rx.controlEvent(.valueChanged).asSignal() ?? .empty(),
            seemoreButtonTapped: screen.seemoreButton.button.rx.tap.asSignal(),
            finishButtonTapped: screen.finishRecordButton.button.rx.tap.asSignal(),
            cameraFloatingButtonTapped: screen.cameraFloatingButton.button.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.record
            .drive(with: self) { owner, record in
                owner.screen.action(.setAlbumTitleLabel(record.title))
                owner.screen.action(.setTrackingStartDateLabel(record.trackingStartDate.startDateFormat))
            }
            .disposed(by: disposeBag)
        
        output.photoList
            .drive(screen.albumCollectionView.rx.items(
                cellIdentifier: MomentRecordCell.identifier,
                cellType: MomentRecordCell.self
            )) { [weak self] index, photo, cell in
                cell.action(.setImage(photo.content))
                self?.screen.albumCollectionView.refreshControl?.endRefreshing()
            }
            .disposed(by: disposeBag)
        
        output.photoList
            .drive(with: self) { owner, photos in
                owner.screen.action(.setTotalImageCountLabel(photos.count))
                owner.screen.albumCollectionView.refreshControl?.endRefreshing()
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
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
}
