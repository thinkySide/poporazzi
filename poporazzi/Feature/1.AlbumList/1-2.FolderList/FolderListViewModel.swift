//
//  FolderListViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 5/30/25.
//

import UIKit
import RxSwift
import RxCocoa

final class FolderListViewModel: ViewModel {
    
    @Dependency(\.photoKitService) var photoKitService
    
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

extension FolderListViewModel {
    
    struct Input {
        let viewDidLoad: Signal<Void>
        // let folderCellSelected: Signal<IndexPath>
    }
    
    struct Output {
        
    }
    
    enum Navigation {
        
    }
}

// MARK: - Transform

extension FolderListViewModel {
    
    func transform(_ input: Input) -> Output {
        
        return output
    }
}
