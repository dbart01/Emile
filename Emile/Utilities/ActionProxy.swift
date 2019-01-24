//
//  ActionProxy.swift
//  Emile
//
//  Created by Dima Bart on 2018-09-06.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

internal class ActionProxy: NSObject {
    
    internal var block: (() -> Void)?
    
    internal let selector = #selector(action)
    
    // MARK: - Action -
    
    @objc private func action() {
        self.block?()
    }
}
