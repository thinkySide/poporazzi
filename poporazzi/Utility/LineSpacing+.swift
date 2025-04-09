//
//  LineSpacing+.swift
//  poporazzi
//
//  Created by 김민준 on 4/9/25.
//

import UIKit

extension UILabel {
    
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
