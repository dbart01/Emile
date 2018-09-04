//
//  GridViewController.swift
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

class GridViewController: UIViewController {

    private let collectionView: UICollectionView = {
        let layout                     = UICollectionViewFlowLayout()
        layout.minimumLineSpacing      = 0.0
        layout.minimumInteritemSpacing = 0.0
        
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private let imageNames: [String] = [
        "nailed",
        "tigercub",
        "redsquirrel",
        "canadagoose",
        "doge",
        "earth",
        "cat",
        "cactus",
        "goose",
        "penguin",
    ]
    
    private lazy var gifs: [GIF] = self.imageNames.map { try! GIF(named: $0) }
    
    // MARK: - View Loading -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(AnimatedCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource           = self
        collectionView.delegate             = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor      = .clear
        
        self.view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
        ])
    }
}

// MARK: - UICollectionViewDataSource -

extension GridViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageNames.count * 100
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AnimatedCell
        
        cell.gif = self.gifs[indexPath.item % (self.gifs.count - 1)]
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate -

extension GridViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let gif     = self.gifs[indexPath.item % (self.gifs.count - 1)]
        let details = DetailsViewController(gif: gif)
        
        self.navigationController?.pushViewController(details, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout -

extension GridViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 2
        return CGSize(
            width:  width,
            height: width
        )
    }
}
