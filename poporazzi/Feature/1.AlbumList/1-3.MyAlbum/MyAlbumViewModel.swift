//
//  MyAlbumViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 5/27/25.
//

import UIKit
import RxSwift
import RxCocoa

final class MyAlbumViewModel: ViewModel {
    
    @Dependency(\.photoKitService) private var photoKitService
    
    private let paginationManager = PaginationManager(pageSize: 100, threshold: 10)
    
    private let disposeBag = DisposeBag()
    private let output: Output
    
    
    let navigation = PublishRelay<Navigation>()
    
    init(output: Output) {
        self.output = output
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Input & Output

extension MyAlbumViewModel {
    
    struct Input {
        let viewDidLoad: Signal<Void>
        let willDisplayIndexPath: Signal<IndexPath>
        let backButtonTapped: Signal<Void>
    }
    
    struct Output {
        let album: BehaviorRelay<Album>
        
        let mediaList = BehaviorRelay<[Media]>(value: [])
        let sectionMediaList = BehaviorRelay<SectionMediaList>(value: [])
        let thumbnailList = BehaviorRelay<[Media: UIImage?]>(value: [:])
        
        let viewDidRefresh = PublishRelay<Void>()
        let pagination = PublishRelay<Void>()
    }
    
    enum Navigation {
        case pop
    }
}

// MARK: - Transform

extension MyAlbumViewModel {
    
    func transform(_ input: Input) -> Output {
        
        // 이미지 불러오기(페이지네이션)
        output.pagination
            .withUnretained(self)
            .map { owner, _ in
                (owner, owner.paginationManager.paginationList(from: owner.mediaList))
            }
            .flatMap { owner, paginationList in
                owner.photoKitService.fetchMediaListWithThumbnail(
                    from: paginationList.map(\.id),
                    option: .normal
                )
            }
            .bind(with: self) { owner, mediaList in
                let thumbnailList = Dictionary(uniqueKeysWithValues: mediaList.map {
                    ($0, $0.thumbnail)
                })
                var lastThumnailList = owner.thumbnailList
                lastThumnailList.merge(thumbnailList) { $1 }
                owner.output.thumbnailList.accept(lastThumnailList)
            }
            .disposed(by: disposeBag)
        
        // 미디어 리스트 정보만 불러오기
        Signal.merge(
            input.viewDidLoad,
            output.viewDidRefresh.asSignal()
        )
        .emit(with: self) { owner, _ in
            let mediaList = owner.photoKitService.fetchMediaList(from: owner.album)
            owner.output.mediaList.accept(mediaList)
            
            let startDate = owner.album.creationDate
            let sectionMediaList = mediaList.toSectionMediaList(startDate: startDate)
            owner.output.sectionMediaList.accept(sectionMediaList)
            
            owner.paginationManager.reset()
            owner.output.pagination.accept(())
        }
        .disposed(by: disposeBag)
        
        // 현재 보이는 IndexPath를 기준으로 페이지네이션 여부 결정
        input.willDisplayIndexPath
            .emit(with: self) { owner, indexPath in
                let index = owner.index(
                    from: owner.sectionMediaList,
                    indexPath: indexPath
                )
                
                guard index <= owner.mediaList.count else { return }
                
                if owner.paginationManager.isPagination(to: index) {
                    owner.paginationManager.updateForNextPagination()
                    owner.output.pagination.accept(())
                }
            }
            .disposed(by: disposeBag)
        
        input.backButtonTapped
            .emit(with: self) { owner, _ in
                owner.navigation.accept(.pop)
            }
            .disposed(by: disposeBag)
        
        return output
    }
}

// MARK: - Syntax Sugar

extension MyAlbumViewModel {
    
    var album: Album {
        output.album.value
    }
    
    var mediaList: [Media] {
        output.mediaList.value
    }
    
    var sectionMediaList: SectionMediaList {
        output.sectionMediaList.value
    }
    
    var thumbnailList: [Media: UIImage?] {
        output.thumbnailList.value
    }
}

// MARK: - Helper

extension MyAlbumViewModel {
    
    /// Section MediaList에서 해당 IndexPath가 몇번째 인덱스인지 반환합니다.
    private func index(
        from sectionMediaList: SectionMediaList,
        indexPath: IndexPath
    ) -> Int {
        var currentIndex = 0
        for (index, mediaList) in sectionMediaList.enumerated() {
            if index == indexPath.section {
                currentIndex += indexPath.row
                break
            }
            currentIndex += mediaList.1.count
        }
        return currentIndex
    }
}
