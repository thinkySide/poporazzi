//
//  CustomFont+.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import UIKit

extension UIFont {
    
    /// 프리텐다드 폰트를 설정합니다.
    static func setPretendard(_ weight: Pretendard, _ size: CGFloat) -> UIFont? {
        UIFont(
            name: weight.fileName(),
            size: size
        )
    }
    
    /// 런드리고딕 폰트를 설정합니다.
    static func setLaundryGothic(_ weight: LaundryGothic, _ size: CGFloat) -> UIFont? {
        UIFont(
            name: weight.fileName(),
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
    
    /// 프리텐다드
    enum Pretendard: CustomFont {
        case thin
        case extraLight
        case light
        case regular
        case medium
        case semiBold
        case bold
        case extraBold
        case black
        
        func fileName() -> String {
            switch self {
            case .thin: "Pretendard-Thin"
            case .extraLight: "Pretendard-ExtraLight"
            case .light: "Pretendard-Light"
            case .regular: "Pretendard-Regular"
            case .medium: "Pretendard-Medium"
            case .semiBold: "Pretendard-SemiBold"
            case .bold: "Pretendard-Bold"
            case .extraBold: "Pretendard-ExtraBold"
            case .black: "Pretendard-Black"
            }
        }
    }
    
    /// 런드리 고딕
    enum LaundryGothic: CustomFont {
        case regular
        case bold
        
        func fileName() -> String {
            switch self {
            case .regular: "OTLaundryGothicR"
            case .bold: "OTLaundryGothicB"
            }
        }
    }
}
