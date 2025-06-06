//
//  FolderListViewController.swift
//  poporazzi
//
//  Created by 김민준 on 5/30/25.
//

import UIKit
import RxSwift
import RxCocoa

final class FolderListViewController: ViewController {
    
    private let scene = FolderListView()
    private let viewModel: FolderListViewModel
    private let disposeBag = DisposeBag()
    private let event = Event()
    
    private var dataSource: UICollectionViewDiffableDataSource<AlbumSection, Album>!
    
    init(viewModel: FolderListViewModel) {
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
        setupMenu()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        event.viewWillDisappear.accept(())
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Event

extension FolderListViewController {
    
    struct Event {
        let viewWillDisappear = PublishRelay<Void>()
    }
}

// MARK: - UICollectionViewDiffableDataSource

extension FolderListViewController {
    
    /// DataSource를 설정합니다.
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<AlbumSection, Album>(collectionView: scene.albumCollectionView) {
            [weak self] (collectionView, indexPath, album) -> UICollectionViewCell? in
            guard let self, let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FolderListCell.identifier,
                for: indexPath
            ) as? FolderListCell else { return nil }
            
            if let thumbnailList = self.viewModel.thumbnailList[album.id] {
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
    
    private func updatePaginationDataSource(to updateList: [String]) {
        guard !updateList.isEmpty else { return }
        var snapshot = dataSource.snapshot()
        let validList = snapshot.itemIdentifiers.filter { updateList.contains($0.id) }
        snapshot.reloadItems(validList)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - Binding

extension FolderListViewController {
    
    func bind() {
        let input = FolderListViewModel.Input(
            viewDidLoad: .just(()),
            viewWillDisappear: event.viewWillDisappear.asSignal(),
            folderCellSelected: scene.albumCollectionView.rx.itemSelected.asSignal(),
            backButtonTapped: scene.backButton.button.rx.tap.asSignal(),
            seemoreButtonTapped: scene.seemoreButton.button.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.folder
            .bind(with: self) { owner, album in
                owner.scene.action(.setTitle(album.title))
            }
            .disposed(by: disposeBag)
        
        output.albumList
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, albumList in
                owner.updateInitialDataSource(to: albumList)
            }
            .disposed(by: disposeBag)
        
        output.updateThumbnail
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, updateList in
                owner.updatePaginationDataSource(to: updateList)
            }
            .disposed(by: disposeBag)
    }
    
    func setupMenu() {
        scene.seemoreButton.button.showsMenuAsPrimaryAction = true
        scene.seemoreButton.button.menu = viewModel.seemoreMenu.toUIMenu
    }
}
