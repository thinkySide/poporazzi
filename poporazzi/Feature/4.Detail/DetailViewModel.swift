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
        let backButtonTapped: Signal<Void>
    }
    
    struct Output {
        let album: BehaviorRelay<Album>
        let sectionMediaList: BehaviorRelay<SectionMediaList>
        let selectedIndexPath: BehaviorRelay<IndexPath>
        let mediaList = BehaviorRelay<[Media]>(value: [])
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
                owner.selectedMedia(
                    from: owner.output.sectionMediaList.value,
                    indexPath: owner.output.selectedIndexPath.value
                )
                .observe(on: MainScheduler.asyncInstance)
                .bind(to: owner.output.mediaList)
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
    
    /// 선택한 미디어를 고화질 이미지와 함께 반환합니다.
    private func selectedMedia(
        from sectionMediaList: SectionMediaList,
        indexPath: IndexPath
    ) -> Observable<[Media]> {
        let media = sectionMediaList[indexPath.section].1[indexPath.row]
        return photoKitService.fetchMedias(from: [media.id], option: .high)
    }
}
