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
    
    private var dataSource: UICollectionViewDiffableDataSource<RecordSection, Media>!
    private let recentIndexPath = BehaviorRelay<IndexPath>(value: [])
    private var cache = [String: UIImage?]()
    
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

// MARK: - RecordSection

typealias SectionMediaList = [(RecordSection, [Media])]

enum RecordSection: Hashable, Comparable {
    case day(order: Int, date: Date)
    
    /// DateFormat을 반환합니다.
    var dateFormat: String {
        switch self {
        case let .day(order, date):
            "\(order)일차"
        }
    }
    
    static func < (lhs: RecordSection, rhs: RecordSection) -> Bool {
        switch (lhs, rhs) {
        case let (.day(order1, _), .day(order2, _)):
            return order1 < order2
        }
    }
}

// MARK: - UICollectionViewDiffableDataSource

extension RecordViewController {
    
    /// DataSource를 설정합니다.
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<RecordSection, Media>(collectionView: scene.recordCollectionView) {
            [weak self] (collectionView, indexPath, media) -> UICollectionViewCell? in
            guard let self, let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RecordCell.identifier,
                for: indexPath
            ) as? RecordCell else { return nil }
            
            if let cacheThumbnail = self.cache[media.id] {
                cell.action(.setImage(cacheThumbnail))
            }
            
            cell.action(.setMediaType(media.mediaType))
            
            return cell
        }
        
        dataSource.supplementaryViewProvider = {
            [weak self] (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: elementKind,
                withReuseIdentifier: RecordHeader.identifier,
                for: indexPath
            ) as? RecordHeader
            
            if let section = self?.dataSource.sectionIdentifier(for: indexPath.section) {
                switch section {
                case let .day(order, date):
                    header?.action(.updateDayCountLabel(order))
                    header?.action(.updateDateLabel(date))
                }
            }
            
            return header
        }
    }
    
    /// 기본 DataSource를 업데이트합니다.
    private func updateInitialDataSource(to sections: SectionMediaList) {
        var snapshot = NSDiffableDataSourceSnapshot<RecordSection, Media>()
        for (section, medias) in sections {
            snapshot.appendSections([section])
            snapshot.appendItems(medias, toSection: section)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    /// 페이지네이션 된 DataSource를 업데이트합니다.
    private func updatePaginationDataSource(to mediaList: [Media]) {
        guard !mediaList.isEmpty else { return }
        
        for media in mediaList {
            cache.updateValue(media.thumbnail, forKey: media.id)
        }
        
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems(mediaList)
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
            }
            .disposed(by: disposeBag)
        
        output.sectionMediaList
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, sections in
                owner.updateInitialDataSource(to: sections)
            }
            .disposed(by: disposeBag)
        
        output.updateRecordCells
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, mediaList in
                owner.updatePaginationDataSource(to: mediaList)
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
