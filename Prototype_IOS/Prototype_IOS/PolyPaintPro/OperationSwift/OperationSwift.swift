//
//  OperationSwift.swift
//  Prototype_IOS
//
//  Created by Jeremie Miglierina on 18-11-15.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation
import UIKit
import SocketIO

class OperationSwift {
    var type : String
    
    init(type: String){
        self.type = type
    }
    
    init(){
        self.type = "Error type"
    }
}

