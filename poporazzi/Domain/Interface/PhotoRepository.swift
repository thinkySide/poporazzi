//
//  PhotoRepository.swift
//  poporazzi
//
//  Created by 김민준 on 4/8/25.
//

import Foundation
import RxSwift

protocol PhotoRepository {
    
    /// 앨범 권한을 요청합니다.
    func requestAuth()
    
    /// 날짜에 맞는 전체 사진을 반환합니다.
    func fetchPhotos(from date: Date) -> Observable<[Photo]>
}
