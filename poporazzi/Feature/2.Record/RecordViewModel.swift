//
//  RecordViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import RxSwift
import RxCocoa
import Photos

final class RecordViewModel: ViewModel {
    
    private let photoKitService = PhotoKitService()
    private var fetchResult: PHFetchResult<PHAsset>?
    
    private let disposeBag = DisposeBag()
    private let output: Output
    
    let navigation = PublishRelay<Navigation>()
    let delegate = PublishRelay<Delegate>()
    let alert = PublishRelay<Alert>()
    let menu = PublishRelay<Menu>()
    
    init(output: Output) {
        self.output = output
    }
}

// MARK: - Input & Output

extension RecordViewModel {
    
    struct Input {
        let viewDidLoad: Signal<Void>
        let viewBecomeActive: Signal<Void>
        let finishButtonTapped: Signal<Void>
    }
    
    struct Output {
        let record: BehaviorRelay<Record>
        let mediaList = BehaviorRelay<[Media]>(value: [])
        let viewDidRefresh = PublishRelay<Void>()
        let setupSeeMoreMenu = BehaviorRelay<[MenuModel]>(value: [])
        let finishAlertPresented = PublishRelay<AlertModel>()
        let saveCompleteAlertPresented = PublishRelay<AlertModel>()
    }
    
    enum Navigation {
        case pop
        case pushEdit(Record)
    }
    
    enum Delegate {
        case momentDidEdited(Record)
    }
    
    enum Alert {
        case save
        case popToHome
    }
    
    enum Menu {
        case edit
    }
}

// MARK: - Transform

extension RecordViewModel {
    
    func transform(_ input: Input) -> Output {
        input.viewDidLoad
            .emit(with: self) { owner, _ in
                owner.output.setupSeeMoreMenu.accept(owner.seemoreMenu)
            }
            .disposed(by: disposeBag)
        
        Signal.merge(input.viewBecomeActive, output.viewDidRefresh.asSignal())
            .asObservable()
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .withUnretained(self)
            .flatMap { owner, _ in owner.fetchCurrentPhotos() }
            .bind(to: output.mediaList)
            .disposed(by: disposeBag)
        
        input.finishButtonTapped
            .emit(with: self) { owner, _ in
                owner.output.finishAlertPresented.accept(owner.finishAlert)
            }
            .disposed(by: disposeBag)
        
        alert
            .bind(with: self) { owner, action in
                switch action {
                case .save:
                    do {
                        try owner.saveToAlbums()
                        owner.output.saveCompleteAlertPresented.accept(owner.saveAlert)
                    } catch {
                        print(error)
                    }
                    
                case .popToHome:
                    owner.navigation.accept(.pop)
                    UserDefaultsService.isTracking = false
                }
            }
            .disposed(by: disposeBag)
        
        menu
            .bind(with: self) { owner, action in
                switch action {
                case .edit:
                    let record = owner.output.record.value
                    owner.navigation.accept(.pushEdit(record))
                }
            }
            .disposed(by: disposeBag)
        
        delegate
            .bind(with: self) { owner, delegate in
                switch delegate {
                case .momentDidEdited(let record):
                    owner.output.record.accept(record)
                    owner.output.viewDidRefresh.accept(())
                }
            }
            .disposed(by: disposeBag)
        
        return output
    }
}

// MARK: - Album Logic

extension RecordViewModel {
    
    /// 현재 사진 리스트를 반환합니다.
    private func fetchCurrentPhotos() -> Observable<[Media]> {
        let trackingStartDate = output.record.value.trackingStartDate
        fetchResult = photoKitService.fetchAssetResult(
            mediaFetchType: .all,
            date: trackingStartDate,
            ascending: true
        )
        return photoKitService.fetchPhotos(fetchResult)
    }
    
    /// 앨범에 저장합니다.
    private func saveToAlbums() throws {
        let title = output.record.value.title
        try photoKitService.saveAlbum(title: title, assets: fetchResult)
    }
}

// MARK: - Alert

extension RecordViewModel {
    
    /// 기록 종료 Alert
    private var finishAlert: AlertModel {
        let title = output.record.value.title
        let totalCount = output.mediaList.value.count
        return AlertModel(
            title: "기록을 종료할까요?",
            message: "총 \(totalCount)장의 '\(title)' 기록 종료 후 앨범에 저장돼요",
            eventButton: .init(
                title: "종료",
                action: { [weak self] in
                    self?.alert.accept(.save)
                }
            ),
            cancelButton: .init(title: "취소")
        )
    }
    
    /// 앨범 저장 Alert
    private var saveAlert: AlertModel {
        let title = output.record.value.title
        return AlertModel(
            title: "기록이 종료되었습니다!",
            message: "'\(title)' 앨범을 확인해보세요!",
            eventButton: .init(
                title: "홈으로 돌아가기",
                action: { [weak self] in
                    self?.alert.accept(.popToHome)
                }
            )
        )
    }
}

// MARK: - Menu

extension RecordViewModel {
    
    /// 더보기 Menu
    private var seemoreMenu: [MenuModel] {
        let edit = MenuModel(symbol: .edit, title: "기록 수정") { [weak self] in
            self?.menu.accept(.edit)
        }
        return [edit]
    }
}
