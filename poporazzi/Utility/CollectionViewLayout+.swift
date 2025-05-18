//
//  CollectionViewLayout+.swift
//  poporazzi
//
//  Created by 김민준 on 5/5/25.
//

import UIKit

struct CollectionViewLayout {
    
    static let mainHeaderKind = "mainHeaderKind"
    static let subHeaderKind = "subHeaderKind"
    
    private static var section: NSCollectionLayoutSection {
        
        // 1. 기본값 변수 저장
        let numberOfRows: CGFloat = 3
        let itemInset: CGFloat = 2
        
        // 2. 아이템(Cell) 설정
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalHeight(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 0, bottom: itemInset, trailing: itemInset)
        let lastItem = NSCollectionLayoutItem(layoutSize: itemSize)
        lastItem.contentInsets = .init(top: 0, leading: 0, bottom: itemInset, trailing: 0)
        
        // 3. 그룹 설정
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(1 / numberOfRows)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item, item, lastItem]
        )
        
        // 4. 섹션 설정
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 8, leading: 16, bottom: 32, trailing: 16)
        
        return section
    }
    
    /// 기본 3단 레이아웃을 반환합니다.
    static var threeColumns: UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout(section: section)
    }
    
    /// Header가 포함된 레이아웃을 반환합니다.
    static var headerSection: UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, environment in
            let section = section
            var supplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem] = []
            
            let subHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(32)
                ),
                elementKind: CollectionViewLayout.subHeaderKind,
                alignment: .topLeading
            )
            subHeader.pinToVisibleBounds = true
            
            if sectionIndex == 0 {
                let mainHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(104)
                    ),
                    elementKind: CollectionViewLayout.mainHeaderKind,
                    alignment: .top
                )
                mainHeader.zIndex = -1
                supplementaryItems = [mainHeader, subHeader]
            } else {
                supplementaryItems = [subHeader]
            }
            section.boundarySupplementaryItems = supplementaryItems
            return section
        }
    }
}
