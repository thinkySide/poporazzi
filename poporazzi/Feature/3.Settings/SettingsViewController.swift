//
//  SettingsViewController.swift
//  poporazzi
//
//  Created by 김민준 on 5/23/25.
//

import UIKit
import RxSwift
import RxCocoa

final class SettingsViewController: ViewController {
    
    private let scene = SettingsView()
    private let viewModel: SettingsViewModel
    
    let disposeBag = DisposeBag()
    
    init(viewModel: SettingsViewModel) {
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

extension SettingsViewController {
    
    func bind() {
        let input = SettingsViewModel.Input(
            writeAppStoreReviviewButtonTapped: scene.writeAppStoreReviviewButton.tapGesture.rx.event.asVoidSignal(),
            requestFeatureAndInquiriesButtonTapped: scene.requestFeatureAndInquiriesButton.tapGesture.rx.event.asVoidSignal(),
            shareWithFriendsButtonTapped: scene.shareWithFriendsButton.tapGesture.rx.event.asVoidSignal(),
            poporazziOpenChatRoomButtonTapped: scene.poporazziOpenChatRoomButton.tapGesture.rx.event.asVoidSignal(),
            instagramButtonTapped: scene.instagramButton.tapGesture.rx.event.asVoidSignal(),
            threadButtonTapped: scene.threadButton.tapGesture.rx.event.asVoidSignal()
            
        )
        let output = viewModel.transform(input)
    }
}
