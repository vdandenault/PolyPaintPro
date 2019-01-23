//
//  socketIO.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-10-08.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation
import SocketIO


let manager = SocketManager(socketURL: URL(string: "https://project3server.herokuapp.com/")!)

protocol SocketMessageDelegate: class {
    func receivedMessage(message: Message)
}

protocol SocketOperationDelegate: class {
    func receivedOperations(operation : OperationSwift)
}

protocol SocketWorkspacesDelegate: class {
    func getWorkspaces(workspaces: [String])
}

protocol SocketChannelsDelegate: class {
    func getChannels(channels: [String])
}

protocol SocketSessionIDDelegate: class {
    func setSessionId(sessionId : String)
}

protocol SocketSaveImageOnSaverDelegate: class {
    func saveImageOnServerFromSocket()
}

protocol SocketShapeContent: class {
    func loadImageContent(shapes: [ShapesSwift])
}

protocol SocketSessionEject {
    func ejectUser()
}

protocol SocketDeleteUser {
    func deleteUser()
}

class Socket: NSObject {
    
    static let shared = Socket()
    
    let maxReadLength = 1024
    var socket: SocketIOClient!
    var socketDelegate: SocketMessageDelegate!
    var socketWorkspacesDelegate: SocketWorkspacesDelegate!
    var socketChannelsDelegate: SocketChannelsDelegate!
    var socketOperationDelegate: SocketOperationDelegate!
    var socketSesssionIdDelegate: SocketSessionIDDelegate!
    var socketSaveImageOnServerFromSocket: SocketSaveImageOnSaverDelegate!
    var socketShapeContent: SocketShapeContent!
    var socketSessionEject: SocketSessionEject!
    var socketDeleteUser: SocketDeleteUser!
    
    //MARK: - Socket Functions
    func start() {
        socket = manager.defaultSocket;
        self.socket.connect();
    }
    
    func chatLogIn() {
        do{
            let data  = LogIn(username: User.shared.username, userId: User.shared.id)
            let jsonData = try JSONEncoder().encode(data)
            self.socket.emit("chatLogIn", with: [jsonData])
        }
        catch{
            print(error.localizedDescription)
        }
    }
    
    func editorLogIn() {
        do{
            let data  = LogIn(username: User.shared.username, userId: User.shared.id)
            let jsonData =  try JSONEncoder().encode(data)
            self.socket.emit("editorLogIn", with: [jsonData] )
        }
        catch{
            print(error.localizedDescription)
        }
    }
    
    func editorJoin(sessionId: String) {
        do{
            let data  = JoinEditor(sessionId: sessionId)
            let jsonData = try JSONEncoder().encode(data)
            self.socket.emit("editorJoin", with: [jsonData]);
        }
        catch{
            print(error.localizedDescription)
        }
    }
    
    func chatJoin(channelName: String) {
        do{
            let data  = JoinLeaveChat(channel: channelName)
            let jsonData = try JSONEncoder().encode(data)
            self.socket.emit("chatJoin", with: [jsonData]);
        }
        catch{
            print(error.localizedDescription)
        }
        
    }
    
    func editorCreate(name: String) {
        do{
            let data = EditorCreate(name: name)
            let jsonData = try JSONEncoder().encode(data)
            self.socket.emit("editorCreate", with: [jsonData])
        }
        catch{
            print(error.localizedDescription)
        }
    }

    func getChannels() {
        self.socket.emit("chatAvailableChannels")
    }
    
    func getWorkspaces() {
        self.socket.emit("editorAvailableSessions")
    }
    
    func leaveChat(channelName: String) {
        do {
            let data  = JoinLeaveChat(channel: channelName)
            let jsonData = try JSONEncoder().encode(data)
            self.socket.emit("chatLeave", with: [jsonData])
        }
        catch {
            print(error.localizedDescription)
        }
    }

//    func chatLogOut() {
//        self.socket.emit("chatLogOut") //chatLogOut
//    }

    func leaveWorkSpace() {
        self.socket.emit("editorLeave")
    }
    
    func setSocketOn() {
        self.socket.on("editorJoin") { data, ack in
            guard let jsonString = data[0] as? String else
            {
                print("Error in response")
                return
            }
            guard let jsonData: Data = jsonString.data(using: .utf8) else {
                print("Error in json" )
                return
            }
            do {
                let sessionId:SessionId = try JSONDecoder().decode(SessionId.self, from: jsonData)
                self.socketSesssionIdDelegate.setSessionId(sessionId: sessionId.sessionId)
            }
            catch{
                print(error.localizedDescription)
            }
        }
        
        self.socket.on("editorSavePng") {data, ack in
            self.socketSaveImageOnServerFromSocket.saveImageOnServerFromSocket()
        }
        
        self.socket.on("chatMessage") {data, ack in
            guard let jsonString = data[0] as? String else
            {
                print("Error in response")
                return
            }
            guard let jsonData: Data = jsonString.data(using: .utf8) else {
                print("Error in json" )
                return
            }
            do {
                let newMessage = try JSONDecoder().decode(MessageIORecieved.self, from: jsonData)
                let message = self.processedMessage(message: newMessage)
                if (message.message != "") {
                    self.socketDelegate?.receivedMessage(message: message)
                }
            }
            catch{
                print(error.localizedDescription)
            }
        }
        self.socket.on("chatAvailableChannels"){data, ack in
            guard let jsonString = data[0] as? String else
            {
                print("Error in response")
                return
            }
            guard let jsonData: Data = jsonString.data(using: .utf8) else {
                print("Error in json" )
                return
            }
            do {
                let jsonArray:Channels = try JSONDecoder().decode(Channels.self, from: jsonData)
                if (!jsonArray.channels.isEmpty) {
                    self.socketChannelsDelegate?.getChannels(channels: jsonArray.channels)
                }
            }
            catch{
                print(error.localizedDescription)
            }
        }
        self.socket.on("editorAvailableSessions"){data, ack in
            guard let jsonString = data[0] as? String else
            {
                print("Error in response")
                return
            }
            guard let jsonData: Data = jsonString.data(using: .utf8) else {
                print("Error in json" )
                return
            }
            do {
                let jsonArray:Workspaces = try JSONDecoder().decode(Workspaces.self, from: jsonData)
                if (!jsonArray.sessions.isEmpty) {
                    self.socketWorkspacesDelegate?.getWorkspaces(workspaces: jsonArray.sessions)
                }
            }
            catch{
                print(error.localizedDescription)
            }
        }
        self.socket.on("editorOperation") {data, ack in
            guard let jsonString = data[0] as? String else
            {
                print("Error in response")
                return
            }
            guard let jsonData: Data = jsonString.data(using: .utf8)
                else {
                    print("Error in json" )
                    return
            }
            do {
                let newOperations = try JSONDecoder().decode(JSONDataStruct.self, from: jsonData)
                let operation = self.processedOperations(jsonDataStruct: newOperations)
                self.socketOperationDelegate?.receivedOperations(operation: operation)
                
            }
            catch{
                print(error.localizedDescription)
            }
        }
        self.socket.on("editorContent") {data, ack in
            guard let jsonString = data[0] as? String else
            {
                print("Error in response")
                return
            }
            
            guard let jsonData: Data = jsonString.data(using: .utf8)
                else {
                    print("Error in json" )
                    return
            }
            do {
                let newShapes = try JSONDecoder().decode(JSONImageContent.self, from: jsonData)
                let shapesSwift = self.processedShapes(jsonImageContent: newShapes)
                self.socketShapeContent?.loadImageContent(shapes: shapesSwift)
                
            }
            catch{
                print(error.localizedDescription)
            }
        }
        self.socket.on("editorSessionEject") {data, ack in
            self.socketSessionEject?.ejectUser()
        }
        self.socket.on("userDeleted") {data, ack in
            self.socketDeleteUser?.deleteUser()
            }
        }
    
    //    func processedShape(shape: ShapesJSONWrapper) -> ShapesJSON {
    //
    //    }
    func processedMessage(message: MessageIORecieved) -> Message {
        let messageSender:MessageSender
        if (message.from == User.shared.username) {
            messageSender = .ourself
        } else {
            messageSender = .other
        }
        return Message(message: message.text, messageSender: messageSender, username: User.shared .username + " [" + message.createdAt + "]", createdAt: message.createdAt, channel: message.channel)
    }
    
    func processedOperations(jsonDataStruct: JSONDataStruct) -> OperationSwift { // a changer pour le type shape
        let operation = jsonDataStruct.operations![0]
        switch operation.type {
        case SELECTSHAPE?, DESELECTSHAPE?, ERASESHAPE?:
            let operation = processedOperation(shapeId: operation.shapeId!, type: operation.type!)
            return operation
        case ADDSHAPE?, MODIFYSHAPE?:
            let shape = operation.shape
            switch shape?.type {
            case ACTOR?:
                let actor = processedActor(shape: operation.shape!)
                let operation = processedOperation(shape : actor, user: operation.user!, type: operation.type!)
                return operation
            case CLASSRECTANGLE?:
                let classRectangle = processedClassRectangle(shape: operation.shape!)
                let operation = processedOperation(shape : classRectangle, user: operation.user!, type: operation.type!)
                return operation
            case ELLIPSE?:
                let ellipse = processedEllipse(shape: operation.shape!)
                let operation = processedOperation(shape : ellipse, user: operation.user!, type: operation.type!)
                return operation
            case RECTANGLE?:
                let rectangle = processedRectangle(shape: operation.shape!)
                let operation = processedOperation(shape: rectangle, user: operation.user!, type: operation.type!)
                return operation
            case TEXTBOX?:
                let textBox = processedTextBox(shape: operation.shape!)
                let operation = processedOperation(shape : textBox, user: operation.user!, type: operation.type!)
                return operation
            case TRIANGLE?:
                let triangle = processedTriangle(shape: operation.shape!)
                let operation = processedOperation(shape: triangle, user: operation.user!, type: operation.type!)
                return operation
            case PICTURE?:
                let picture = processedImage(shape: operation.shape!)
                let operation =  processedOperation(shape: picture, user: operation.user!, type: operation.type!)
                return operation
            default:
                return OperationSwift()
            }
        case RESET?:
            let operation = processedOperation(type: operation.type!)
            return operation
        default:
            return OperationSwift()
        }
    }
    
    func processedShapes(jsonImageContent: JSONImageContent) -> [ShapesSwift] {
        let shapes = jsonImageContent.shapes!
        var shapeSwiftArray:[ShapesSwift] = []
        for shape in shapes {
            switch shape.type {
            case ELLIPSE?:
                let ellipse = processedEllipse(shape: shape)
                shapeSwiftArray.append(ellipse)
                break
            case RECTANGLE?:
                let rectangle = processedRectangle(shape: shape)
                shapeSwiftArray.append(rectangle)
                break
            case TRIANGLE?:
                let triangle = processedTriangle(shape: shape)
                shapeSwiftArray.append(triangle)
                break
            case CLASSRECTANGLE?:
                let classRectangle = processedClassRectangle(shape: shape)
                shapeSwiftArray.append(classRectangle)
                break
            case TEXTBOX?:
                let textBox = processedTextBox(shape: shape)
                shapeSwiftArray.append(textBox)
                break
            case ACTOR?:
                let actor = processedActor(shape: shape)
                shapeSwiftArray.append(actor)
                break
            case PICTURE?:
                let picture = processedPicture(shape: shape)
                shapeSwiftArray.append(picture)
            default:
                break
            }
        }
        return shapeSwiftArray
    }
    
    fileprivate func processedPicture(shape: shape) -> ShapesSwift{
        let position = CGPoint(x:CGFloat((shape.positions?[0].x)!) , y:CGFloat(shape.positions![0].y!))
        let positions : Array<CGPoint> = [position]
        let idValue: String = (shape.id!.value!)
        let id : IdSwift = IdSwift(value: idValue)
        
        let picture = PictureSwift(type: PICTURE, positions: positions, id: id, author: shape.author!, picture: shape.picture!)
        return picture as ShapesSwift
    }
    
    fileprivate func processedActor(shape: shape) -> ShapesSwift{
        let position = CGPoint(x:CGFloat((shape.positions?[0].x)!) , y:CGFloat(shape.positions![0].y!))
        let positions : Array<CGPoint> = [position]
        let idValue: String = (shape.id!.value!)
        let id : IdSwift = IdSwift(value: idValue)
        
        let actor = ActorSwift(type: ACTOR, positions: positions, actorName: shape.actorName!, length: CGFloat(shape.length!), width: CGFloat(shape.width!), id: id, author: shape.author!)
        return actor as ShapesSwift
    }
    
    fileprivate func processedTextBox(shape: shape) -> ShapesSwift{
        let position = CGPoint(x:CGFloat((shape.positions?[0].x)!) , y:CGFloat(shape.positions![0].y!))
        let positions : Array<CGPoint> = [position]
        let idValue: String = (shape.id!.value!)
        let id : IdSwift = IdSwift(value: idValue)
        
        let textBox = TextBoxSwift(type: TEXTBOX, positions: positions, text: shape.text!, length: CGFloat(shape.length!), width: CGFloat(shape.width!), id: id, author: shape.author!)
        return textBox as ShapesSwift
    }
    
    fileprivate func processedClassRectangle(shape: shape) -> ShapesSwift{
        let position1 = CGPoint(x:CGFloat((shape.positions?[0].x)!) , y:CGFloat(shape.positions![0].y!))
        let position2 = CGPoint(x:CGFloat((shape.positions?[1].x)!) , y:CGFloat(shape.positions![1].y!))
        let position3 = CGPoint(x:CGFloat((shape.positions?[2].x)!) , y:CGFloat(shape.positions![2].y!))
        let position4 = CGPoint(x:CGFloat((shape.positions?[3].x)!) , y:CGFloat(shape.positions![3].y!))
        let positions : Array<CGPoint> = [position1,position2,position3,position4]
        let idValue: String = (shape.id!.value!)
        let id : IdSwift = IdSwift(value: idValue)
        let length = CGFloat(abs(positions[1].y - positions[2].y))
        let width = CGFloat(abs(positions[1].x - positions[0].x))
        
        let classRectangle = ClassRectangleSwift(type: CLASSRECTANGLE, positions: positions, className: shape.className!, attributes: shape.attributes!, methods: shape.methods!, length: length, width: width, id: id, author: shape.author!)
        return classRectangle as ShapesSwift
    }
    
    fileprivate func processedEllipse(shape: shape) -> ShapesSwift{
        let position = CGPoint(x:CGFloat((shape.positions?[0].x)!) , y:CGFloat(shape.positions![0].y!))
        let positions : Array<CGPoint> = [position]
        let idValue: String = (shape.id!.value!)
        let id : IdSwift = IdSwift(value: idValue)
        
        let ellipse = EllipseSwift(type: ELLIPSE, positions: positions, length: CGFloat(shape.length!), width: CGFloat(shape.width!), title: shape.title!, id: id, author: shape.author!)
        return ellipse as ShapesSwift
    }

    fileprivate func processedTriangle(shape: shape) -> ShapesSwift{
        let position1 = CGPoint(x:CGFloat((shape.positions?[0].x)!) , y:CGFloat(shape.positions![0].y!))
        let position2 = CGPoint(x:CGFloat((shape.positions?[1].x)!) , y:CGFloat(shape.positions![1].y!))
        let position3 = CGPoint(x:CGFloat((shape.positions?[2].x)!) , y:CGFloat(shape.positions![2].y!))
        let positions : Array<CGPoint> = [position1,position2,position3]
        let idValue: String = (shape.id!.value!)
        let id : IdSwift = IdSwift(value: idValue)
        let width = CGFloat(shape.positions![1].x! - shape.positions![0].x!)
        let length = CGFloat(shape.positions![0].y! - shape.positions![2].y!)
        return TriangleSwift(type: TRIANGLE, positions: positions,length: length, width: width, id: id, author: shape.author!)
    }
    
    fileprivate func processedRectangle(shape: shape) -> ShapesSwift{
        let position1 = CGPoint(x:CGFloat((shape.positions?[0].x)!) , y:CGFloat(shape.positions![0].y!))
        let position2 = CGPoint(x:CGFloat((shape.positions?[1].x)!) , y:CGFloat(shape.positions![1].y!))
        let position3 = CGPoint(x:CGFloat((shape.positions?[2].x)!) , y:CGFloat(shape.positions![2].y!))
        let position4 = CGPoint(x:CGFloat((shape.positions?[3].x)!) , y:CGFloat(shape.positions![3].y!))
        let positions : Array<CGPoint> = [position1,position2,position3,position4]
        let idValue: String = (shape.id!.value!)
        let id : IdSwift = IdSwift(value: idValue)
        let length = CGFloat(positions[1].y-positions[2].y)
        let width = CGFloat(positions[1].x-positions[0].x)
        
        return RectangleSwift(type: RECTANGLE, positions: positions, length: length, width: width, id: id, author: shape.author!)
    }
    
    fileprivate func processedImage(shape: shape) -> ShapesSwift{
        let position1 =  CGPoint(x:CGFloat((shape.positions?[0].x)!) , y:CGFloat(shape.positions![0].y!))
        let positions : Array<CGPoint> = [position1]
        let idValue: String = (shape.id!.value!)
        let id : IdSwift = IdSwift(value: idValue)
        let length = CGFloat(200)
        let width = CGFloat(300)
        let picture = shape.picture
        
        return PictureSwift(type: PICTURE, positions: positions, id: id, author: shape.author!, picture: picture!)
    }
    
    fileprivate func processedOperation(shape: ShapesSwift, user: String, type: String) -> OperationSwift {
        switch type {
        case ADDSHAPE:
            let addShape = AddShapeSwift(shape: shape, user: user, type: type)
            return addShape
        case MODIFYSHAPE:
            let modifyShape = ModifyShapeSwift(shape: shape, type: type)
           return modifyShape
        default:
            break
        }
        return OperationSwift()
    }
    
    fileprivate func processedOperation(type: String) -> OperationSwift {
        switch type {
        case RESET :
            let reset = Reset(type: type)
            let operation = reset as? OperationSwift
            return operation!
        default:
            break
        }
        return OperationSwift()
    }
    
    fileprivate func processedOperation(shapeId: String, type: String) -> OperationSwift {
        switch type {
        case SELECTSHAPE :
            let selectShape = SelectShape(shapeId: shapeId, type: type)
            let operation = selectShape
            return operation
        case DESELECTSHAPE:
            let selectShape = DeselectShape(shapeId: shapeId, type: type)
            let operation = selectShape
            return operation
        case ERASESHAPE:
            let selectShape = EraseShape(shapeId: shapeId, type: type)
            let operation = selectShape
            return operation
            
//        case MODIFYSHAPE:
//            let selectShape = ModifyShapeSwift(shapeId: shapeId, type: type)
//            let operation = selectShape
//            return operation
        default:
            break
        }
        return OperationSwift()
    }
    
    func sendMessage(message: String, channelName: String) ->  Bool {
        if (message != "") {
            if (message.lengthOfBytes(using: .ascii) < maxReadLength) {
                do{
                    let data  = try JSONEncoder().encode(MessageIO(channel: channelName, from: User.shared.username, text: message))
                    self.socket.emit("chatMessage", [data]);
                    return true
                }
                catch{
                    print(error.localizedDescription)
                    return false
                }
            }
            else {
                return false
            }
        }
        return false
    }
    
    func sendOperation(jsonDataStruct:JSONDataStruct)-> Bool {
        do
        {
            let jsonData = try JSONEncoder().encode(jsonDataStruct)
            self.socket.emit("editorOperation", with: [jsonData]);
            return true
        }catch{
            print(error.localizedDescription)
            return false
            
        }
    }
    
    func disconnect() {
        self.socket.disconnect()
    }
}

struct Message {
    let message: String
    let senderUsername: String
    let messageSender: MessageSender
    let createdAt: String
    let channel: String
    
    init(message: String, messageSender: MessageSender, username: String, createdAt: String, channel: String) {
        self.message = message.withoutWhitespace()
        self.messageSender = messageSender
        self.senderUsername = username
        self.createdAt = createdAt
        self.channel = channel
    }
}

enum MessageSender {
    case ourself
    case other
}
