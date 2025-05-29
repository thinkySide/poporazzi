//
//  AlbumListViewController.swift
//  poporazzi
//
//  Created by 김민준 on 5/23/25.
//

import UIKit
import RxSwift
import RxCocoa

final class AlbumListViewController: ViewController {
    
    private let scene = AlbumListView()
    private let viewModel: AlbumListViewModel
    
    private var dataSource: UICollectionViewDiffableDataSource<AlbumSection, Album>!
    
    private var imageCache = [String: UIImage?]()
    
    let disposeBag = DisposeBag()
    
    init(viewModel: AlbumListViewModel) {
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
        setupDataSource()
        bind()
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - AlbumSection

enum AlbumSection: Hashable, Comparable {
    case main
}

// MARK: - UICollectionViewDiffableDataSource

extension AlbumListViewController {
    
    /// DataSource를 설정합니다.
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<AlbumSection, Album>(collectionView: scene.albumCollectionView) {
            [weak self] (collectionView, indexPath, album) -> UICollectionViewCell? in
            guard let self, let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AlbumCell.identifier,
                for: indexPath
            ) as? AlbumCell else { return nil }
            
            if let cacheThumbnail = self.imageCache[album.id] {
                cell.action(.setThumbnail(cacheThumbnail))
            }
            
            cell.action(.setAlbumInfo(album))
            
            return cell
        }
    }
    
    /// 기본 DataSource를 업데이트합니다.
    private func updateInitialDataSource(to albumList: [Album]) {
        var snapshot = NSDiffableDataSourceSnapshot<AlbumSection, Album>()
        snapshot.appendSections([.main])
        snapshot.appendItems(albumList, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func updatePaginationDataSource(to albumList: [Album]) {
        guard !albumList.isEmpty else { return }
        
        for album in albumList {
            imageCache.updateValue(album.thumbnail, forKey: album.id)
        }
        
        var snapshot = dataSource.snapshot()
        let validList = albumList.filter { snapshot.itemIdentifiers.contains($0) }
        snapshot.reloadItems(validList)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - Binding

extension AlbumListViewController {
    
    func bind() {
        let input = AlbumListViewModel.Input(
            viewDidLoad: .just(()),
            albumCellSelected: scene.albumCollectionView.rx.itemSelected.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.albumList
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, albumList in
                owner.updateInitialDataSource(to: albumList)
            }
            .disposed(by: disposeBag)
        
        output.updateThumbnail
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, albumList in
                owner.updatePaginationDataSource(to: albumList)
            }
            .disposed(by: disposeBag)
    }
}
