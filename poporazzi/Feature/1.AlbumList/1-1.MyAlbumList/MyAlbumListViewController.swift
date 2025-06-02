//
//  MyAlbumListViewController.swift
//  poporazzi
//
//  Created by 김민준 on 5/23/25.
//

import UIKit
import RxSwift
import RxCocoa

final class MyAlbumListViewController: ViewController {
    
    private let scene = MyAlbumListView()
    private let viewModel: MyAlbumListViewModel
    let disposeBag = DisposeBag()
    
    private var dataSource: UICollectionViewDiffableDataSource<AlbumSection, Album>!
    
    init(viewModel: MyAlbumListViewModel) {
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

extension MyAlbumListViewController {
    
    /// DataSource를 설정합니다.
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<AlbumSection, Album>(collectionView: scene.albumCollectionView) {
            [weak self] (collectionView, indexPath, album) -> UICollectionViewCell? in
            guard let self, let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MyAlbumListCell.identifier,
                for: indexPath
            ) as? MyAlbumListCell else { return nil }
            
            if let thumbnailList = self.viewModel.thumbnailList[album] {
                cell.action(.setAlbum(album, thumbnailList))
            } else {
                cell.action(.setAlbum(album, []))
            }
            
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
        var snapshot = dataSource.snapshot()
        let valideList = snapshot.itemIdentifiers.filter { albumList.contains($0) }
        snapshot.reconfigureItems(valideList)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - Binding

extension MyAlbumListViewController {
    
    func bind() {
        let input = MyAlbumListViewModel.Input(
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
        
        output.thumbnailList
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, thumbnailList in
                owner.updatePaginationDataSource(to: thumbnailList.map(\.key))
            }
            .disposed(by: disposeBag)
    }
}
