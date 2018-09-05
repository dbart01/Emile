//
//  AnimatedImageViewTests.swift
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

class AnimatedImageViewTests: XCTestCase {
    
    private let whitePixel = Image.named("whitePixel").cgImage!
    private let blackPixel = Image.named("blackPixel").cgImage!
    
    // MARK: - Setup -
    
    override func setUp() {
        super.setUp()
        
        AnimatorProvider.shared = TestAnimatorProvider()
    }
    
    // MARK: - Test Init -
 
    func testInitWithFrame() {
        let imageView = AnimatedImageView(frame: .zero)
        
        XCTAssertNotNil(imageView.animator)
        XCTAssertTrue(imageView.animator.delegate === imageView)
    }
    
    func testInitWithCoder() {
        let imageView = Nib.load(name: "TestAnimatedImageView", type: AnimatedImageView.self)
        
        XCTAssertNotNil(imageView.animator)
        XCTAssertTrue(imageView.animator.delegate === imageView)
    }
    
    // MARK: - Test Animator GIF -
    
    func testAnimatorGifUpdated() {
        let gif = try! GIF(named: "goose", bundle: Bundle.testBundle)
        let imageView = AnimatedImageView(frame: .zero)
        
        imageView.gif = gif
        
        XCTAssertTrue(TestAnimator.shared.gif === gif)
    }
    
    // MARK: - Test Delegate -
    
    func testDelegateImageUpdates() {
        let imageView = AnimatedImageView(frame: .zero)
        
        TestAnimator.shared.invokeDelegate(using: self.blackPixel, index: 0)
        XCTAssertEqual(imageView.layer.contents as! CGImage, self.blackPixel)
        
        TestAnimator.shared.invokeDelegate(using: self.whitePixel, index: 0)
        XCTAssertEqual(imageView.layer.contents as! CGImage, self.whitePixel)
    }
}
