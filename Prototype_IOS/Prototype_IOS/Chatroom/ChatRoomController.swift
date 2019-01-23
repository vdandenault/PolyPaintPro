//
//  ChatRoomController.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-10-12.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import UIKit
import UserNotifications

//MARK: Class ChatRoomController
class ChatRoomController: UIViewController {
    
    var channels: [Channel] = []
    let blackView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Socket.shared.socketChannelsDelegate = self
        channelsTable.delegate = self
        channelsTable.dataSource = self
        newChannelView.isHidden = true
        self.getChannels()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keybordWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keybordWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keybordWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - UI variables
    @IBOutlet weak var newChannelView: UIView!
    @IBOutlet weak var addNewChannelButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var newChannelTextField: UITextField!
    @IBOutlet weak var channelsTable: UITableView!
    
    @IBAction func adddNewChannelTapped(_ sender: Any) {
        self.blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.view.addSubview(blackView)
        self.blackView.frame = self.view.frame
        self.blackView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.blackView.alpha = 1
            self.view.addSubview(self.newChannelView)
            self.newChannelView.isHidden = false
        })
    }
    
    @IBAction func goButtonTapped(_ sender: Any) {
            if (!(newChannelTextField.text?.isEmpty)!) {
                let channelname = newChannelTextField.text!
                newChannelTextField.text = ""
                let channel:Channel = Channel(channelName: channelname)
                UIView.animate(withDuration: 0.5) {
                    self.newChannelView.isHidden = true
                    self.blackView.alpha = 0
                }
                self.channelsTable.reloadData()
                performSegue(withIdentifier: "toChat", sender: channel)
            }
            else {
                Alert.showBasic(title: "Empty Name", message: "Please enter a name", vc: self)
            }
        }
    

    @IBAction func exitTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.5) {
            self.newChannelView.isHidden = true
            self.blackView.alpha = 0
        }
        newChannelTextField.text = ""
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChat" {
            if let chatRoomVC = segue.destination as? ChatRoomViewController {
                if let channel = sender as? Channel {
                    chatRoomVC.channel = channel
                    if (channel.channelName != "Global") {
                        channel.joinchat()
                    }
                }
            }
        }
    }
    
    @IBAction func homeTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "toHomeFCR", sender: self)
    }
    
    func getChannels() {
        Socket.shared.getChannels()
    }
    
    @objc func keybordWillChange(notification: Notification) {
        guard let keybordRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        if (notification.name == Notification.Name.UIKeyboardWillShow || notification.name == Notification.Name.UIKeyboardWillChangeFrame) {
            view.frame.origin.y = -keybordRect.height
        }
        else {
            view.frame.origin.y = 0
        }
    }
}

// MARK: - Extension

extension ChatRoomController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let channel = channels[indexPath.row]
        let cell = channelsTable.dequeueReusableCell(withIdentifier: "channelCell") as! channelCell
        cell.setChannel(channel: channel)
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            channels.remove(at: indexPath.row)
            channelsTable.beginUpdates()
            channelsTable.deleteRows(at: [indexPath], with: .automatic)
            channelsTable.endUpdates()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = channels[indexPath.row]
        performSegue(withIdentifier: "toChat", sender: channel)
    }
}

extension ChatRoomController: SocketChannelsDelegate {
    func getChannels(channels: [String]) {
        var Channels: [Channel] = []
        for string in channels {
            let channel = Channel(channelName: string)
            Channels.append(channel)
        }
        self.channels = Channels
        self.channelsTable.reloadData()
    }
}



