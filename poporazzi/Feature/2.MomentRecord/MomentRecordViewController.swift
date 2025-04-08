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
        let output = viewModel.transform(
            MomentRecordViewModel.Input(
                viewDidLoad: .just(())
            )
        )
        
        output.photoListResponse
            .bind(to: screen.albumCollectionView.rx.items(
                cellIdentifier: MomentRecordCell.identifier,
                cellType: MomentRecordCell.self
            )) { index, photo, cell in
                cell.action(.setImage(photo.content))
            }
            .disposed(by: disposeBag)
    }
}
