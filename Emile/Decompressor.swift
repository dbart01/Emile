//
//  Decompressor.swift
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

internal enum Decompressor {
    
    internal static let decompressionQueue = DispatchQueue(
        label: "com.emile.decompressionQueue",
        qos: .default,
        attributes: .concurrent,
        autoreleaseFrequency: .inherit,
        target: nil
    )
    
    private static let bitsPerComponent: Int = 8
    
    private static let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    internal static func inflate(_ image: CGImage) -> CGImage {
        var info = CGBitmapInfo.byteOrder32Big.rawValue
        info    |= image.hasAlpha ? CGImageAlphaInfo.premultipliedFirst.rawValue : CGImageAlphaInfo.noneSkipFirst.rawValue
        
        let context = CGContext(
            data:             nil,
            width:            image.width,
            height:           image.height,
            bitsPerComponent: Decompressor.bitsPerComponent,
            bytesPerRow:      0,
            space:            Decompressor.colorSpace,
            bitmapInfo:       info
        )
        
        if let context = context {
            let imageFrame = CGRect(x: 0, y: 0, width: image.width, height: image.height)
            context.draw(image, in: imageFrame)
            
            if let decompressedImage = context.makeImage() {
                return decompressedImage
            }
        }
        
        return image
    }
}

// MARK: - CGImage Extensions -

private extension CGImage {
    
    var hasAlpha: Bool {
        switch self.alphaInfo {
        case .first, .last, .premultipliedFirst, .premultipliedLast:
            return true
        default:
            return false
        }
    }
}
