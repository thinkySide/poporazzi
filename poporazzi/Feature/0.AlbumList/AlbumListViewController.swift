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
            [weak self] (collectionView, indexPath, media) -> UICollectionViewCell? in
            guard let self, let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AlbumCell.identifier,
                for: indexPath
            ) as? AlbumCell else { return nil }
            
            cell.action(.setAlbumInfo(.init(title: "콜트플레이 내한 콘서트 🪐 ", mediaFetchOption: .all, mediaFilterOption: .init())))
            cell.action(.setThumbnail(nil))
            
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
}

// MARK: - Binding

extension AlbumListViewController {
    
    func bind() {
        updateInitialDataSource(to: [.initialValue, .initialValue, .initialValue, .initialValue, .initialValue])
        
        let input = AlbumListViewModel.Input(
            
        )
        let output = viewModel.transform(input)
        
    }
}
