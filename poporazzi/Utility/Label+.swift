//
//  Label+.swift
//  poporazzi
//
//  Created by 김민준 on 5/11/25.
//

import UIKit

extension UILabel {
    
    /// Label 편의 생성자
    convenience init(_ text: String = "", size: CGFloat, color: UIColor) {
        self.init(frame: .zero)
        self.text = text
        self.font = .setDovemayo(size)
        self.textColor = color
    }
}
