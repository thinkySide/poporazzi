//
//  FolderEditViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 6/3/25.
//

import Foundation
import RxSwift
import RxCocoa

final class FolderEditViewModel: ViewModel {
    
    @Dependency(\.photoKitService) private var photoKitService
    
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

extension FolderEditViewModel {
    
    struct Input {
        let viewDidLoad: Signal<Void>
        
        let titleTextChanged: Signal<String>
        
        let backButtonTapped: Signal<Void>
        let saveButtonTapped: Signal<Void>
    }
    
    struct Output {
        let folder: BehaviorRelay<Album>
        let titleText: BehaviorRelay<String>
        let isSaveButtonEnabled = BehaviorRelay<Bool>(value: true)
    }
    
    enum Navigation {
        case pop
        case popWithUpdate(Album)
    }
}

// MARK: - Transform

extension FolderEditViewModel {
    
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
                let newFolder = Album(
                    id: owner.folder.id,
                    title: owner.titleText.isEmpty ? owner.folder.title : owner.titleText,
                    creationDate: owner.folder.creationDate,
                    thumbnailList: owner.folder.thumbnailList,
                    estimateCount: owner.folder.estimateCount,
                    albumType: owner.folder.albumType
                )
                
                owner.photoKitService.editFolder(to: newFolder)
                    .observe(on: MainScheduler.asyncInstance)
                    .bind { isSuccess in
                        owner.navigation.accept(.popWithUpdate(newFolder))
                        HapticManager.notification(type: .success)
                    }
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        return output
    }
}

// MARK: - Syntax Sugar

extension FolderEditViewModel {
    
    var folder: Album {
        output.folder.value
    }
    
    var titleText: String {
        output.titleText.value
    }
}
