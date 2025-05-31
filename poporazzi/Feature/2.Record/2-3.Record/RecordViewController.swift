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
    private let event = Event()
    
    private var dataSource: UICollectionViewDiffableDataSource<MediaSection, Media>!
    private var albumCache = Record.initialValue
    private var totalCount = 0
    
    private let contextMenuPresented = PublishRelay<IndexPath>()
    
    let disposeBag = DisposeBag()
    
    init(viewModel: RecordViewModel) {
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
        setupCollectionView()
        setupDataSource()
        bind()
        setupMenu()
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Event

extension RecordViewController {
    
    struct Event {
        let willDisplayIndexPath = PublishRelay<IndexPath>()
    }
}

// MARK: - UICollectionView

extension RecordViewController {
    
    /// CollectionView를 세팅합니다.
    private func setupCollectionView() {
        let collectionView = scene.recordCollectionView
        collectionView.delegate = self
        collectionView.collectionViewLayout = collectionViewLayout
        collectionView.register(
            RecordCell.self,
            forCellWithReuseIdentifier: RecordCell.identifier
        )
        collectionView.register(
            RecordTitleHeader.self,
            forSupplementaryViewOfKind: CollectionViewLayout.mainHeaderKind,
            withReuseIdentifier: RecordTitleHeader.identifier
        )
        collectionView.register(
            RecordDateHeader.self,
            forSupplementaryViewOfKind: CollectionViewLayout.subHeaderKind,
            withReuseIdentifier: RecordDateHeader.identifier
        )
    }
    
    /// CollectionViewLayout을 반환합니다.
    private var collectionViewLayout: UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            let section = CollectionViewLayout.recordLayout
            var supplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem] = []
            
            let subHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(36)
                ),
                elementKind: CollectionViewLayout.subHeaderKind,
                alignment: .top
            )
            subHeader.pinToVisibleBounds = true
            
            if sectionIndex == 0 {
                let mainHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(64)
                    ),
                    elementKind: CollectionViewLayout.mainHeaderKind,
                    alignment: .top
                )
                mainHeader.zIndex = 0
                supplementaryItems = [mainHeader, subHeader]
            } else {
                supplementaryItems = [subHeader]
            }
            section.boundarySupplementaryItems = supplementaryItems
            
            section.visibleItemsInvalidationHandler = { visibleItems, point, _ in
                
            }
            
            return section
        }
    }
}

// MARK: - UICollectionViewDiffableDataSource

extension RecordViewController {
    
    /// DataSource를 설정합니다.
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<MediaSection, Media>(collectionView: scene.recordCollectionView) {
            [weak self] (collectionView, indexPath, media) -> UICollectionViewCell? in
            guard let self, let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RecordCell.identifier,
                for: indexPath
            ) as? RecordCell else { return nil }
            
            if let thumbnail = self.viewModel.thumbnailList[media] {
                cell.action(.setMedia(media, thumbnail))
            } else {
                cell.action(.setMedia(media, nil))
            }
            
            return cell
        }
        
        dataSource.supplementaryViewProvider = {
            [weak self] (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            guard let self else { return nil }
            
            if elementKind == CollectionViewLayout.mainHeaderKind && indexPath.section == 0 {
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: elementKind,
                    withReuseIdentifier: RecordTitleHeader.identifier,
                    for: indexPath
                ) as? RecordTitleHeader
                
                header?.action(.updateAlbumTitleLabel(albumCache.title))
                header?.action(.updateTotalImageCountLabel(totalCount))
                
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: elementKind,
                    withReuseIdentifier: RecordDateHeader.identifier,
                    for: indexPath
                ) as? RecordDateHeader
                
                if let section = dataSource.sectionIdentifier(for: indexPath.section) {
                    switch section {
                    case let .day(order, date):
                        header?.action(.updateDayCountLabel(order))
                        header?.action(.updateDateLabel(date))
                    }
                }
                
                return header
            }
        }
    }
    
    /// Title Header를 업데이트합니다.
    private func updateTitleHeader() {
        var snapshot = dataSource.snapshot()
        if let firstSection = snapshot.sectionIdentifiers.first {
            snapshot.reloadSections([firstSection])
            dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    /// 기본 DataSource를 업데이트합니다.
    private func updateInitialDataSource(to sections: SectionMediaList) {
        var snapshot = NSDiffableDataSourceSnapshot<MediaSection, Media>()
        
        for (section, medias) in sections {
            snapshot.appendSections([section])
            snapshot.appendItems(medias, toSection: section)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    /// 페이지네이션 된 DataSource를 업데이트합니다.
    private func updatePaginationDataSource(to mediaList: [Media]) {
        guard !mediaList.isEmpty else { return }
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems(mediaList)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UICollectionViewDelegate

extension RecordViewController: UICollectionViewDelegate {
    
    /// 선택된 IndexPath의 Context Menu를 설정합니다.
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        contextMenuPresented.accept(indexPath)
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { [weak self] _ in
                self?.viewModel.contextMenu(from: indexPath).toUIMenu
            }
        )
    }
}

// MARK: - Binding

extension RecordViewController {
    
    func bind() {
        let input = RecordViewModel.Input(
            viewDidLoad: .just(()),
            willDisplayIndexPath: event.willDisplayIndexPath.asSignal(),
            cellSelected: scene.recordCollectionView.rx.itemSelected.asSignal(),
            cellDeselected: scene.recordCollectionView.rx.itemDeselected.asSignal(),
            selectButtonTapped: scene.selectButton.button.rx.tap.asSignal(),
            selectCancelButtonTapped: scene.selectCancelButton.button.rx.tap.asSignal(),
            finishButtonTapped: scene.finishRecordButton.button.rx.tap.asSignal(),
            favoriteToolbarButtonTapped: scene.favoriteToolBarButton.button.rx.tap.asSignal(),
            excludeToolbarButtonTapped: scene.excludeToolBarButton.button.rx.tap.asSignal(),
            removeToolbarButtonTapped: scene.removeToolBarButton.button.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.record
            .bind(with: self) { owner, album in
                owner.albumCache = album
                owner.scene.action(.updateTitleLabel(album.title))
                owner.scene.action(.updateInfoLabel(album))
            }
            .disposed(by: disposeBag)
        
        output.mediaList
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, medias in
                owner.totalCount = medias.count
                owner.updateTitleHeader()
                owner.scene.action(.toggleEmptyLabel(medias.isEmpty))
            }
            .disposed(by: disposeBag)
        
        output.sectionMediaList
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, sections in
                owner.updateInitialDataSource(to: sections)
            }
            .disposed(by: disposeBag)
        
        output.thumbnailList
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, thumbnailList in
                let mediaList = thumbnailList.map(\.key)
                owner.updatePaginationDataSource(to: mediaList)
            }
            .disposed(by: disposeBag)
        
        scene.recordCollectionView.rx.willDisplayCell
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, cell in
                let indexPath = IndexPath(row: cell.at.row, section: cell.at.section)
                owner.event.willDisplayIndexPath.accept(indexPath)
            }
            .disposed(by: disposeBag)
        
        output.selectedIndexPathList
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, indexPathList in
                owner.scene.action(.updateSelectedCountLabel(indexPathList.count))
            }
            .disposed(by: disposeBag)
        
        output.shouldBeFavorite
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, isFavorite in
                owner.scene.action(.toggleFavoriteMode(isFavorite))
            }
            .disposed(by: disposeBag)
        
        output.isSelectMode
            .observe(on: MainScheduler.instance)
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
    
    func setupMenu() {
        scene.seemoreButton.button.showsMenuAsPrimaryAction = true
        scene.seemoreButton.button.menu = viewModel.seemoreMenu.toUIMenu

        scene.seemoreToolBarButton.button.showsMenuAsPrimaryAction = true
        scene.seemoreToolBarButton.button.menu = viewModel.seemoreToolbarMenu.toUIMenu
    }
}
