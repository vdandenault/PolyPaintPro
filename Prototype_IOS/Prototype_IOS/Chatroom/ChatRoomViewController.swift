//
//  ChatRoomViewController.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 18-09-20.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//



import UIKit

class ChatRoomViewController: UIViewController {
    let tableView = UITableView()
    let messageInputBar = MessageInputView()
    
    let chatRoom = ChatRoom()
    
    var messages = [Message]()
    
    var username = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        chatRoom.delegate = self
        chatRoom.setupNetworkCommunication()
        chatRoom.joinChat(username: username)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        chatRoom.stopChatSession()
    }
}

//MARK - Message Input Bar
extension ChatRoomViewController: MessageInputDelegate {
    func sendWasTapped(message: String) {
        chatRoom.sendMessage(message: message)
    }
}

//MARK - Chat Room
extension ChatRoomViewController: ChatRoomDelegate {
    func receivedMessage(message: Message) {
        insertNewMessageCell(message)
    }
}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


