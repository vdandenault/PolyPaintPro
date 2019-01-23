//
//  String+Extension.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-10-09.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation

// TODO : ADD SOURCE

extension String {
    
    var isValidEmail: Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }
    func withoutWhitespace() -> String {
        return self.replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: "\0", with: "")
    }
    func firstSixCaracthers() -> String {
        let indexEndOfText = self.index(self.endIndex, offsetBy: 10)
        return String(self[self.startIndex..<indexEndOfText])
    }
}
