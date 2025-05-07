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
        viewModel = RecordViewModel(output: .init(album: .init(value: .initialValue)))
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        try super.tearDownWithError()
    }
    
    typealias TestInput = (
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
    
    func test_앨범제목입력() throws {
        
        // 1. given: 필요한 모든 값 설정
        let (input, output) = makeInputOutput()
        
        // 2. when: 테스트 중인 코드 실행
        
        
        // 3. then: 에상 결과 확인
        
    }
}

// MARK: - Input & Output

extension RecordTests {
    
    func makeInputOutput() -> (TestInput, RecordViewModel.Output) {
        let testInput = TestInput(
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
            viewDidLoad: .just(()),
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
