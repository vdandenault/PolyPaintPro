//
//  PositionJSON.swift
//  Prototype_IOS
//
//  Created by Jeremie Miglierina on 18-11-11.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation

import SocketIO
import UIKit

struct PositionJSON: Codable, SocketData{
    var x : float_t?
    var y : float_t?
    
}
