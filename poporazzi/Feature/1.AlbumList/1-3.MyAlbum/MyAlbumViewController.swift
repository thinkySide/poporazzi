//
//  MyAlbumViewController.swift
//  poporazzi
//
//  Created by 김민준 on 5/27/25.
//

import UIKit
import RxSwift
import RxCocoa

final class MyAlbumViewController: ViewController {
    
    private let scene = MyAlbumView()
    private let viewModel: MyAlbumViewModel
    
    private var dataSource: UICollectionViewDiffableDataSource<MediaSection, Media>!
    
    private let contextMenuPresented = PublishRelay<IndexPath>()
    private let selectedContextMenu = BehaviorRelay<[MenuModel]>(value: [])
    
    let disposeBag = DisposeBag()
    
    init(viewModel: MyAlbumViewModel) {
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

// MARK: - UICollectionView

extension MyAlbumViewController {
    
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
        collectionView.register(
            RecordDateHeader.self,
            forSupplementaryViewOfKind: CollectionViewLayout.subHeaderKind,
            withReuseIdentifier: RecordDateHeader.identifier
        )
    }
    
    /// CollectionViewLayout을 반환합니다.
    private var collectionViewLayout: UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, environment in
            let section = CollectionViewLayout.threeStageSection
            if sectionIndex == 0 {
                section.boundarySupplementaryItems = [
                    CollectionViewLayout.titleHeader,
                    CollectionViewLayout.dateHeader
                ]
            } else {
                section.boundarySupplementaryItems = [CollectionViewLayout.dateHeader]
            }
            return section
        }
    }
}

// MARK: - UICollectionViewDiffableDataSource

extension MyAlbumViewController {
    
    /// DataSource를 설정합니다.
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<MediaSection, Media>(collectionView: scene.mediaCollectionView) {
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
                
                header?.action(.updateAlbumTitleLabel(viewModel.album.title))
                header?.action(.updateTotalImageCountLabel(viewModel.mediaList.count))
                
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
        snapshot.reloadItems(mediaList)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UICollectionViewDelegate

extension MyAlbumViewController: UICollectionViewDelegate {
    
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
                self?.selectedContextMenu.value.toUIMenu
            }
        )
    }
}

// MARK: - Binding

extension MyAlbumViewController {
    
    func bind() {
        let input = MyAlbumViewModel.Input(
            viewDidLoad: .just(()),
            backButtonTapped: scene.backButton.button.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.mediaList
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, mediaList in
                let creationDate = owner.viewModel.album.creationDate
                let sectionMediaList = mediaList.toSectionMediaList(startDate: creationDate)
                owner.updateInitialDataSource(to: sectionMediaList)
                owner.updateTitleHeader()
            }
            .disposed(by: disposeBag)
        
        output.thumbnailList
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, thumbnailList in
                let mediaList = thumbnailList.map(\.key)
                owner.updatePaginationDataSource(to: mediaList)
            }
            .disposed(by: disposeBag)
    }
}
