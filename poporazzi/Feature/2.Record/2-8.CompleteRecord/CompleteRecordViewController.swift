//
//  CompleteRecordViewController.swift
//  poporazzi
//
//  Created by 김민준 on 6/17/25.
//

import UIKit
import RxSwift
import RxCocoa

final class CompleteRecordViewController: ViewController {
    
    private let scene = CompleteRecordView()
    private let viewModel: CompleteRecordViewModel
    
    let disposeBag = DisposeBag()
    
    init(viewModel: CompleteRecordViewModel) {
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

extension CompleteRecordViewController {
    
    func bind() {
        let input = CompleteRecordViewModel.Input(
            
        )
        let output = viewModel.transform(input)
    }
}
