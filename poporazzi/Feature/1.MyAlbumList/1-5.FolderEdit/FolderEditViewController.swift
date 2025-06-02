//
//  FolderEditViewController.swift
//  poporazzi
//
//  Created by 김민준 on 6/3/25.
//

import UIKit
import RxSwift
import RxCocoa

final class FolderEditViewController: ViewController {
    
    private let scene = FolderEditView()
    private let viewModel: FolderEditViewModel
    
    let disposeBag = DisposeBag()
    
    init(viewModel: FolderEditViewModel) {
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

extension FolderEditViewController {
    
    func bind() {
        let input = FolderEditViewModel.Input(
            viewDidLoad: .just(()),
            titleTextChanged: scene.titleTextField.textField.rx.text.orEmpty.asSignal(onErrorJustReturn: ""),
            backButtonTapped: scene.backButton.button.rx.tap.asSignal(),
            saveButtonTapped: scene.saveButton.button.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.folder
            .bind(with: self) { owner, album in
                owner.scene.titleTextField.action(.updateText(album.title))
                owner.scene.titleTextField.action(.updatePlaceholder(album.title))
            }
            .disposed(by: disposeBag)
        
        output.isSaveButtonEnabled
            .bind(with: self) { owner, isValid in
                owner.scene.action(.toggleSaveButton(isValid))
            }
            .disposed(by: disposeBag)
        
        scene.titleTextField.textField.rx.text
            .subscribe(with: self) { owner, title in
                owner.scene.titleTextField.action(.toggleLine)
            }
            .disposed(by: disposeBag)
        
        scene.tapGesture.rx.event
            .subscribe(with: self) { owner, _ in
                owner.scene.titleTextField.action(.dismissKeyboard)
            }
            .disposed(by: disposeBag)
        
        viewModel.navigation
            .bind(with: self) { owner, path in
                owner.scene.titleTextField.action(.dismissKeyboard)
            }
            .disposed(by: disposeBag)
    }
}
