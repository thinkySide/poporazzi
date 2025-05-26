//
//  DetailViewController.swift
//  poporazzi
//
//  Created by 김민준 on 5/26/25.
//

import UIKit
import RxSwift
import RxCocoa

final class DetailViewController: ViewController {
    
    private let scene = DetailView()
    private let viewModel: DetailViewModel
    
    let disposeBag = DisposeBag()
    
    init(viewModel: DetailViewModel) {
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

extension DetailViewController {
    
    func bind() {
        let input = DetailViewModel.Input(
            
        )
        let output = viewModel.transform(input)
    }
}
