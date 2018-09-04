//
//  GIF.swift
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

import Foundation
import ImageIO
import MobileCoreServices

public class GIF {
    
    let count: Int
    
    private let source: CGImageSource
    private var faults: [ImageFault]
    
    // MARK: - Init -
    
    public convenience init(named name: String, bundle: Bundle? = nil) throws {
        
        let resolvedBundle = (bundle ?? Bundle.main)
        if let url = resolvedBundle.url(forResource: name, withExtension: "gif") {
            try self.init(with: url)
            
        } else if let asset = NSDataAsset(name: name, bundle: resolvedBundle) {
            try self.init(with: asset.data)
            
        } else {
            print("Unable to find GIF in bundle.")
            throw GIF.Error.resourceNotFound
        }
    }
    
    public convenience init(with url: URL) throws {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            print("Failed to create GIF. Could not instantiate image source.")
            throw GIF.Error.dataInvalid
        }
        
        try self.init(with: source)
    }
    
    public convenience init(with data: Data) throws {
        guard let provider = CGDataProvider(data: data as CFData) else {
            print("Failed to create GIF. Could not instantiate data provider.")
            throw GIF.Error.dataInvalid
        }
        
        guard let source = CGImageSourceCreateWithDataProvider(provider, nil) else {
            print("Failed to create GIF. Could not instantiate image source.")
            throw GIF.Error.dataInvalid
        }
        
        try self.init(with: source)
    }
    
    public init(with source: CGImageSource) throws {
        
        guard let type = CGImageSourceGetType(source), UTTypeConformsTo(type, kUTTypeGIF) else {
            print("Failed to create GIF. Data is not a valid GIF image.")
            throw GIF.Error.dataInvalid
        }
        
        let faults  = try GIF.createFaults(from: source)
        
        self.count  = faults.count
        self.faults = faults
        self.source = source
    }
    
    private static func createFaults(from source: CGImageSource) throws -> [ImageFault] {
        let count = CGImageSourceGetCount(source)
        
        var faults: [ImageFault] = []
        faults.reserveCapacity(count)
        
        for index in 0..<count {
            guard
                let dictionary = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [String : Any],
                let properties = dictionary[kCGImagePropertyGIFDictionary as String] as? [String : Any]
                else {
                    print("Unable to obtain image properties at index: \(index)")
                    throw GIF.Error.propertiesInvalid
            }
        
            faults.append(ImageFault(
                properties: Properties(properties),
                image: nil
            ))
        }
        
        return faults
    }
    
    // MARK: - Image Management -
    
    internal func image(at index: Int) -> CGImage {
        if let image = self.faults[index].image {
            return image
        }
        
        guard let image = CGImageSourceCreateImageAtIndex(self.source, index, nil) else {
            fatalError("Failed to extract GIF frame at index: \(index)")
        }
        
        self.faults[index].image = image
        return image
    }
    
    internal func image(at index: Int, completion: @escaping (CGImage) -> Void) {
        if let image = self.faults[index].image {
            completion(image)
            return
        }
        
        guard let image = CGImageSourceCreateImageAtIndex(self.source, index, nil) else {
            fatalError("Failed to extract GIF frame at index: \(index)")
        }
        
        Decompressor.decompressionQueue.async {
            let decompressedImage = Decompressor.inflate(image)
            
            DispatchQueue.main.async {
                self.faults[index].image = decompressedImage
                completion(decompressedImage)
            }
        }
    }
    
    // MARK: - Properties -
    
    internal func properties(at index: Int) -> Properties {
        return self.faults[index].properties
    }
}

// MARK: - Properties -

extension GIF {
    public struct Properties {
        
        public let loopCount: Int
        public let delayTime: Milliseconds // unclamped delay in milliseconds
        
        // MARK: - Init -
        
        public init(_ dictionary: [String: Any]) {
            self.loopCount = (dictionary[kCGImagePropertyGIFLoopCount as String] as? Int) ?? 0
            
            var delay = dictionary[kCGImagePropertyGIFUnclampedDelayTime as String] as? Double
            if delay == nil {
                delay = dictionary[kCGImagePropertyGIFDelayTime as String] as? Double
            }
            
            if let delay = delay {
                self.delayTime = Milliseconds(fromTimestamp: delay)
            } else {
                self.delayTime = Milliseconds.defaultDelay
            }
        }
    }
}

// MARK: - Errors -

extension GIF {
    public enum Error: Swift.Error {
        case resourceNotFound
        case dataInvalid
        case propertiesInvalid
        case sourceInvalid
    }
}

// MARK: - ImageFault -

extension GIF {
    private struct ImageFault {
        
        let properties: Properties
        var image:      CGImage?
        
        // MARK: - Init -
        
        init(properties: Properties, image: CGImage?) {
            self.properties = properties
            self.image      = image
        }
    }
}
