//
//  SFSymbol+.swift
//  poporazzi
//
//  Created by 김민준 on 4/17/25.
//

import UIKit

enum SFSymbol: String {
    case ellipsis
    case camera = "camera.fill"
    case edit = "square.and.pencil"
    case dismiss = "xmark"
    case up = "chevron.up"
    case down = "chevron.down"
    case left = "chevron.left"
    case right = "chevron.right"
    case exclude = "nosign"
    case info = "info.circle.fill"
    case check = "checkmark"
    case checkBox = "checkmark.square.fill"
    case noSave = "xmark.bin"
}

// MARK: - initializer

extension UIImage {
    
    /// SFSymbol 편의 생성자
    convenience init?(symbol: SFSymbol, size: CGFloat, weight: UIImage.SymbolWeight) {
        let config = UIImage.SymbolConfiguration(pointSize: size, weight: weight)
        self.init(systemName: symbol.rawValue, withConfiguration: config)
    }
}

extension UIImageView {
    
    /// SFSymbol 편의 생성자
    convenience init(symbol: SFSymbol, size: CGFloat, weight: UIImage.SymbolWeight, tintColor: UIColor) {
        let image = UIImage(symbol: symbol, size: size, weight: weight)
        self.init(image: image)
        self.tintColor = tintColor
        self.contentMode = .center
    }
}
