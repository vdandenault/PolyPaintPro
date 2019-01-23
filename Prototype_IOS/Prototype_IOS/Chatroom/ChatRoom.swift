/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import SocketIO

var textReceived:String = "";
var otherUserName:String = "";
var createdAtTime:String = "";

//var messageReceived:Message = Message(message: "", messageSender: .someoneElse, username: otherUserName);

protocol ChatRoomDelegate: class {
  func receivedMessage(message: Message)
}

class ChatRoom: NSObject {
    
  weak var delegate: ChatRoomDelegate?
  
  let maxReadLength = 1024
    
    let manager = SocketManager(socketURL: URL(string: "https://project3server.herokuapp.com/")!)
    var socket:SocketIOClient!
    
    func start() {
        socket = manager.defaultSocket;
        self.socket.connect();
    
    }
    
   struct CustomData : SocketData {
    var from: String
    var text: String
    
    func socketRepresentation() -> SocketData {
        return ["from": from, "text": text]
        }
    }
    
  func joinChat(username: String) {
    self.socket.emit("addUser", CustomData(from: "thin-client" , text: userName!));
    }
    
    func setSocketOn() {
        self.socket.on("newMessage") { data, ack in
            print(data);
            if let arr = data as? [[String: Any]] {
                if let txt = arr[0]["from"] as? String {
                    otherUserName = txt;
                }
                else{
                    otherUserName = "DEFAULT USER";
                }
                if let txt = arr[0]["text"] as? String {
                    textReceived = txt;
                }
                else {
                    textReceived = "ERROR";
                }
                if let txt = arr[0]["createdAt"] as? String {
                    createdAtTime = txt;
                }
                else{
                    createdAtTime = "DEFAULT USER";
                }
                print(createdAtTime);
                
            }
            let message = self.processedMessageString(message: textReceived, user: otherUserName, createdAtTime: createdAtTime)
            self.delegate?.receivedMessage(message: message)
        };
       
    }
    
    func processedMessageString(message:String, user:String, createdAtTime: String) -> Message {
        let messageSender:MessageSender = (otherUserName == userName! ? .ourself : .someoneElse )
        return Message(message: (message), messageSender: messageSender, username: user + " [" + createdAtTime + "]", createdAt: createdAtTime)
    }
    
  
  func sendMessage(message: String) {
    if (message != "") {
    if (message.lengthOfBytes(using: .ascii) < maxReadLength) {
        self.socket.emit("createMessage", CustomData(from: userName!, text: message))
    }
    else
        {
            self.socket.emit("createMessage", CustomData(from: userName!, text: "ERROR, MESSAGE TOO LONG"));
        }
      }
    }
    
  func stopChatSession() {
   self.socket.disconnect()
  }
}

