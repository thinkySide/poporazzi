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
    private lazy var input = MomentRecordViewModel.Input(
        viewDidLoad: .just(()),
        refresh: screen.albumCollectionView.refreshControl?
            .rx.controlEvent(.valueChanged).asObservable() ?? .empty(),
        finishButtonTapped: screen.finishRecordButton.button
            .rx.tap.asObservable(),
        saveToAlbumButtonTapped: .init()
    )
    
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
        let output = viewModel.transform(input)
        
        output.currentRecord
            .bind(with: self) { owner, record in
                owner.screen.action(.setAlbumTitleLabel(record.title))
                owner.screen.action(.setTrackingStartDateLabel(record.trackingStartDate.startDateFormat))
            }
            .disposed(by: disposeBag)
        
        output.photoList
            .observe(on: MainScheduler.instance)
            .bind(to: screen.albumCollectionView.rx.items(
                cellIdentifier: MomentRecordCell.identifier,
                cellType: MomentRecordCell.self
            )) { [weak self] index, photo, cell in
                cell.action(.setImage(photo.content))
                self?.screen.albumCollectionView.refreshControl?.endRefreshing()
            }
            .disposed(by: disposeBag)
        
        output.photoList
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, photos in
                owner.screen.action(.setTotalImageCountLabel(photos.count))
                owner.screen.albumCollectionView.refreshControl?.endRefreshing()
            }
            .disposed(by: disposeBag)
        
        output.finishAlertPresented
            .bind(with: self) { owner, _ in
                owner.showFinishAlert()
            }
            .disposed(by: disposeBag)
        
        output.saveToAlbum
            .bind(with: self) { owner, _ in
                UserDefaultsService.isTracking = false
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Alert

extension MomentRecordViewController {
    
    private func showFinishAlert() {
        let title = UserDefaultsService.albumTitle
        let totalCount = viewModel.output.photoList.value.count
        showAlert(
            title: "기록을 종료합니다",
            message: "총 \(totalCount)장의 '\(title)' 기록이 종료돼요",
            confirmTitle: "종료"
        )
        .subscribe { actionType in
            switch actionType {
            case .cancel:
                break
            case .confirm:
                self.input.saveToAlbumButtonTapped.accept(())
            }
        }
        .disposed(by: disposeBag)
    }
}
