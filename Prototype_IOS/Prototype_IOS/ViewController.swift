//
//  ViewController.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 18-09-20.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import UIKit

var userName:String?;

class ViewController: UIViewController {
    
    @IBOutlet weak var userNameTextBox: UITextField!
    
    @IBAction func registerButton(_ sender: Any) {
        if (!(userNameTextBox.text?.isEmpty)!)
        {
            userName = userNameTextBox.text;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

