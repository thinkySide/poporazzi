//
//  TitleInputTests.swift
//  poporazziTests
//
//  Created by 김민준 on 5/7/25.
//

import XCTest
import RxSwift
import RxCocoa
@testable import poporazzi

final class TitleInputTests: XCTestCase {
    
    private var viewModel: TitleInputViewModel!
    
    override func setUpWithError() throws {
        DIContainer.shared.inject(.testValue)
        viewModel = TitleInputViewModel(output: .init())
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        try super.tearDownWithError()
    }
    
    typealias TestInput = (
        containScreenshotChanged: PublishRelay<Bool>,
        titleTextChanged: PublishRelay<String>,
        startButtonTapped: PublishRelay<Void>
    )
}

// MARK: - Tests

extension TitleInputTests {
    
    func test_앨범제목입력() throws {
        let (input, output) = makeInputOutput()
        
        let testTitle = "콜드플레이 내한 콘서트"
        input.titleTextChanged.accept(testTitle)
        
        XCTAssertEqual(output.titleText.value, testTitle)
        XCTAssertTrue(output.isStartButtonEnabled.value)
    }
    
    func test_시작버튼활성화() throws {
        let (input, output) = makeInputOutput()
        
        XCTAssertTrue(!output.isStartButtonEnabled.value)
        input.titleTextChanged.accept("테스트")
        XCTAssertTrue(output.isStartButtonEnabled.value)
        input.titleTextChanged.accept("")
        XCTAssertTrue(!output.isStartButtonEnabled.value)
    }
    
    func test_시작후저장값() throws {
        let (input, _) = makeInputOutput()
        let testTitle = "테스트"
        input.titleTextChanged.accept(testTitle)
        input.startButtonTapped.accept(())
        XCTAssertTrue(UserDefaultsService.albumTitle == testTitle)
        XCTAssertTrue(UserDefaultsService.isTracking)
    }
}

// MARK: - Input & Output

extension TitleInputTests {
    
    func makeInputOutput() -> (TestInput, TitleInputViewModel.Output) {
        let testInput = (
            containScreenshotChanged: PublishRelay<Bool>(),
            titleTextChanged: PublishRelay<String>(),
            startButtonTapped: PublishRelay<Void>()
        )
        let input = TitleInputViewModel.Input(
            titleTextChanged: testInput.titleTextChanged.asSignal(),
            containScreenshotChanged: testInput.containScreenshotChanged.asSignal(),
            startButtonTapped: testInput.startButtonTapped.asSignal()
        )
        let output = viewModel.transform(input)
        return (testInput, output)
    }
}
