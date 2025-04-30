//
//  CustomFont+.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import UIKit

extension UIFont {
    
    /// 둘기마요 고딕 폰트를 설정합니다.
    static func setDovemayo(_ size: CGFloat) -> UIFont? {
        UIFont(
            name: DovemayoGothic.regular.fileName(),
            size: size
        )
    }
}

extension UIFont {
    
    /// 커스텀 폰트 프로토콜
    protocol CustomFont {
        
        /// 파일명을 반환합니다.
        func fileName() -> String
    }
    
    /// 둘기마요
    enum DovemayoGothic: CustomFont {
        case regular
        
        func fileName() -> String {
            switch self {
            case .regular: "Dovemayo_gothic"
            }
        }
    }
}
