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
    
    enum Section {
        case main
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Media>!
    private let recentIndexPath = BehaviorRelay<IndexPath>(value: [])
    private var cache = [IndexPath: UIImage?]()
    
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
        setupDataSource()
        bind()
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - UICollectionViewDiffableDataSource

extension RecordViewController {
    
    /// DataSource를 설정합니다.
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Media>(collectionView: scene.recordCollectionView) {
            [weak self] (collectionView, indexPath, media) -> UICollectionViewCell? in
            guard let self, let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RecordCell.identifier,
                for: indexPath
            ) as? RecordCell else { return nil }
            
            if let cacheThumbnail = self.cache[indexPath] {
                cell.action(.setImage(cacheThumbnail))
            }
            
            cell.action(.setMediaType(media.mediaType))
            
            return cell
        }
    }
    
    /// 기본 DataSource를 업데이트합니다.
    private func updateInitialDataSource(to medias: [Media]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Media>()
        snapshot.appendSections([.main])
        snapshot.appendItems(medias, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    /// 페이지네이션 된 DataSource를 업데이트합니다.
    private func updatePaginationDataSource(to medias: [OrderedMedia]) {
        guard !medias.isEmpty else {
            return
        }
        
        medias.forEach { cache.updateValue($1.thumbnail, forKey: .init(row: $0, section: 0)) }
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems(medias.map { $0.1 })
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - Binding

extension RecordViewController {
    
    func bind() {
        let input = RecordViewModel.Input(
            viewDidLoad: .just(()),
            selectButtonTapped: scene.selectButton.button.rx.tap.asSignal(),
            selectCancelButtonTapped: scene.selectCancelButton.button.rx.tap.asSignal(),
            recentIndexPath: recentIndexPath,
            recordCellSelected: scene.recordCollectionView.rx.itemSelected.asSignal(),
            recordCellDeselected: scene.recordCollectionView.rx.itemDeselected.asSignal(),
            excludeButtonTapped: scene.excludeButton.button.rx.tap.asSignal(),
            removeButtonTapped: scene.removeButton.button.rx.tap.asSignal(),
            finishButtonTapped: scene.finishRecordButton.button.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        scene.recordCollectionView.rx.willDisplayCell
            .bind(with: self) { owner, cell in
                let indexPath = IndexPath(row: cell.at.row, section: cell.at.section)
                owner.recentIndexPath.accept(indexPath)
            }
            .disposed(by: disposeBag)
        
        output.album
            .bind(with: self) { owner, album in
                owner.scene.action(.setAlbumTitleLabel(album.title))
                owner.scene.action(.setStartDateLabel(album.trackingStartDate.startDateFormat))
            }
            .disposed(by: disposeBag)
        
        output.mediaList
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, medias in
                owner.scene.action(.setTotalImageCountLabel(medias.count))
                owner.updateInitialDataSource(to: medias)
            }
            .disposed(by: disposeBag)
        
        output.updateRecordCells
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, orderedMediaList in
                owner.updatePaginationDataSource(to: orderedMediaList)
            }
            .disposed(by: disposeBag)
        
        output.selectedRecordCells
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, selectedMedias in
                owner.scene.action(.updateSelectedCountLabel(selectedMedias.count))
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
