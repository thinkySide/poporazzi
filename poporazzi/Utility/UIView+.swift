//
//  UIView+.swift
//  poporazzi
//
//  Created by 김민준 on 5/11/25.
//

import UIKit

extension UIView {
    
    /// 특정 영역에 Stroke를 추가합니다.
    func addStroke(_ edges: [UIRectEdge], color: UIColor, thickness: CGFloat) {
        edges.forEach { edge in
            
            let stroke = CALayer()
            stroke.backgroundColor = color.cgColor
            
            let width = bounds.width
            let height = bounds.height
            
            switch edge {
            case .top:
                stroke.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: width,
                    height: thickness
                )
            case .bottom:
                stroke.frame = CGRect(
                    x: 0,
                    y: height - thickness,
                    width: width,
                    height: thickness
                )
            case .left:
                stroke.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: thickness,
                    height: height
                )
            case .right:
                stroke.frame = CGRect(
                    x: width - thickness,
                    y: 0,
                    width: thickness,
                    height: height
                )
            default:
                break
            }
            
            self.layer.addSublayer(stroke)
        }
    }
}
