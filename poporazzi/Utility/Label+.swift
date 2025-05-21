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
    
    /// Label 정렬 및 줄 간격을 설정합니다.
    func setLine(alignment: NSTextAlignment, spacing: CGFloat) {
        guard let text = text else { return }
        let attributeString = NSMutableAttributedString(string: text)
        let style = NSMutableParagraphStyle()
        style.alignment = alignment
        style.lineSpacing = spacing
        attributeString.addAttribute(
            .paragraphStyle,
            value: style,
            range: NSRange(location: 0, length: attributeString.length)
        )
        attributedText = attributeString
    }
}
