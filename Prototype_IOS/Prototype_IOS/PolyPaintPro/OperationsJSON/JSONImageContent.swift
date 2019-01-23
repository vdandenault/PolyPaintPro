//
//  JSONImageContent.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-11-23.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation

struct JSONImageContent: Codable {
    var shapes : Array<shape>?
    var zoom: Double?
    var id: String?
}
