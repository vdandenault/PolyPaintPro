//
//  LogInView.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-10-04.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import UIKit

class LogInView: UIViewController {
    
    //MARK: Structures
   

    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func noWifiTapped(_ sender: Any) {
        User.shared.setWifi(wifi: false)
        performSegue(withIdentifier: "toPolyPaintProFLS", sender: self)
        User.shared.localShapes = []
//        User.shared.localPictures = []
//        User.shared.localTexts = []
//        User.shared.localActor = []
//        User.shared.localClassD = []
    }
}

