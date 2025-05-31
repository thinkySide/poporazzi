//
//  AlbumDetailViewController.swift
//  poporazzi
//
//  Created by 김민준 on 5/27/25.
//

import UIKit
import RxSwift
import RxCocoa

final class AlbumDetailViewController: ViewController {
    
    private let scene = AlbumDetailView()
    private let viewModel: AlbumDetailViewModel
    
    private var dataSource: UICollectionViewDiffableDataSource<AlbumDetailSection, Media>!
    
    let event = Event()
    let disposeBag = DisposeBag()
    
    init(viewModel: AlbumDetailViewModel) {
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
        setupLoadingIndicator()
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

extension AlbumDetailViewController {
    
    struct Event {
        let willDisplayIndexPath = PublishRelay<IndexPath>()
        let contextMenuPresented = PublishRelay<IndexPath>()
        let currentScrollOffset = PublishRelay<CGPoint>()
    }
}

enum AlbumDetailSection: Hashable, Comparable {
    case main
}

// MARK: - UICollectionView

extension AlbumDetailViewController {
    
    /// CollectionView를 세팅합니다.
    private func setupCollectionView() {
        let collectionView = scene.mediaCollectionView
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
    }
    
    /// CollectionViewLayout을 반환합니다.
    private var collectionViewLayout: UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            let section = CollectionViewLayout.threeStageSection
            section.boundarySupplementaryItems = [CollectionViewLayout.titleHeader]
            
            section.visibleItemsInvalidationHandler = { visibleItems, point, _ in
                guard let self else { return }
                self.event.currentScrollOffset.accept(point)
            }
            
            return section
        }
    }
}

// MARK: - UICollectionViewDiffableDataSource

extension AlbumDetailViewController {
    
    /// DataSource를 설정합니다.
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<AlbumDetailSection, Media>(collectionView: scene.mediaCollectionView) {
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
            
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: elementKind,
                withReuseIdentifier: RecordTitleHeader.identifier,
                for: indexPath
            ) as? RecordTitleHeader
            
            header?.action(.updateAlbumTitleLabel(viewModel.album.title))
            header?.action(.updateTotalImageCountLabel(viewModel.mediaList.count))
            
            return header
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
    private func updateInitialDataSource(to mediaList: [Media]) {
        var snapshot = NSDiffableDataSourceSnapshot<AlbumDetailSection, Media>()
        snapshot.appendSections([.main])
        snapshot.appendItems(mediaList, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    /// 페이지네이션 된 DataSource를 업데이트합니다.
    private func updatePaginationDataSource(to mediaList: [Media]) {
        guard !mediaList.isEmpty else { return }
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems(mediaList)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - UICollectionViewDelegate

extension AlbumDetailViewController: UICollectionViewDelegate {
    
    /// 선택된 IndexPath의 Context Menu를 설정합니다.
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        event.contextMenuPresented.accept(indexPath)
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

extension AlbumDetailViewController {
    
    func bind() {
        let input = AlbumDetailViewModel.Input(
            viewDidLoad: .just(()),
            willDisplayIndexPath: event.willDisplayIndexPath.asSignal(),
            cellSelected: scene.mediaCollectionView.rx.itemSelected.asSignal(),
            cellDeselected: scene.mediaCollectionView.rx.itemDeselected.asSignal(),
            backButtonTapped: scene.backButton.button.rx.tap.asSignal(),
            selectButtonTapped: scene.selectButton.button.rx.tap
                .asSignal(),
            selectCancelButtonTapped: scene.selectCancelButton.button.rx.tap
                .asSignal(),
            contextMenuPresented: event.contextMenuPresented.asSignal(),
            currentScrollOffset: event.currentScrollOffset.asSignal(),
            favoriteToolbarButtonTapped: scene.favoriteToolBarButton.button.rx.tap.asSignal(),
            excludeToolbarButtonTapped: scene.excludeToolBarButton.button.rx.tap.asSignal(),
            removeToolbarButtonTapped: scene.removeToolBarButton.button.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.mediaList
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, mediaList in
                owner.updateTitleHeader()
                owner.updateInitialDataSource(to: mediaList)
            }
            .disposed(by: disposeBag)
        
        output.thumbnailList
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, thumbnailList in
                let mediaList = thumbnailList.map(\.key)
                owner.updatePaginationDataSource(to: mediaList)
            }
            .disposed(by: disposeBag)
        
        scene.mediaCollectionView.rx.willDisplayCell
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, cell in
                let indexPath = IndexPath(row: cell.at.row, section: cell.at.section)
                owner.event.willDisplayIndexPath.accept(indexPath)
            }
            .disposed(by: disposeBag)
        
        output.isNavigationTitleShown
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, isShown in
                owner.scene.action(.updateTitle(
                    isShown: isShown,
                    owner.viewModel.album.title)
                )
            }
            .disposed(by: disposeBag)
        
        output.isSelectMode
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, isSelect in
                owner.scene.action(.toggleSelectMode(isSelect))
            }
            .disposed(by: disposeBag)
        
        output.selectedIndexPathList
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, indexPathList in
                owner.scene.action(.updateSelectedCount(indexPathList.count))
            }
            .disposed(by: disposeBag)
        
        output.shouldBeFavorite
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, isFavorite in
                owner.scene.action(.updateShouldFavorite(isFavorite))
            }
            .disposed(by: disposeBag)
        
        output.toggleLoading
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, isLoading in
                owner.toggleLoadingIndicator(isLoading)
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
    }
    
    func setupMenu() {
        scene.seemoreButton.button.showsMenuAsPrimaryAction = true
        scene.seemoreButton.button.menu = viewModel.seemoreMenu.toUIMenu
        
        scene.seemoreToolBarButton.button.showsMenuAsPrimaryAction = true
        scene.seemoreToolBarButton.button.menu = viewModel.seemoreToolbarMenu.toUIMenu
    }
}
