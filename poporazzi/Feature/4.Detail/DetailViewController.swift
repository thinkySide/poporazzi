//
//  DetailViewController.swift
//  poporazzi
//
//  Created by 김민준 on 5/26/25.
//

import UIKit
import RxSwift
import RxCocoa

final class DetailViewController: ViewController {
    
    enum Section {
        case main
    }
    
    private let scene = DetailView()
    private let viewModel: DetailViewModel
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Media>!
    private var selectedRow = 0
    private var imageCache = [String: UIImage?]()
    
    /// 현재 바라보고 있는 CollectionView Index
    private let currentIndexRelay = PublishRelay<Int>()
    
    let disposeBag = DisposeBag()
    
    init(viewModel: DetailViewModel) {
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
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - UICollectionViewDiffableDataSource

extension DetailViewController {
    
    /// CollectionView를 세팅합니다.
    private func setupCollectionView() {
        scene.mediaCollectionView.collectionViewLayout = mediaCollectionViewLayout
        scene.mediaCollectionView.isPagingEnabled = true
        scene.mediaCollectionView.register(
            DetailCell.self,
            forCellWithReuseIdentifier: DetailCell.identifier
        )
    }
    
    /// DataSource를 설정합니다.
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Media>(collectionView: scene.mediaCollectionView) {
            [weak self] (collectionView, indexPath, media) -> UICollectionViewCell? in
            guard let self, let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: DetailCell.identifier,
                for: indexPath
            ) as? DetailCell else { return nil }
            
            if let cacheImgae = self.imageCache[media.id] {
                cell.action(.setImage(cacheImgae))
            }
            
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
        
        for media in mediaList {
            imageCache.updateValue(media.thumbnail, forKey: media.id)
        }
        
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems(mediaList)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - CollectionView Layout

extension DetailViewController {
    
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
                self?.currentIndexRelay.accept(closestItem.indexPath.item)
            }
        }
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - Binding

extension DetailViewController {
    
    func bind() {
        let input = DetailViewModel.Input(
            viewDidLoad: .just(()),
            currentIndex: currentIndexRelay.asSignal(),
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
        
        output.updateMediaList
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, mediaList in
                owner.updatePaginationDataSource(to: mediaList)
            }
            .disposed(by: disposeBag)
        
        output.initialRow
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
    }
}
