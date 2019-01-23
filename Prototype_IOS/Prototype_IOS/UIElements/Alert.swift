//
//  Alert.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-10-09.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation

import UIKit

// TODO : ADD SOURCE 

class Alert {
    class func showBasic(title: String, message: String, vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(alert, animated: true)
    }
}
