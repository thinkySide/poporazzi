//
//  MomentRecordCell.swift
//  poporazzi
//
//  Created by 김민준 on 4/7/25.
//

import UIKit
import PinLayout
import FlexLayout

final class MomentRecordCell: UICollectionViewCell {
    
    static let identifier = "MomentRecordCell"
    
    var containerView = UIView()
    
    private let image: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    init() {
        super.init(frame: .zero)
        addSubview(image)
        configLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all(pin.safeArea)
        containerView.flex.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout

extension MomentRecordCell {
    
    func configLayout() {
        containerView.flex
            .define { flex in
                flex.addItem(image)
            }
    }
}
