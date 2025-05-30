//
//  MediaDetailViewController.swift
//  poporazzi
//
//  Created by 김민준 on 5/26/25.
//

import UIKit
import RxSwift
import RxCocoa

final class MediaDetailViewController: ViewController {
    
    enum Section {
        case main
    }
    
    private let scene = MediaDetailView()
    private let viewModel: MediaDetailViewModel
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Media>!
    private var selectedRow = 0
    
    private let event = Event()
    
    let disposeBag = DisposeBag()
    
    private var initialImage: UIImage?
    
    init(viewModel: MediaDetailViewModel, initialImage: UIImage?) {
        self.viewModel = viewModel
        self.initialImage = initialImage
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
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Event

extension MediaDetailViewController {
    
    struct Event {
        let currentIndex = PublishRelay<Int>()
        let currentScrollOffset = PublishRelay<CGPoint>()
    }
}

// MARK: - UICollectionViewDiffableDataSource

extension MediaDetailViewController {
    
    /// CollectionView를 세팅합니다.
    private func setupCollectionView() {
        scene.mediaCollectionView.collectionViewLayout = mediaCollectionViewLayout
        scene.mediaCollectionView.isPagingEnabled = true
        scene.mediaCollectionView.register(
            MediaDetailCell.self,
            forCellWithReuseIdentifier: MediaDetailCell.identifier
        )
    }
    
    /// DataSource를 설정합니다.
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Media>(collectionView: scene.mediaCollectionView) {
            [weak self] (collectionView, indexPath, media) -> UICollectionViewCell? in
            guard let self, let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MediaDetailCell.identifier,
                for: indexPath
            ) as? MediaDetailCell else { return nil }
            
            var thumbnail: UIImage?
            if let initialImage {
                thumbnail = initialImage
                self.initialImage = nil
            }
            
            if let loadImage = self.viewModel.thumbnailList[media] {
                thumbnail = loadImage
            }
            
            cell.action(.setImage(thumbnail))
            
            return cell
        }
    }
    
    /// 기본 DataSource를 업데이트합니다.
    private func updateInitialDataSource(to mediaList: [Media]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Media>()
        
        snapshot.appendSections([.main])
        
        for media in mediaList {
            snapshot.appendItems([media], toSection: .main)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
            guard let self else { return }
            self.scene.action(.setInitialIndex(self.selectedRow))
        }
    }
    
    /// 페이지네이션 된 DataSource를 업데이트합니다.
    private func updatePaginationDataSource(to mediaList: [Media]) {
        guard !mediaList.isEmpty else { return }
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems(mediaList)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - CollectionView Layout

extension MediaDetailViewController {
    
    /// 레이아웃을 반환합니다.
    var mediaCollectionViewLayout: UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, point, environment in
            let centerX = point.x + environment.container.contentSize.width / 2
            let sortedItems = visibleItems.sorted {
                abs($0.frame.midX - centerX) < abs($1.frame.midX - centerX)
            }
            if let closestItem = sortedItems.first {
                self?.event.currentIndex.accept(closestItem.indexPath.item)
            }
            self?.event.currentScrollOffset.accept(point)
        }
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - Binding

extension MediaDetailViewController {
    
    func bind() {
        let input = MediaDetailViewModel.Input(
            viewDidLoad: .just(()),
            currentIndex: event.currentIndex.asSignal(),
            currentScrollOffset: event.currentScrollOffset.asSignal(),
            favoriteButtonTapped: scene.favoriteButton.button.rx.tap.asSignal(),
            excludeButtonTapped: scene.excludeButton.button.rx.tap.asSignal(),
            removeButtonTapped: scene.removeButton.button.rx.tap
                .asSignal(),
            backButtonTapped: scene.backButton.button.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.mediaList
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, mediaList in
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
        
        output.currentIndex
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, selectedRow in
                owner.selectedRow = selectedRow
            }
            .disposed(by: disposeBag)
        
        output.updateMediaInfo
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, info in
                let (media, dayCount, date) = info
                owner.scene.action(.updateDateLabel(dayCount: dayCount, date))
                owner.scene.action(.updateMediaInfo(media))
            }
            .disposed(by: disposeBag)
        
        output.updateCountInfo
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, countInfo in
                let (currentIndex, totalCount) = countInfo
                owner.scene.action(.updateCountInfo(currentIndex: currentIndex, totalCount: totalCount))
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
        
        output.setupSeeMoreMenu
            .bind(with: self) { owner, menu in
                owner.scene.seemoreButton.button.showsMenuAsPrimaryAction = true
                owner.scene.seemoreButton.button.menu = menu.toUIMenu
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
