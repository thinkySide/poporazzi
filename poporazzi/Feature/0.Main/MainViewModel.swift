//
//  MainViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 5/24/25.
//

import Foundation
import RxSwift
import RxCocoa

final class MainViewModel: ViewModel {
    
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

extension MainViewModel {
    
    struct Input {
        let viewDidLoad: Signal<Void>
        let albumListTabTapped: Signal<Void>
        let recordTabTaaped: Signal<Void>
        let settingsTabTapped: Signal<Void>
    }
    
    struct Output {
        let selectedTab: BehaviorRelay<Tab>
        let isTracking: BehaviorRelay<Bool>
    }
    
    enum Navigation {
        
    }
}

// MARK: - Transform

extension MainViewModel {
    
    func transform(_ input: Input) -> Output {
        
        input.albumListTabTapped
            .map { Tab.albumList }
            .emit(with: self) { owner, tab in
                owner.output.selectedTab.accept(tab)
                owner.output.isTracking.accept(owner.output.isTracking.value)
                HapticManager.impact(style: .soft)
            }
            .disposed(by: disposeBag)
        
        input.recordTabTaaped
            .emit(with: self) { owner, tab in
                let isTracking = owner.output.isTracking.value
                let tab = Tab.record(isTracking: isTracking)
                owner.output.selectedTab.accept(tab)
                owner.output.isTracking.accept(isTracking)
                HapticManager.impact(style: .soft)
            }
            .disposed(by: disposeBag)
        
        input.settingsTabTapped
            .map { Tab.settings }
            .emit(with: self) { owner, tab in
                owner.output.selectedTab.accept(tab)
                owner.output.isTracking.accept(owner.output.isTracking.value)
                HapticManager.impact(style: .soft)
            }
            .disposed(by: disposeBag)
        
        return output
    }
}
