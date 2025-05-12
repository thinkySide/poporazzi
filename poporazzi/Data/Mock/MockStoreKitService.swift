//
//  MockStoreKitService.swift
//  poporazzi
//
//  Created by 김민준 on 5/12/25.
//

import Foundation

struct MockStoreKitService: StoreKitServiceInterface {
    
    /// 사용자에게 AppStore 리뷰 Alert를 출력합니다.
    func requestReview() {
        print("AppStore 리뷰 Alert 출력")
    }
}
