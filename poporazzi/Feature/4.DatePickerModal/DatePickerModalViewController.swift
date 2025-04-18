//
//  DatePickerModalViewController.swift
//  poporazzi
//
//  Created by 김민준 on 4/18/25.
//

import UIKit
import RxSwift
import RxCocoa

final class DatePickerModalViewController: ViewController {
    
    private let scene = DatePickerModalView()
    private let viewModel = DatePickerModalViewModel()
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        view = scene
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
}

// MARK: - Binding

extension DatePickerModalViewController {
    
    func bind() {
        
    }
}
