//
//  MomentTitleInputViewController.swift
//  poporazzi
//
//  Created by 김민준 on 4/4/25.
//

import UIKit

final class MomentTitleInputViewController: UIViewController {
    
    private let customView = MomentTitleInputView()
    
    override func loadView() {
        view = customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
