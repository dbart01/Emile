//
//  AnimatorTests.swift
//  EmileTests
//
//  The MIT License (MIT)
//
//  Copyright (c) 2018 Dima Bart
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import XCTest
@testable import Emile

class AnimatorTests: XCTestCase {
    
    private let gif = try! GIF(named: "goose", bundle: .testBundle)
    
    // MARK: - Init -
    
    func testInit() {
        let animator = Animator()
        
        XCTAssertNil(animator.delegate)
        XCTAssertNil(animator.gif)
        
        XCTAssertNotNil(animator.testingState.proxy)
        XCTAssertNotNil(animator.testingState.proxy.block)
        XCTAssertNotNil(animator.testingState.timer)
        
        XCTAssertEqual(animator.testingState.timer.isPaused,    true)
        XCTAssertEqual(animator.testingState.frameStartTime,    .idle)
        XCTAssertEqual(animator.testingState.currentImageIndex, .prestart)
        XCTAssertEqual(animator.testingState.loops,             0)
    }
    
    func testDeinit() {
        var animator: Animator? = Animator()
        weak var proxy: ActionProxy? = animator!.testingState.proxy
        
        XCTAssertNotNil(animator)
        let timer = animator!.testingState.timer
        
        animator = nil
        
        XCTAssertEqual(timer.isPaused, true)
        
        // Verifies the timer is invalidate
        // and the proxy is released.
        XCTAssertNil(proxy)
    }
    
    // MARK: - Control -
    
    func testStartWithoutImage() {
        let animator = Animator()
        
        XCTAssertEqual(animator.testingState.timer.isPaused, true)
        
        animator.testStart()
        
        XCTAssertEqual(animator.testingState.timer.isPaused, true)
    }
    
    func testStartWithImage() {
        let animator = Animator()
        
        XCTAssertEqual(animator.testingState.timer.isPaused, true)
        
        animator.gif = self.gif
        
        XCTAssertEqual(animator.testingState.timer.isPaused, false)
    }
    
    func testStop() {
        let animator = Animator()
        animator.gif = self.gif
        
        XCTAssertEqual(animator.testingState.timer.isPaused, false)
        
        animator.testStop()
        
        XCTAssertEqual(animator.testingState.frameStartTime,    .idle)
        XCTAssertEqual(animator.testingState.currentImageIndex, .prestart)
        XCTAssertEqual(animator.testingState.timer.isPaused,    true)
    }
    
    // MARK: - Tick -
    
    func testTickWithoutImage() {
        let animator = Animator(timerProvider: TestTimerProvider())
        
        XCTAssertNil(animator.gif)
        XCTAssertEqual(animator.testingState.frameStartTime,    .idle)
        XCTAssertEqual(animator.testingState.currentImageIndex, .prestart)
        
        TestTimer.shared.invokeTick()
        
        XCTAssertEqual(animator.testingState.frameStartTime,    .idle)
        XCTAssertEqual(animator.testingState.currentImageIndex, .prestart)
    }
    
    func testTickWithInitialFrame() {
        let animator = Animator(timerProvider: TestTimerProvider())
        animator.gif = self.gif
        
        XCTAssertEqual(animator.testingState.frameStartTime,    .idle)
        XCTAssertEqual(animator.testingState.currentImageIndex, .prestart)
        
        TestTimer.shared.timestamp = 300
        TestTimer.shared.invokeTick()
        
        XCTAssertEqual(animator.testingState.frameStartTime,    300000)
        XCTAssertEqual(animator.testingState.currentImageIndex, 0)
    }
    
    func testTickWithMidFrame() {
        let animator = Animator(timerProvider: TestTimerProvider())
        animator.gif = self.gif
        
        XCTAssertEqual(animator.testingState.frameStartTime,    .idle)
        XCTAssertEqual(animator.testingState.currentImageIndex, .prestart)
        
        TestTimer.shared.timestamp = 100
        TestTimer.shared.invokeTick()
        
        TestTimer.shared.timestamp = 500
        TestTimer.shared.invokeTick()
        
        XCTAssertEqual(animator.testingState.frameStartTime,    500000)
        XCTAssertEqual(animator.testingState.currentImageIndex, 1)
    }
}

// MARK: - TestAnimatorDelegate -

private class TestAnimatorDelegate: AnimatorDelegate {
    
    var didUpdate: ((Animator, CGImage, Int) -> Void)?
    
    func animator(_ animator: Animator, didUpdateImage image: CGImage, at index: Int) {
        self.didUpdate?(animator, image, index)
    }
}
