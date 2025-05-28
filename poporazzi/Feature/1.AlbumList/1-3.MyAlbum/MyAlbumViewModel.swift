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
    }
    
    enum Navigation {
        case pop
    }
}

// MARK: - Transform

extension MyAlbumViewModel {
    
    func transform(_ input: Input) -> Output {
        
        // 1. 미디어 리스트 정보만 불러오기
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
        }
        .disposed(by: disposeBag)
        
        // 2. 썸네일 불러오기
        output.mediaList
            .withUnretained(self)
            .flatMap {
                $0.photoKitService.fetchMediaListWithThumbnail(
                    from: $1.map(\.id),
                    option: .normal
                )
            }
            .bind(with: self) { owner, mediaList in
                let thumbnailList = Dictionary(uniqueKeysWithValues: mediaList.map {
                    ($0, $0.thumbnail)
                })
                owner.output.thumbnailList.accept(thumbnailList)
            }
            .disposed(by: disposeBag)
        
        input.willDisplayIndexPath
            .emit(with: self) { owner, indexPath in
                
                // 인덱스 계산
                let index = owner.index(
                    from: owner.sectionMediaList,
                    indexPath: indexPath
                )
                
                // 인덱스 오버플로우 방지
                guard index <= owner.mediaList.count else { return }
                
                
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
