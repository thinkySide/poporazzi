//
//  OnboardingViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 6/4/25.
//

import Foundation
import RxSwift
import RxCocoa

final class OnboardingViewModel: ViewModel {
    
    private let output: Output
    
    let disposeBag = DisposeBag()
    let navigation = PublishRelay<Navigation>()
    
    init(output: Output) {
        self.output = output
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Input & Output

extension OnboardingViewModel {
    
    struct Input {
        let actionButtonTapped: Signal<Void>
        let currentIndex: Signal<Int>
    }
    
    struct Output {
        let onboardingItems = BehaviorRelay<[OnboardingItem]>(value: OnboardingItem.list)
        let currentIndex = BehaviorRelay<Int>(value: 0)
        let currentItem = BehaviorRelay<OnboardingItem>(value: OnboardingItem.list.first!)
        
        let nextButtonTapped = PublishRelay<Int>()
    }
    
    enum Navigation {
        
    }
}

// MARK: - Transform

extension OnboardingViewModel {
    
    func transform(_ input: Input) -> Output {
        input.actionButtonTapped
            .emit(with: self) { owner, _ in
                let currentIndex = owner.output.currentIndex.value
                if currentIndex >= owner.onboardingItems.count - 1 {
                    // TODO: Start
                } else {
                    owner.output.nextButtonTapped.accept(currentIndex + 1)
                }
            }
            .disposed(by: disposeBag)
        
        input.currentIndex
            .distinctUntilChanged()
            .emit(to: output.currentIndex)
            .disposed(by: disposeBag)
        
        output.currentIndex
            .bind(with: self) { owner, index in
                let item = owner.onboardingItems[index]
                owner.output.currentItem.accept(item)
            }
            .disposed(by: disposeBag)
        
        return output
    }
}

// MARK: - Syntax Sugar

extension OnboardingViewModel {
    
    var onboardingItems: [OnboardingItem] {
        output.onboardingItems.value
    }
    
    var currentIndex: Int {
        output.currentIndex.value
    }
}
