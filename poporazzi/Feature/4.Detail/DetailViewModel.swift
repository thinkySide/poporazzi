//
//  DetailViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 5/26/25.
//

import Foundation
import RxSwift
import RxCocoa

final class DetailViewModel: ViewModel {
    
    @Dependency(\.photoKitService) private var photoKitService
    
    private let disposeBag = DisposeBag()
    private let output: Output
    
    let navigation = PublishRelay<Navigation>()
    
    /// 이미지 업데이트를 받았는지 확인하는 마킹 배열
    private var updateMarkingList = [Bool]()
    
    init(output: Output) {
        self.output = output
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Input & Output

extension DetailViewModel {
    
    struct Input {
        let viewDidLoad: Signal<Void>
        let willDisplayCell: Signal<IndexPath>
        let backButtonTapped: Signal<Void>
    }
    
    struct Output {
        let album: BehaviorRelay<Album>
        let mediaList: BehaviorRelay<[Media]>
        let selectedRow: BehaviorRelay<Int>
        let updateMediaList = BehaviorRelay<[Media]>(value: [])
    }
    
    enum Navigation {
        case pop
    }
}

// MARK: - Transform

extension DetailViewModel {
    
    func transform(_ input: Input) -> Output {
        input.viewDidLoad
            .asObservable()
            .bind(with: self) { owner, _ in
                owner.updateMarkingList = Array(repeating: false, count: owner.output.mediaList.value.count)
            }
            .disposed(by: disposeBag)
        
        input.willDisplayCell
            .asObservable()
            .distinctUntilChanged()
            .bind(with: self) { owner, indexPath in
                let fetchMediaList = owner.calcForFetchMediaList(displayRow: indexPath.row)
                owner.mediaListWithImage(from: fetchMediaList)
                    .observe(on: MainScheduler.asyncInstance)
                    .bind(to: owner.output.updateMediaList)
                    .disposed(by: owner.disposeBag)
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

// MARK: - Helper

extension DetailViewModel {
    
    /// 페이지네이션에 필요한 MediaList를 계산합니다.
    private func calcForFetchMediaList(displayRow: Int) -> [Media] {
        let mediaList = output.mediaList.value
        var fetchMediaList: [Media] = []
        
        if let currentMedia = mediaList[safe: displayRow],
           !updateMarkingList[displayRow] {
            print("현재: \(displayRow)")
            fetchMediaList.append(currentMedia)
            updateMarkingList[displayRow] = true
        }
        
        for i in 1...3 {
            let previousIndex = displayRow - i
            let nextIndex = displayRow + i
            
            if let previousMedia = mediaList[safe: previousIndex],
               !updateMarkingList[previousIndex] {
                print("이전: \(previousIndex)")
                fetchMediaList.append(previousMedia)
                updateMarkingList[previousIndex] = true
            }
            
            if let nextMedia = mediaList[safe: nextIndex],
               !updateMarkingList[nextIndex] {
                print("다음: \(nextIndex)")
                fetchMediaList.append(nextMedia)
                updateMarkingList[nextIndex] = true
            }
        }
        
        return fetchMediaList
    }
    
    /// 선택한 미디어를 고화질 이미지와 함께 반환합니다.
    private func mediaListWithImage(
        from mediaList: [Media]
    ) -> Observable<[Media]> {
        photoKitService.fetchMedias(from: mediaList.map(\.id), option: .high)
    }
}
