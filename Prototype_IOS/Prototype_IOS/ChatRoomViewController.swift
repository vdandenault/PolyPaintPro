import UIKit
import NotificationCenter





//MARK: - ChatRoomViewController
class ChatRoomViewController: UIViewController {
    
    let tableView = UITableView()
    let messageInputBar = MessageInputView()
    var messages = [Message]()
    var channel:Channel!
    var once:Bool = false
    var twice:Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        Socket.shared.socketDelegate = self;
        
        NotificationCenter.default.addObserver(self, selector: #selector(keybordWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keybordWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keybordWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if(channel.channelName != "Global") {
            channel.leaveChat()
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
//MARK - Message Input Bar
extension ChatRoomViewController: MessageInputDelegate {
    func sendWasTapped(message: String) {
        let sent:Bool = self.channel.sendMessage(message: message)
        if (!sent) {
            Alert.showBasic(title: "Error", message: "Message did not sent", vc: self)
        }
    }
}

//MARK - ChatRoom
extension ChatRoomViewController: SocketMessageDelegate {
    func receivedMessage(message: Message) {
        if (message.channel == self.channel.channelName) {
            insertNewMessageCell(message)
        }
        else {
            NotificationBanner.show("New Message")
        }
    }
}
