//
//  ExcludeRecordViewController.swift
//  poporazzi
//
//  Created by 김민준 on 5/5/25.
//

import UIKit
import RxSwift
import RxCocoa

final class ExcludeRecordViewController: ViewController {
    
    private let scene = ExcludeRecordView()
    private let viewModel: ExcludeRecordViewModel
    
    enum Section {
        case main
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Media>!
    
    private let contextMenuPresented = PublishRelay<IndexPath>()
    private let selectedContextMenu = BehaviorRelay<[MenuModel]>(value: [])
    
    let disposeBag = DisposeBag()
    
    init(viewModel: ExcludeRecordViewModel) {
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

// MARK: - UICollectionViewDiffableDataSource

extension ExcludeRecordViewController {
    
    /// DataSource를 설정합니다.
    private func setupDataSource() {
        scene.recordCollectionView.delegate = self
        
        dataSource = UICollectionViewDiffableDataSource<Section, Media>(collectionView: scene.recordCollectionView) {
            (collectionView, indexPath, media) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RecordCell.identifier,
                for: indexPath
            ) as? RecordCell else { return nil }
            
            cell.action(.setImage(media.thumbnail))
            cell.action(.setMediaInfo(media))
            
            return cell
        }
    }
    
    /// 기본 DataSource를 업데이트합니다.
    private func updateInitialDataSource(to medias: [Media]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Media>()
        snapshot.appendSections([.main])
        snapshot.appendItems(medias, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UICollectionViewDelegate

extension ExcludeRecordViewController: UICollectionViewDelegate {
    
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

extension ExcludeRecordViewController {
    
    func bind() {
        let input = ExcludeRecordViewModel.Input(
            viewDidLoad: .just(()),
            backButtonTapped: scene.backButton.button.rx.tap.asSignal(),
            selectButtonTapped: scene.selectButton.button.rx.tap.asSignal(),
            selectCancelButtonTapped: scene.selectCancelButton.button.rx.tap.asSignal(),
            recordCellSelected: scene.recordCollectionView.rx.itemSelected.asSignal(),
            recordCellDeselected: scene.recordCollectionView.rx.itemDeselected.asSignal(),
            contextMenuPresented: contextMenuPresented.asSignal(),
            favoriteToolbarButtonTapped: scene.favoriteToolBarButton.button.rx.tap.asSignal(),
            recoverButtonTapped: scene.recoverToolBarButton.button.rx.tap.asSignal(),
            removeButtonTapped: scene.removeToolBarButton.button.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.mediaList
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, medias in
                owner.scene.action(.setTotalImageCountLabel(medias.count))
                owner.updateInitialDataSource(to: medias)
            }
            .disposed(by: disposeBag)
        
        output.selectedRecordCells
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, selectedMedias in
                owner.scene.action(.updateSelectedCountLabel(selectedMedias.count))
            }
            .disposed(by: disposeBag)
        
        output.shoudBeFavorite
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, bool in
                owner.scene.action(.toggleFavoriteMode(bool))
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
        
        output.setupSeeMoreToolbarMenu
            .bind(with: self) { owner, menu in
                owner.scene.seemoreToolBarButton.button.showsMenuAsPrimaryAction = true
                owner.scene.seemoreToolBarButton.button.menu = menu.toUIMenu
            }
            .disposed(by: disposeBag)
        
        output.selectedContextMenu
            .bind(with: self) { owner, menus in
                owner.selectedContextMenu.accept(menus)
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
