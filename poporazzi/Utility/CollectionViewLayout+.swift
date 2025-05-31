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
    
    /// 기본 3단 레이아웃을 반환합니다.
    static var recordThreeColumns: UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout(section: recordLayout)
    }
    
    /// Header가 포함된 레이아웃을 반환합니다.
    static var recordHeaderSection: UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, environment in
            let section = recordLayout
            var supplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem] = []
            
            let subHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(36)
                ),
                elementKind: CollectionViewLayout.subHeaderKind,
                alignment: .top
            )
            subHeader.pinToVisibleBounds = true
            
            // 최상단 Section에만 mainHeader 적용
            if sectionIndex == 0 {
                let mainHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(64)
                    ),
                    elementKind: CollectionViewLayout.mainHeaderKind,
                    alignment: .top
                )
                mainHeader.zIndex = 0
                supplementaryItems = [mainHeader, subHeader]
            } else {
                // 이후에는 subHeader만 적용
                supplementaryItems = [subHeader]
            }
            section.boundarySupplementaryItems = supplementaryItems
            return section
        }
    }
}

// MARK: - New

extension CollectionViewLayout {
    
    /// 3단 레이아웃 섹션을 반환합니다.
    static var threeStageSection: NSCollectionLayoutSection {
        
        // 1. 기본값 변수 저장
        let numberOfRows: CGFloat = 3
        let itemInset: CGFloat = 3
        
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
    
    /// 제목 Header
    static var titleHeader: NSCollectionLayoutBoundarySupplementaryItem {
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(64)
            ),
            elementKind: CollectionViewLayout.mainHeaderKind,
            alignment: .top
        )
        header.zIndex = 0
        return header
    }
    
    /// 날짜 Header
    static var dateHeader: NSCollectionLayoutBoundarySupplementaryItem {
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(36)
            ),
            elementKind: CollectionViewLayout.subHeaderKind,
            alignment: .top
        )
        header.pinToVisibleBounds = true
        return header
    }
}

// MARK: - Helper

extension CollectionViewLayout {
    
    /// 기록용 3단 레이아웃 Section을 반환합니다.
    static var recordLayout: NSCollectionLayoutSection {
        
        // 1. 기본값 변수 저장
        let numberOfRows: CGFloat = 3
        let itemInset: CGFloat = 3
        
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
    
    static var myAlbumListLayout: UICollectionViewCompositionalLayout {
        let numberOfColumns: CGFloat = 2
        let hightRatio: CGFloat = 1.3
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1 / numberOfColumns),
            heightDimension: .fractionalWidth(hightRatio / numberOfColumns)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 8, bottom: 20, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(hightRatio / numberOfColumns)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item, item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    static var folderListLayout: UICollectionViewCompositionalLayout {
        let height: CGFloat = 64
        let spacing: CGFloat = 20
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(height)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 0, bottom: spacing, trailing: 0)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(height + spacing)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 12, leading: 16, bottom: 0, trailing: 16)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
