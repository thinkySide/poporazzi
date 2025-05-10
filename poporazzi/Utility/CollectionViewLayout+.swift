//
//  CollectionViewLayout+.swift
//  poporazzi
//
//  Created by 김민준 on 5/5/25.
//

import UIKit

struct CollectionViewLayout {
    
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
    
    /// Header가 포함된 기본 3단 레이아웃을 반환합니다.
    static var threeColumnsWithHeader: UICollectionViewCompositionalLayout {
        
        let headerSection = section
        
        // 헤더 설정
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(32)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        headerSection.boundarySupplementaryItems = [header]
        
        return UICollectionViewCompositionalLayout(section: headerSection)
    }
}
