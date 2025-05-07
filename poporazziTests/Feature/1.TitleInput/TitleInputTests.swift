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
    
    /// 각각의 Test Method를 실행하기 전에 모든 상태를 reset해주는 함수
    override func setUpWithError() throws {
        viewModel = TitleInputViewModel(output: .init())
        try super.setUpWithError()
    }
    
    /// 각각의 Test Method들이 끝나고 난 뒤에 cleanup을 수행해주는 함수
    override func tearDownWithError() throws {
        viewModel = nil
        try super.tearDownWithError()
    }
    
    typealias TestInput = (
        titleTextChanged: PublishRelay<String>,
        startButtonTapped: PublishRelay<Void>
    )
}

// MARK: - Tests

extension TitleInputTests {
    
    /// 테스트 메소드의 이름은 항상 'test'로 시작하고
    /// 뒤에는 무엇을 테스트하는지 설명해줘야한다.
    func test_앨범제목입력() throws {
        
        // 1. given: 필요한 모든 값 설정
        let (input, output) = makeInputOutput()
        
        // 2. when: 테스트 중인 코드 실행
        input.titleTextChanged.accept("콜드플레이 내한 콘서트")
        
        // 3. then: 에상 결과 확인
        XCTAssertEqual(output.titleText.value, "콜드플레이 내한 콘서트")
        XCTAssertTrue(output.isStartButtonEnabled.value)
    }
}

// MARK: - Input & Output

extension TitleInputTests {
    
    func makeInputOutput() -> (TestInput, TitleInputViewModel.Output) {
        let testInput = (
            titleTextChanged: PublishRelay<String>(),
            startButtonTapped: PublishRelay<Void>()
        )
        let input = TitleInputViewModel.Input(
            titleTextChanged: testInput.titleTextChanged.asSignal(),
            startButtonTapped: testInput.startButtonTapped.asSignal()
        )
        let output = viewModel.transform(input)
        return (testInput, output)
    }
}
