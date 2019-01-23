//
//  Stack.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-11-16.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation

struct Stack<Element> {
    fileprivate var array: [Element] = []
    
    mutating func push(_ element: Element) {
        array.append(element)
    }
    
    mutating func pop() -> Element? {
        return array.popLast()
    }
    
    func peek() -> Element? {
        guard array.last != nil else {
            fatalError("This stack is empty.")
        }
        return array.last
    }
    mutating func clear() {
        array.removeAll()
    }
    
    var description: String {
        let topDivider = "---Stack---\n"
        let bottomDivider = "\n-----------\n"
        let stackElements = array.map { "\($0)" }.reversed().joined(separator: "\n")
        return topDivider + stackElements + bottomDivider
    }
    
    var isEmpty: Bool {
        return array.isEmpty
    }
    
    var count: Int {
        return array.count
    }
}
