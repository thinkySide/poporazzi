//
//  Alert+.swift
//  poporazzi
//
//  Created by 김민준 on 4/9/25.
//

import UIKit
import RxSwift

extension UIViewController {
    
    /// Alert 액션 타입
    enum AlertActionType {
        case confirm
        case cancel
    }
    
    /// Alert를 출력합니다.
    func showAlert(
        title: String,
        message: String?,
        confirmTitle: String
    ) -> Observable<AlertActionType> {
        return Observable.create { [weak self] observer in
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            
            let action = UIAlertAction(title: confirmTitle, style: .default) { _ in
                observer.onNext(.confirm)
                observer.onCompleted()
            }
            alert.addAction(action)
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
                observer.onNext(.cancel)
                observer.onCompleted()
            }
            alert.addAction(cancelAction)
            
            self?.present(alert, animated: true)
            
            return Disposables.create {
                alert.dismiss(animated: true)
            }
        }
        .subscribe(on: MainScheduler.instance)
    }
}
