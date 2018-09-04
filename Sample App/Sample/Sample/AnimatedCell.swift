//
//  AnimatedCell.swift
//  Sample
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
import Emile

class AnimatedCell: UICollectionViewCell {
    
    var gif: GIF? {
        didSet {
            self.animatedImageView.gif = self.gif
        }
    }
    
    private let animatedImageView = AnimatedImageView(frame: .zero)
    
    // MARK: - Init -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initialize()
    }
    
    private func initialize() {
        self.selectedBackgroundView = nil
        
        self.animatedImageView.translatesAutoresizingMaskIntoConstraints = false
        self.animatedImageView.contentMode   = .scaleAspectFill
        self.animatedImageView.clipsToBounds = true
        self.addSubview(animatedImageView)
        
        NSLayoutConstraint.activate([
            self.animatedImageView.leftAnchor.constraint(equalTo: self.leftAnchor),
            self.animatedImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.animatedImageView.rightAnchor.constraint(equalTo: self.rightAnchor),
            self.animatedImageView.topAnchor.constraint(equalTo: self.topAnchor),
        ])
    }
}
