//
//  Method.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-11-17.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation

class Method {
    var name: String!
    var isClassName: Bool!
    
    init() {
        self.name = ""
    }
    init(name: String, isClassName: Bool) {
        self.name = name
        self.isClassName = isClassName
    }
    func setName(name: String) {
        self.name = name  
    }
}
