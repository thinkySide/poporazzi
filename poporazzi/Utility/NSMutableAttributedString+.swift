//
//  NSMutableAttributedString+.swift
//  poporazzi
//
//  Created by 김민준 on 5/19/25.
//

import UIKit

extension NSMutableAttributedString {
    
    /// 하이라이트를 위한 모델
    struct Highlight {
        var text: String
        var color: UIColor
    }
    
    /// 컬러를 적용 후 반환합니다.
    func tint(_ text: String, color: UIColor) -> Self {
        let attributes: [NSAttributedString.Key : Any] = [.foregroundColor: color]
        self.append(NSAttributedString(string: text, attributes: attributes))
        return self
    }
    
    /// 전체 문장 중 하이라이트 할 부분을 지정해 반환합니다.
    func highlight(
        text: String,
        highlights: [Highlight],
        defaultColor: UIColor = .mainLabel
    ) -> Self {
        let attributedString = NSMutableAttributedString(string: text)
        for highlight in highlights {
            let range = (text as NSString).range(of: highlight.text)
            attributedString.addAttributes([.foregroundColor: highlight.color], range: range)
        }
        self.append(attributedString)
        return self
    }
}
