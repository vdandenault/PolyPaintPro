//
//  UserCaseDiagram.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-11-17.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation
import UIKit

class ActorView: ShapeView, UITextViewDelegate {
    var actorName: String = "Actor"
    var actorNameTextUIView: UITextView!
    var actorImage: UIImageView!
    
    override init(frame: CGRect, shape: intmax_t, startingPoint: CGPoint, workspace: Workspace, shapeSwift: ShapesSwift) {
        super.init(frame: frame, shape: shape, startingPoint: startingPoint, workspace: workspace, shapeSwift: shapeSwift)
        let imageFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height - 40)
        actorImage = UIImageView(frame: imageFrame)
        actorImage.image = #imageLiteral(resourceName: "actor")
        actorImage.contentMode = .scaleAspectFit
        let textFrame = CGRect(x: 0, y: frame.height - 40, width: frame.width, height: 40)
        actorNameTextUIView = makeTextView(frame: textFrame)
        self.addSubview(actorImage)
        self.addSubview(actorNameTextUIView)
        
        actorNameTextUIView.translatesAutoresizingMaskIntoConstraints = false
        [ actorNameTextUIView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
          actorNameTextUIView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
          actorNameTextUIView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
          actorNameTextUIView.heightAnchor.constraint(equalToConstant: 50)].forEach{$0.isActive = true }
        
        actorNameTextUIView.delegate = self
        actorNameTextUIView.isScrollEnabled = false
        textViewDidChange(actorNameTextUIView)
        
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(ActorView.handdleDrag(_:)))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(ActorView.handdlePinch(_ :)))
        let tapDelete = UITapGestureRecognizer(target: self, action: #selector(ActorView.handdleTapDelete(_:)))
        self.addGestureRecognizer(dragGesture)
        self.addGestureRecognizer(pinch)
        self.addGestureRecognizer(tapDelete)
        setAnchorPointsActor(width: frame.width, length: frame.height)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keybordWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keybordWillChange(notification: Notification) {
        
        if (User.shared.wifi && !User.shared.offLineImage()) {
        guard let keybordRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
            self.actorName = actorNameTextUIView.text!
            let actorShapeSwift = shapeSwift as! ActorSwift
            actorShapeSwift.actorName = self.actorName
        
            let shapeJSON = actorShapeSwift.toShape()
            let operationModifyJSON: operation = operation(type:MODIFYSHAPE, shape: shapeJSON, user: "")
            let operationJSONSelect: operation = operation(type: SELECTSHAPE, shapeId: (actorShapeSwift.shapeId.value))
            let operationJSONDeselect: operation = operation(type: DESELECTSHAPE, shapeId: (actorShapeSwift.shapeId.value))
            sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSONSelect]))
            sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationModifyJSON]))
            sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSONDeselect]))
        }
    }


    func makeTextView(frame: CGRect) -> UITextView {
        let textField = UITextView(frame: frame)
        textField.backgroundColor = UIColor.clear
        textField.textAlignment = .left
        textField.textColor = UIColor.black
        textField.text = self.actorName
        textField.font = UIFont(name: "Helvetica", size: 20)
        textField.allowsEditingTextAttributes = true
        textField.clearsOnInsertion = true
        textField.delegate = self
        textField.isScrollEnabled = false
        
        return textField
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
            actorNameTextUIView.resignFirstResponder()
            return false
        }
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: self.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.constraints.forEach { (constraint) in
            if (constraint.firstAttribute == .height) {
                constraint.constant = estimatedSize.height
            }
            
        }
    }
    
    override func sendOperations(jsonDataStruct: JSONDataStruct) {
        let sent: Bool  = self.workspace.sendOperations(jsonDataStruct: jsonDataStruct)
        if (!sent) {
            print("Error in sent operation")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (selectedStatePolyPaintPro == enumStatePolyPaintPro.erase) {
            if (User.shared.wifi) {
                let view = touches.first?.view as! ShapeView
                let shapeId = view.shapeSwift.shapeId.value
                let type = SELECTSHAPE
                let operationJSONSelect: operation = operation(type: type, shapeId: shapeId)
                let operationJSONErase: operation = operation(type: ERASESHAPE, shapeId: shapeId)
                sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSONSelect]))
                sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSONErase]))
            }
            else {
                touches.first?.view?.removeFromSuperview()
            }
        }
    }
    
    @objc override func handdleDrag(_ sender: UIPanGestureRecognizer) {
        if (selectedStatePolyPaintPro == enumStatePolyPaintPro.cursor) {
            if(User.shared.wifi){
                let translation = sender.translation(in: self)
                let shapeToMove = sender.view as! ActorView
                let newPosition: [PositionJSON]
                let shapeSwift = shapeToMove.shapeSwift as! ActorSwift
                newPosition = [PositionJSON(x: float_t((shapeSwift.positions[0].x) + translation.x), y: float_t((shapeSwift.positions[0].y) + translation.y))]
                let actorView = sender.view as! ActorView
                let shapeJSON: shape = shape(type:shapeSwift.type, positions: newPosition, length: float_t(shapeSwift.length), width: float_t(shapeSwift.width), title: nil, id: id(value: shapeSwift.shapeId.value), author: shapeSwift.author, className: "", attributes: "", methods: "", text: "", actorName: actorView.actorNameTextUIView.text, picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""))
                
                
                
                let operationJSONModify: operation = operation(type: MODIFYSHAPE, shape: shapeJSON, user: User.shared.name)
                
                
                let operationJSONSelect: operation = operation(type: SELECTSHAPE, shapeId: (shapeJSON.id?.value)!)
                let operationJSONDeselect: operation = operation(type: DESELECTSHAPE, shapeId: (shapeJSON.id?.value)!)
                if(sender.state == UIGestureRecognizerState.began){
                    //selectedShape = shapeToMove
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
    @objc override func handdlePinch(_ sender: UIPinchGestureRecognizer) {
        if (selectedStatePolyPaintPro == enumStatePolyPaintPro.cursor) {
            self.superview!.bringSubview(toFront: self)
            let scale = sender.scale
            self.transform = CGAffineTransform.init(scaleX: scale, y: scale)
        }
    }
    @objc override func handdleTapDelete(_ sender: UITapGestureRecognizer) {
        if (selectedStatePolyPaintPro == enumStatePolyPaintPro.erase) {
            if (User.shared.wifi) {
                let view = sender.view as! ShapeView
                let shapeId = view.shapeSwift.shapeId.value
                let type = SELECTSHAPE
                let operationJSONSelect: operation = operation(type: type, shapeId: shapeId)
                let operationJSONErase: operation = operation(type: ERASESHAPE, shapeId: shapeId)
                sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSONSelect]))
                sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSONErase]))
            }
            else {
                sender.view!.removeFromSuperview()
            }
        }
        
    }
}

extension ActorView {
    func setAnchorPointsActor(width: CGFloat, length: CGFloat) {

        
        var frame = CGRect(x: 0 - ANCHORPOINTSIZE/2 , y: (length * 0.5) - ANCHORPOINTSIZE * 0.5 , width: ANCHORPOINTSIZE, height: ANCHORPOINTSIZE)
        let anchorPoint3 = AnchorPoint(frame: frame, anchorPointAttachedTo: self)
        anchorPoints.append(anchorPoint3)
        self.addSubview(anchorPoint3)
        
        frame = CGRect(x: width - ANCHORPOINTSIZE/2, y: (length * 0.5) - ANCHORPOINTSIZE * 0.5, width: ANCHORPOINTSIZE, height: ANCHORPOINTSIZE)
        let anchorPoint4 = AnchorPoint(frame: frame, anchorPointAttachedTo: self)
        anchorPoints.append(anchorPoint4)
        self.addSubview(anchorPoint4)
    }
}



