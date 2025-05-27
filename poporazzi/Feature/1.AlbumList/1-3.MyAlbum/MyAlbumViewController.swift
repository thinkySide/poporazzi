//
//  MyAlbumViewController.swift
//  poporazzi
//
//  Created by 김민준 on 5/27/25.
//

import UIKit
import RxSwift
import RxCocoa

final class MyAlbumViewController: ViewController {
    
    private let scene = MyAlbumView()
    private let viewModel: MyAlbumViewModel
    
    let disposeBag = DisposeBag()
    
    init(viewModel: MyAlbumViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = scene
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Binding

extension MyAlbumViewController {
    
    func bind() {
        let input = MyAlbumViewModel.Input(
            
        )
        let output = viewModel.transform(input)
        
    }
}
