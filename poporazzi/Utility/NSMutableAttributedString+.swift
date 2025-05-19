//
//  NSMutableAttributedString+.swift
//  poporazzi
//
//  Created by 김민준 on 5/19/25.
//

import UIKit

extension NSMutableAttributedString {
    
    /// 컬러를 적용 후 반환합니다.
    func tint(_ text: String, color: UIColor) -> Self {
        let attributes: [NSAttributedString.Key : Any] = [.foregroundColor: color]
        self.append(NSAttributedString(string: text, attributes: attributes))
        return self
    }
}
