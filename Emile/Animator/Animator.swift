//
//  Animator.swift
//  Emile
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

import UIKit

protocol AnimatorDelegate: class {
    func animator(_ animator: Animator, didUpdateImage image: CGImage, at index: Int)
}

internal class Animator {
    
    weak var delegate: AnimatorDelegate?
    
    internal weak var gif: GIF? {
        didSet {
            if let _ = self.gif {
                self.start()
            } else {
                self.stop()
            }
        }
    }
    
    private let proxy: ActionProxy
    private let timer: TimerType
    
    private var frameStartTime: Milliseconds = .idle
    private var currentImageIndex: Index = .prestart
    private var loops: Int = 0
    
    // MARK: - Init -
    
    internal init(timerProvider: TimerProvider = TimerProvider()) {
        self.proxy = ActionProxy()
        self.timer = timerProvider.createTimer(target: self.proxy, selector: self.proxy.selector)
        
        self.proxy.block = { [weak self] in
            self?.tick()
        }
        
        self.timer.isPaused = true
        self.timer.add(to: RunLoop.current, forMode: .commonModes)
    }
    
    deinit {
        self.stop()
        self.timer.invalidate()
    }
    
    // MARK: - Control -
    
    private func start() {
        guard let _ = self.gif else {
            return
        }
        
        self.loops = 0
        
        self.reset()
        self.timer.isPaused = false
    }
    
    private func stop() {
        self.timer.isPaused = true
        self.reset()
    }
    
    private func reset() {
        self.frameStartTime    = .idle
        self.currentImageIndex = .prestart
    }
    
    // MARK: - Tick -
    
    private func tick() {
        guard let gif = self.gif else {
            self.stop()
            return
        }
        
        let currentTime = Milliseconds(fromTimestamp: self.timer.timestamp)
        if self.currentImageIndex == .prestart || self.isCurrentFrameExpired(from: currentTime) {
            
            self.frameStartTime     = currentTime
            self.currentImageIndex += 1
            
            // Loop
            if self.currentImageIndex >= gif.count {
                self.loops += 1
                self.reset()
                self.tick()
                
                let properties = gif.properties(at: self.currentImageIndex)
                if properties.loopCount > 0 && self.loops >= properties.loopCount {
                    self.stop()
                }
                
                return
            }
            
            self.delegate?.animator(self, didUpdateImage: gif.image(at: self.currentImageIndex), at: self.currentImageIndex)
            
//            let indexReference = self.currentImageIndex
//            gif.image(at: self.currentImageIndex) { image in
//                if self.currentImageIndex == indexReference {
//                    self.delegate?.animator(self, didUpdateImage: image, at: indexReference)
//                }
//            }
        }
    }
    
    private func isCurrentFrameExpired(from time: Milliseconds) -> Bool {
        assert(self.gif != nil, "[FATAL] Animator attempted a tick without a valid GIF.")
        
        let properties = self.gif!.properties(at: self.currentImageIndex)
        let deltaTime  = time - self.frameStartTime
        
        return deltaTime > properties.delayTime
    }
}

// MARK: - Testing Support -
#if TESTING

extension Animator {
    struct State {
        let proxy:             ActionProxy
        let timer:             TimerType
        let frameStartTime:    Milliseconds
        let currentImageIndex: Index
        let loops:             Int
    }
}

extension Animator {
    
    func testStart() {
        self.start()
    }
    
    func testStop() {
        self.stop()
    }
    
    func testReset() {
        self.reset()
    }
    
    var testingState: State {
        return Animator.State(
            proxy:             self.proxy,
            timer:             self.timer,
            frameStartTime:    self.frameStartTime,
            currentImageIndex: self.currentImageIndex,
            loops:             self.loops
        )
    }
}

#endif
