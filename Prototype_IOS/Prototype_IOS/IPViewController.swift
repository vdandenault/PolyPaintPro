//
//  IPViewController.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 18-09-20.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import UIKit
import SocketIO


//let manager = SocketManager(socketURL: URL(string: "https://project3server.herokuapp.com/")!)

class IPViewController: UIViewController {
    
   var IpAdress:String? = "";
   // var socket:SocketIOClient!
    
    var AutoConnectToggleButton:Bool = false;
    
    @IBAction func IpToggle(_ sender: UISwitch) {
        AutoConnectToggleButton = autoConnectToggle.isOn;
        if (!AutoConnectToggleButton)
        {
            ipAdressInputBox.isHidden = false;
        }
        else
        {
            ipAdressInputBox.isHidden = true;
        }
    }
    
    @IBOutlet weak var ipAdressInputBox: UITextField!
    @IBOutlet weak var autoConnectToggle: UISwitch!
    
    
    @IBAction func goToChat(_ sender: Any) {
        if (ipAdressInputBox.text != "")
        {
            IpAdress = ipAdressInputBox.text;
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.socket = manager.defaultSocket;
        //self.socket.connect();
        //self.socket.on("newMessage"){ data, ack in
           // print(data);
        //};
        ipAdressInputBox.isHidden = true;
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
}

