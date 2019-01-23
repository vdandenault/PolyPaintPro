//
//  ClassView.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-11-17.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation
import UIKit

class ClassView: ShapeView {
    
    var methods: [Method] = []
    var className: String!
    
    
    var methodsTable: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    override init(frame: CGRect, shape: intmax_t, startingPoint: CGPoint, workspace: Workspace, shapeSwift: ShapesSwift) {
        super.init(frame: frame, shape: shape, startingPoint: startingPoint, workspace: workspace, shapeSwift: shapeSwift)
        
        
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.red
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(ClassView.handdleDrag(_:)))
        self.addGestureRecognizer(dragGesture)
        let tapDelete = UITapGestureRecognizer(target: self, action: #selector(ClassView.handdleTapDelete(_:)))
        self.addGestureRecognizer(tapDelete)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(ClassView.handdlePinch(_ :)))
        self.addGestureRecognizer(pinch)
        let methodFrame = CGRect(x: 10, y: 10, width: self.frame.width - 20, height: self.frame.height - 20)
        
        methodsTable.delegate = self
        methodsTable.dataSource = self
        methodsTable.frame = methodFrame
        methodsTable.register(ClassCell.self, forCellReuseIdentifier: "classCell")
        self.addSubview(methodsTable)
        setAnchorPointsClass(width: frame.width, length: frame.height)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setClassName(className: String) {
        self.className = className
        let classNameMethod = Method(name: self.className, isClassName: true)
        methods.append(classNameMethod)
        self.setUpMethodArray()
        methodsTable.reloadData()
        methodsTable.scrollsToTop = true
    }
    
    func setUpMethodArray() {
        var className = Method.init(name: "Attributs", isClassName: false)
        methods.append(className)
        className = Method.init(name: "Methodes", isClassName: false)
        methods.append(className)
        //        for _ in 1...2 {
        //            let className = Method.init(name: "Attributs", isClassName: false)
        //            methods.append(className)
        
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        if (User.shared.wifi && !User.shared.offLineImage()) {
            guard let keybordRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
            }
            
            var indexPath = NSIndexPath(row: 0, section: 0)
            let cellClassName = methodsTable.cellForRow(at: indexPath as IndexPath) as! ClassCell
            indexPath = NSIndexPath(row: 1, section: 0)
            let cellAttributs = methodsTable.cellForRow(at: indexPath as IndexPath) as! ClassCell
            indexPath = NSIndexPath(row: 2, section: 0)
            let cellMethode = methodsTable.cellForRow(at: indexPath as IndexPath) as! ClassCell
            
            
            
            let classRectangleShapeSwift = shapeSwift as! ClassRectangleSwift
            
            classRectangleShapeSwift.className = cellClassName.textField.text
            classRectangleShapeSwift.attributes = cellAttributs.textField.text
            classRectangleShapeSwift.methods = cellMethode.textField.text
            
            
            let shapeJSON = classRectangleShapeSwift.toShape()
            let operationModifyJSON: operation = operation(type:MODIFYSHAPE, shape: shapeJSON, user: "")
            let operationJSONSelect: operation = operation(type: SELECTSHAPE, shapeId: (classRectangleShapeSwift.shapeId.value))
            let operationJSONDeselect: operation = operation(type: DESELECTSHAPE, shapeId: (classRectangleShapeSwift.shapeId.value))
            sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSONSelect]))
            sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationModifyJSON]))
            sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSONDeselect]))
        }
    }
    
    
    @objc override func handdleDrag(_ sender: UIPanGestureRecognizer) {
        if (selectedStatePolyPaintPro == enumStatePolyPaintPro.cursor) {
            if(User.shared.wifi){
                let translation = sender.translation(in: self)
                let shapeToMove = sender.view as! ClassView
                let newPosition: [PositionJSON]
                let shapeSwift = shapeToMove.shapeSwift as! ClassRectangleSwift
                newPosition = [PositionJSON(x: float_t((shapeSwift.positions[0].x) + translation.x), y: float_t((shapeSwift.positions[0].y) + translation.y)),
                               PositionJSON(x: float_t((shapeSwift.positions[1].x) + translation.x), y: float_t((shapeSwift.positions[1].y) + translation.y)),
                               PositionJSON(x: float_t((shapeSwift.positions[2].x) + translation.x), y: float_t((shapeSwift.positions[2].y) + translation.y)),
                               PositionJSON(x: float_t((shapeSwift.positions[3].x) + translation.x), y: float_t((shapeSwift.positions[3].y) + translation.y))]
                let shapeJSON: shape = shape(type:shapeSwift.type, positions: newPosition, length: float_t(shapeSwift.length), width: float_t(shapeSwift.width), title: nil, id: id(value: shapeSwift.shapeId.value), author: shapeSwift.author, className: shapeSwift.className, attributes: shapeSwift.attributes, methods: shapeSwift.methods, text: "", actorName: "", picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""))
                
                
                
                let operationJSONModify: operation = operation(type: MODIFYSHAPE, shape: shapeJSON, user: User.shared.name)
                
                
                let operationJSONSelect: operation = operation(type: SELECTSHAPE, shapeId: (shapeJSON.id?.value)!)
                let operationJSONDeselect: operation = operation(type: DESELECTSHAPE, shapeId: (shapeJSON.id?.value)!)
                if(sender.state == UIGestureRecognizerState.began){
                    sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSONSelect]))
                }
                self.moveCounter = moveCounter + 1
                if(moveCounter == 7){
                    sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSONModify]))
                    moveCounter = 0
                }
                if(sender.state == UIGestureRecognizerState.ended){
                    sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSONDeselect]))
                }
            }
            else {
                let translation = sender.translation(in: self)
                sender.view?.center = CGPoint(x: (sender.view?.center.x)! + translation.x, y: (sender.view?.center.y)! + translation.y)
                sender.setTranslation(CGPoint.zero, in: sender.view)
            }
        }
    }
}
func handdleTapDelete(_ sender: UITapGestureRecognizer) {
    if (selectedStatePolyPaintPro == enumStatePolyPaintPro.erase) {
        
        sender.view!.removeFromSuperview()
    }
}


extension ClassView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return methods.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let method = methods[indexPath.row]
        let cell = methodsTable.dequeueReusableCell(withIdentifier: "classCell") as! ClassCell
        cell.setCell(method: method)
        if (method.isClassName) {
            cell.setClassAsClassName()
        }
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete && !User.shared.wifi) {
            methods.remove(at: indexPath.row)
            methodsTable.beginUpdates()
            methodsTable.deleteRows(at: [indexPath], with: .automatic)
            methodsTable.endUpdates()
        }
    }
}

extension ClassView {
    @objc override func handdlePinch(_ sender: UIPinchGestureRecognizer) {
        self.superview!.bringSubview(toFront: self)
        let scale = sender.scale
        self.transform = CGAffineTransform.init(scaleX: scale, y: scale)
    }
}

extension ClassView {
    func setAnchorPointsClass(width: CGFloat, length: CGFloat) {
        var frame = CGRect(x: (width * 0.5) - ANCHORPOINTSIZE * 0.5, y: 0 - ANCHORPOINTSIZE/2, width: ANCHORPOINTSIZE, height: ANCHORPOINTSIZE)
        let anchorPoint = AnchorPoint(frame: frame, anchorPointAttachedTo: self)
        anchorPoints.append(anchorPoint)
        self.addSubview(anchorPoint)
        
        frame = CGRect(x: (width * 0.5) - ANCHORPOINTSIZE * 0.5, y: length - ANCHORPOINTSIZE/2, width: ANCHORPOINTSIZE, height: ANCHORPOINTSIZE)
        let anchorPoint2 = AnchorPoint(frame: frame, anchorPointAttachedTo: self)
        anchorPoints.append(anchorPoint2)
        self.addSubview(anchorPoint2)
        
        frame = CGRect(x: 0 - ANCHORPOINTSIZE * 0.5, y: (length * 0.5) - ANCHORPOINTSIZE * 0.5 , width: ANCHORPOINTSIZE, height: ANCHORPOINTSIZE)
        let anchorPoint3 = AnchorPoint(frame: frame, anchorPointAttachedTo: self)
        anchorPoints.append(anchorPoint3)
        self.addSubview(anchorPoint3)
        
        frame = CGRect(x: width - ANCHORPOINTSIZE * 0.5, y: (length * 0.5) - ANCHORPOINTSIZE * 0.5, width: ANCHORPOINTSIZE, height: ANCHORPOINTSIZE)
        let anchorPoint4 = AnchorPoint(frame: frame, anchorPointAttachedTo: self)
        anchorPoints.append(anchorPoint4)
        self.addSubview(anchorPoint4)
    }
}
