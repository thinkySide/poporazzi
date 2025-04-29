//
//  MenuModel+.swift
//  poporazzi
//
//  Created by 김민준 on 4/29/25.
//

import UIKit

/// Menu 타입
struct MenuModel {
    let symbol: SFSymbol
    let title: String
    let action: () -> Void
}

extension [MenuModel] {
    
    /// UIMenu로 변환합니다.
    var toUIMenu: UIMenu {
        let actions = self.map { menu in
            UIAction(
                title: menu.title,
                image: UIImage(systemName: menu.symbol.rawValue),
                handler: { _ in menu.action() }
            )
        }
        return UIMenu(children: actions)
    }
}
