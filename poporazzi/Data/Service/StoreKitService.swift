//
//  StoreKitService.swift
//  poporazzi
//
//  Created by 김민준 on 5/12/25.
//

import StoreKit

struct StoreKitService: StoreKitServiceInterface {
    
    /// 사용자에게 AppStore 리뷰 Alert를 출력합니다.
    func requestReview() {
        guard let scene = UIApplication.shared.connectedScenes.first(where: {
            $0.activationState == .foregroundActive
        }) as? UIWindowScene else { return }
        
        Task {
            await MainActor.run {
                AppStore.requestReview(in: scene)
            }
        }
    }
}
