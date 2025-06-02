//
//  AlbumEditViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 6/3/25.
//

import Foundation
import RxSwift
import RxCocoa

final class AlbumEditViewModel: ViewModel {
    
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

extension AlbumEditViewModel {
    
    struct Input {
        let viewDidLoad: Signal<Void>
        
        let titleTextChanged: Signal<String>
        
        let backButtonTapped: Signal<Void>
        let saveButtonTapped: Signal<Void>
    }
    
    struct Output {
        let album: BehaviorRelay<Album>
        let titleText: BehaviorRelay<String>
        let isSaveButtonEnabled = BehaviorRelay<Bool>(value: true)
    }
    
    enum Navigation {
        case pop
    }
}

// MARK: - Transform

extension AlbumEditViewModel {
    
    func transform(_ input: Input) -> Output {
        input.titleTextChanged
            .emit(to: output.titleText)
            .disposed(by: disposeBag)
        
        input.titleTextChanged
            .map { !$0.isEmpty }
            .emit(to: output.isSaveButtonEnabled)
            .disposed(by: disposeBag)
        
        input.backButtonTapped
            .emit(with: self) { owner, _ in
                owner.navigation.accept(.pop)
            }
            .disposed(by: disposeBag)
        
        input.saveButtonTapped
            .emit(with: self) { owner, _ in
                // TODO: 여기서 앨범 이름 수정
                
                HapticManager.notification(type: .success)
            }
            .disposed(by: disposeBag)
        
        return output
    }
}
