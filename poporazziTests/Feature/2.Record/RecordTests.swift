//
//  RecordTests.swift
//  poporazziTests
//
//  Created by 김민준 on 5/7/25.
//

import XCTest
import RxSwift
import RxCocoa
@testable import poporazzi

final class RecordTests: XCTestCase {
    
    private var viewModel: RecordViewModel!
    
    override func setUpWithError() throws {
        DIContainer.shared.inject(.testValue)
        viewModel = RecordViewModel(output: .init(album: .init(value: .initialValue)))
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        try super.tearDownWithError()
    }
    
    typealias TestInput = (
        viewDidLoad: PublishRelay<Void>,
        selectButtonTapped: PublishRelay<Void>,
        selectCancelButtonTapped: PublishRelay<Void>,
        recentIndexPath: BehaviorRelay<IndexPath>,
        recordCellSelected: PublishRelay<IndexPath>,
        recordCellDeselected: PublishRelay<IndexPath>,
        excludeButtonTapped: PublishRelay<Void>,
        removeButtonTapped: PublishRelay<Void>,
        finishButtonTapped: PublishRelay<Void>
    )
}

// MARK: - Tests

extension RecordTests {
    
    func test_첫화면진입() throws {
        let (input, output) = makeInputOutput()
        let disposeBag = DisposeBag()
        
        let noThumbnailExpectaion = XCTestExpectation(description: "더미 Media 전달")
        let mediaListExpectaion = XCTestExpectation(description: "이미지 포함된 Media 전달")
        
        XCTAssertTrue(output.mediaList.value.isEmpty)
        
        output.mediaList
            .skip(1)
            .subscribe(onNext: { mediaList in
                XCTAssertTrue(!mediaList.isEmpty)
                noThumbnailExpectaion.fulfill()
            })
            .disposed(by: disposeBag)
        
        output.updateRecordCells
            .skip(1)
            .subscribe(onNext: { orderedMediaList in
                XCTAssertTrue(!orderedMediaList.isEmpty)
                mediaListExpectaion.fulfill()
            })
            .disposed(by: disposeBag)
        
        input.viewDidLoad.accept(())
        
        wait(for: [noThumbnailExpectaion, mediaListExpectaion], timeout: 1.0)
    }
    
    func test_화면리프레쉬() throws {
        let (_, output) = makeInputOutput()
        let disposeBag = DisposeBag()
        
        let dummys: [[Media]] = (0..<300).map { [Media](id: String($0), creationDate: .now, mediaType: .photo(.selfShooting, .heic)) }
        output.mediaList.accept(dummys)
        
        output.mediaList
            .skip(1)
            .subscribe(onNext: { mediaList in
                XCTAssertTrue(!mediaList.isEmpty)
                XCTAssertTrue(dummys != mediaList)
            })
            .disposed(by: disposeBag)
        
        output.viewDidRefresh.accept(())
    }
    
    func test_페이지네이션() throws {
        let (input, output) = makeInputOutput()
        let disposeBag = DisposeBag()
        
        let expectation = XCTestExpectation(description: "페이지네이션 횟수 카운트")
        expectation.expectedFulfillmentCount = 2
        
        let dummys: [[Media]] = (0..<300).map { [Media](id: String($0), creationDate: .now, mediaType: .photo(.selfShooting, .heic)) }
        output.mediaList.accept(dummys)
        
        output.updateRecordCells
            .skip(1)
            .subscribe(onNext: { orderedMediaList in
                XCTAssertTrue(!orderedMediaList.isEmpty)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        input.recentIndexPath.accept(IndexPath(row: 20, section: 0))
        input.recentIndexPath.accept(IndexPath(row: 80, section: 0))
        input.recentIndexPath.accept(IndexPath(row: 90, section: 0))
        input.recentIndexPath.accept(IndexPath(row: 189, section: 0))
        input.recentIndexPath.accept(IndexPath(row: 200, section: 0))
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func test_선택모드진입() throws {
        let (input, output) = makeInputOutput()
        let disposeBag = DisposeBag()
        
        input.selectButtonTapped.accept(())
        
        output.switchSelectMode
            .subscribe(onNext: { bool in
                XCTAssertTrue(bool)
            })
            .disposed(by: disposeBag)
    }
    
    func test_선택모드취소() throws {
        let (input, output) = makeInputOutput()
        let disposeBag = DisposeBag()
        
        input.selectCancelButtonTapped.accept(())
        
        output.switchSelectMode
            .subscribe(onNext: { bool in
                XCTAssertFalse(bool)
            })
            .disposed(by: disposeBag)
    }
    
    func test_셀탭이벤트() throws {
        let (input, output) = makeInputOutput()
        
        input.recordCellSelected.accept(.init(row: 0, section: 0))
        input.recordCellSelected.accept(.init(row: 1, section: 0))
        input.recordCellSelected.accept(.init(row: 2, section: 0))
        
        input.recordCellDeselected.accept(.init(row: 1, section: 0))
        input.recordCellDeselected.accept(.init(row: 2, section: 0))
        
        XCTAssertTrue(output.selectedRecordCells.value.count == 1)
        XCTAssertTrue(output.selectedRecordCells.value.first! == .init(row: 0, section: 0))
    }
    
    func test_기록종료_미디어없음() throws {
        let (_, output) = makeInputOutput()
        let disposeBag = DisposeBag()
        
        output.mediaList.accept([])
        
        let expectation = expectation(description: "뒤로가기")
        
        viewModel.navigation
            .subscribe(onNext: { navigation in
                if case .pop = navigation {
                    expectation.fulfill()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.alertAction.accept(.finishWithoutRecord)
        
        wait(for: [expectation], timeout: 1.0)
        
        // XCTAssertTrue(UserDefaultsService.excludeAssets.isEmpty)
        // XCTAssertTrue(!UserDefaultsService.trackingAlbumId)
    }
}

// MARK: - Input & Output

extension RecordTests {
    
    func makeInputOutput() -> (TestInput, RecordViewModel.Output) {
        let testInput = TestInput(
            viewDidLoad: PublishRelay<Void>(),
            selectButtonTapped: PublishRelay<Void>(),
            selectCancelButtonTapped: PublishRelay<Void>(),
            recentIndexPath: BehaviorRelay<IndexPath>(value: .init(row: 0, section: 0)),
            recordCellSelected: PublishRelay<IndexPath>(),
            recordCellDeselected: PublishRelay<IndexPath>(),
            excludeButtonTapped: PublishRelay<Void>(),
            removeButtonTapped: PublishRelay<Void>(),
            finishButtonTapped: PublishRelay<Void>()
        )
        
        let input = RecordViewModel.Input(
            viewDidLoad: testInput.viewDidLoad.asSignal(),
            selectButtonTapped: testInput.selectButtonTapped.asSignal(),
            selectCancelButtonTapped: testInput.selectCancelButtonTapped.asSignal(),
            recentIndexPath: testInput.recentIndexPath,
            recordCellSelected: testInput.recordCellSelected.asSignal(),
            recordCellDeselected: testInput.recordCellDeselected.asSignal(),
            excludeButtonTapped: testInput.excludeButtonTapped.asSignal(),
            removeButtonTapped: testInput.removeButtonTapped.asSignal(),
            finishButtonTapped: testInput.finishButtonTapped.asSignal()
        )
        let output = viewModel.transform(input)
        
        return (testInput, output)
    }
}
