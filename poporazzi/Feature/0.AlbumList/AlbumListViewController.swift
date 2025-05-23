//
//  AlbumListViewController.swift
//  poporazzi
//
//  Created by 김민준 on 5/23/25.
//

import UIKit
import RxSwift
import RxCocoa

final class AlbumListViewController: ViewController {
    
    private let scene = AlbumListView()
    private let viewModel: AlbumListViewModel
    
    let disposeBag = DisposeBag()
    
    init(viewModel: AlbumListViewModel) {
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

extension AlbumListViewController {
    
    func bind() {
        let input = AlbumListViewModel.Input(
            
        )
        let output = viewModel.transform(input)
        
    }
}
