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
    let subtitle: String
    let attributes: UIMenuElement.Attributes
    let action: () -> Void
    
    init(
        symbol: SFSymbol,
        title: String,
        subtitle: String = "",
        attributes: UIMenuElement.Attributes = [],
        action: @escaping () -> Void
    ) {
        self.symbol = symbol
        self.title = title
        self.subtitle = subtitle
        self.attributes = attributes
        self.action = action
    }
}

extension [MenuModel] {
    
    /// UIMenu로 변환합니다.
    var toUIMenu: UIMenu {
        let actions = self.map { menu in
            UIAction(
                title: menu.title,
                subtitle: menu.subtitle,
                image: UIImage(systemName: menu.symbol.rawValue),
                attributes: menu.attributes,
                handler: { _ in menu.action() }
            )
        }
        return UIMenu(children: actions)
    }
}
