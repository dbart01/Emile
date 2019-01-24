//
//  TestTimer.swift
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

import Foundation
@testable import Emile

class TestTimer: TimerType {
    
    private var target:   Any?
    private let selector: Selector
    
    // MARK: - TimerType -
    
    var timestamp: CFTimeInterval
    
    var isPaused: Bool
    
    func add(to runLoop: RunLoop, forMode mode: RunLoopMode) {}
    
    func invalidate() {
        self.target = nil
    }
    
    // MARK: - Init -
    
    required init(target: Any, selector: Selector) {
        self.timestamp = 0
        self.target    = target
        self.selector  = selector
        self.isPaused  = false
    }
    
    static private(set) var shared: TestTimer = TestTimer(target: TestTarget(), selector: #selector(testSelector))
    
    static func createShared(target: Any, selector: Selector) -> TestTimer {
        let timer = TestTimer(target: target, selector: selector)
        self.shared = timer
        return timer
    }
    
    // MARK: - Tick -
    
    func invokeTick() {
        (self.target as? NSObject)?.performSelector(onMainThread: self.selector, with: nil, waitUntilDone: true)
    }
    
    // MARK: - Selector -
    
    @objc private func testSelector() {}
}

private class TestTarget {}
