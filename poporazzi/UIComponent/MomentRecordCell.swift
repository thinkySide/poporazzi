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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(containerView)
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
        containerView.flex.backgroundColor(.systemBlue)
            .define { flex in
                // flex.addItem(image).aspectRatio(1)
            }
    }
}
