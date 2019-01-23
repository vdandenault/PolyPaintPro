//
//  DataExtension.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-11-06.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation

extension Data {
    func toString() -> String {
        return String(data:self, encoding: .utf8)!
    }
}
