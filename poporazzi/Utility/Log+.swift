//
//  Log+.swift
//  poporazzi
//
//  Created by 김민준 on 5/2/25.
//

import Foundation

struct Log {
    
    /// 로그 메시지 열거형
    enum Message {
        case `deinit`
    }
    
    /// 로그 메시지를 출력합니다.
    static func print(_ owner: String, _ message: Message) {
#if DEBUG
        switch message {
        case .deinit:
            Swift.print("[\(fileName(owner))] - deinit")
        }
#endif
    }
    
    /// 현재 파일 이름을 반환합니다.
    static func fileName(_ file: String) -> String {
        ("\(file)" as NSString)
            .lastPathComponent
            .split(separator: ".")
            .map { String($0) }
            .first ?? ""
    }
}
