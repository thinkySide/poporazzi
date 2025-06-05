//
//  OnboardingViewController.swift
//  poporazzi
//
//  Created by 김민준 on 6/4/25.
//

import UIKit
import RxSwift
import RxCocoa

final class OnboardingViewController: ViewController {
    
    enum Section {
        case main
    }
    
    private let scene = OnboardingView()
    private let viewModel: OnboardingViewModel
    private let disposeBag = DisposeBag()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, OnboardingItem>!
    
    private let event = Event()
    
    init(viewModel: OnboardingViewModel) {
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

// MARK: - Event

extension OnboardingViewController {
    
    struct Event {
        let currentIndex = PublishRelay<Int>()
    }
}

// MARK: - UICollectionViewDiffableDataSource

extension OnboardingViewController {
    
    /// CollectionView를 세팅합니다.
    private func setupCollectionView() {
        scene.screenshotCollectionView.delegate = self
        scene.screenshotCollectionView.collectionViewLayout = screenshotCollectionViewLayout
        scene.screenshotCollectionView.isPagingEnabled = true
        scene.screenshotCollectionView.register(
            OnboardingCell.self,
            forCellWithReuseIdentifier: OnboardingCell.identifier
        )
    }
    
    /// 레이아웃을 반환합니다.
    private var screenshotCollectionViewLayout: UICollectionViewCompositionalLayout {
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
        }
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    /// DataSource를 설정합니다.
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, OnboardingItem>(collectionView: scene.screenshotCollectionView) {
            [weak self] (collectionView, indexPath, media) -> UICollectionViewCell? in
            guard let self, let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: OnboardingCell.identifier,
                for: indexPath
            ) as? OnboardingCell else { return nil }
            
            let image = self.viewModel.onboardingItems[indexPath.item].image
            cell.action(.setImage(image))
            
            return cell
        }
    }
    
    /// 기본 DataSource를 업데이트합니다.
    private func updateDataSource(_ onboardingItemList: [OnboardingItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, OnboardingItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(onboardingItemList, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - UICollectionViewDelegate

extension OnboardingViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0
    }
}

// MARK: - Binding

extension OnboardingViewController {
    
    func bind() {
        let input = OnboardingViewModel.Input(
            actionButtonTapped: scene.actionButton.button.rx.tap.asSignal(),
            currentIndex: event.currentIndex.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.onboardingItems
            .bind(with: self) { owner, items in
                owner.updateDataSource(items)
            }
            .disposed(by: disposeBag)
        
        output.currentIndex
            .bind(with: self) { owner, index in
                owner.scene.paginationIndicator.action(.updateCurrentIndex(index))
                if index >= owner.viewModel.onboardingItems.count - 1 {
                    owner.scene.action(.updateActionButton("시작하기", .primary))
                } else {
                    owner.scene.action(.updateActionButton("다음으로", .secondary))
                }
            }
            .disposed(by: disposeBag)
        
        output.currentItem
            .bind(with: self) { owner, item in
                owner.scene.action(.updateTitleLabel(item.title))
            }
            .disposed(by: disposeBag)
        
        output.nextButtonTapped
            .bind(with: self) { owner, index in
                let indexPath = IndexPath(item: index, section: 0)
                owner.scene.screenshotCollectionView.isPagingEnabled = false
                owner.scene.screenshotCollectionView.scrollToItem(
                    at: indexPath,
                    at: .centeredHorizontally,
                    animated: true
                )
                owner.scene.screenshotCollectionView.isPagingEnabled = true
            }
            .disposed(by: disposeBag)
    }
}
