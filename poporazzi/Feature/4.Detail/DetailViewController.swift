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
    private var imageCache = [String: UIImage?]()
    
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
        setupDataSource()
        bind()
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - UICollectionViewDiffableDataSource

extension DetailViewController {
    
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
    private func updateInitialDataSource(to sections: SectionMediaList) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Media>()
        
        snapshot.appendSections([.main])
        
        for (_, medias) in sections {
            snapshot.appendItems(medias, toSection: .main)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - Binding

extension DetailViewController {
    
    func bind() {
        let input = DetailViewModel.Input(
            viewDidLoad: .just(()),
            backButtonTapped: scene.backButton.button.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.sectionMediaList
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, sections in
                owner.updateInitialDataSource(to: sections)
            }
            .disposed(by: disposeBag)
        
        
    }
}
