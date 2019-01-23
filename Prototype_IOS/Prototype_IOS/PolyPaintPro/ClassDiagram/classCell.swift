//
//  classCell.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-11-17.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation
import UIKit

class ClassCell: UITableViewCell, UITextViewDelegate {
    var method: Method!
    var textField: UITextView!
    var isClassName: Bool!
    
    
    func setCell(method: Method) {
        self.backgroundColor = UIColor.white
        self.method = method
         self.isClassName = method.isClassName
        textField = makeTextView(frame: self.frame)
        self.addSubview(textField)
    }
    
    func makeTextView(frame: CGRect) -> UITextView {
        let textField = UITextView(frame: frame)
        textField.backgroundColor = UIColor.clear
        textField.textAlignment = .left
        textField.textColor = UIColor.black
        textField.text = method.name
        textField.font = UIFont(name: "Helvetica", size: 20)
        textField.allowsEditingTextAttributes = true
        textField.clearsOnInsertion = true
        textField.delegate = self
        textField.isScrollEnabled = false
        
        return textField
    }
    
    func setClassAsClassName() {
        if (isClassName) {
            textField.font = UIFont(name: "Helvetica", size: 32)
            textField.textAlignment = .left
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    private func textFieldDidEndEditing(_ textField: UITextField) {
        method.setName(name: textField.text!)
    }
}
