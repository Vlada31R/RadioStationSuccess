//
//  SafeArray.swift
//  RadioOnline
//
//  Created by Sergey Pogrebnyak on 15.11.2018.
//  Copyright © 2018 student. All rights reserved.
//

import Foundation
import UIKit

class SafeArray<T> {
    private var array = [T]()
    private let queue = DispatchQueue(label: "Array queue", attributes: .concurrent)

    public func append(_ value: T) {
        queue.async(flags: .barrier) {
            self.array.append(value)
        }
    }

    public var valueArray: [T] {
        var result = [T]()
        queue.sync {
            result = self.array
        }
        return result
    }

    public func removeAllInArray() {
        self.array.removeAll()
    }
}
