//
//  TitleInputViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import Foundation
import RxSwift
import RxCocoa

final class TitleInputViewModel: ViewModel {
    
    @Dependency(\.liveActivityService) var liveActivityService
    
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

extension TitleInputViewModel {
    
    struct Input {
        let titleTextChanged: Signal<String>
        let nextButtonTapped: Signal<Void>
    }
    
    struct Output {
        let titleText = BehaviorRelay<String>(value: "")
        let isNextButtonEnabled = BehaviorRelay<Bool>(value: false)
    }
    
    enum Navigation {
        case pushAlbumOptionInput(title: String)
    }
}

// MARK: - Transform

extension TitleInputViewModel {
    
    func transform(_ input: Input) -> Output {
        input.titleTextChanged
            .emit(to: output.titleText)
            .disposed(by: disposeBag)
        
        input.titleTextChanged
            .map { !$0.isEmpty }
            .emit(to: output.isNextButtonEnabled)
            .disposed(by: disposeBag)
        
        input.nextButtonTapped
            .emit(with: self) { owner, _ in
                let title = owner.output.titleText.value
                owner.navigation.accept(.pushAlbumOptionInput(title: title))
                HapticManager.impact(style: .soft)
            }
            .disposed(by: disposeBag)
        
        return output
    }
}
