//
//  TextBoxView.swift
//  Prototype_IOS
//
//  Created by Jeremie Miglierina on 18-11-27.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation
import UIKit

class TextBoxView: ShapeView, UITextViewDelegate {
    var textInTextBox: String = "Text"
    var textBoxUIView: UITextView!
    
    
    override init(frame: CGRect, shape: intmax_t, startingPoint: CGPoint, workspace: Workspace, shapeSwift: ShapesSwift) {
        super.init(frame: frame, shape: shape, startingPoint: startingPoint, workspace: workspace, shapeSwift: shapeSwift)
        
        let textFrame = CGRect(x: 20, y: 20, width: frame.width-40 , height: frame.height-40)
        let newtextBoxUIView = makeTextView(frame: textFrame)
        self.textBoxUIView = newtextBoxUIView
        self.addSubview(textBoxUIView)
        
        
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(ActorView.handdleDrag(_:)))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(ActorView.handdlePinch(_ :)))
        let tapDelete = UITapGestureRecognizer(target: self, action: #selector(ActorView.handdleTapDelete(_:)))
        self.addGestureRecognizer(dragGesture)
        self.addGestureRecognizer(pinch)
        self.addGestureRecognizer(tapDelete)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeTextBox(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func keyboardWillChangeTextBox(notification: Notification) {
        if (User.shared.wifi && !User.shared.offLineImage()) {
            guard let keybordRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
            }
            self.textInTextBox = textBoxUIView.text!
            let textBoxShapeSwift = shapeSwift as! TextBoxSwift
            textBoxShapeSwift.text = self.textInTextBox
            
            let shapeJSON = textBoxShapeSwift.toShape()
            let operationModifyJSON: operation = operation(type:MODIFYSHAPE, shape: shapeJSON, user: "")
            let operationJSONSelect: operation = operation(type: SELECTSHAPE, shapeId: (textBoxShapeSwift.shapeId.value))
            let operationJSONDeselect: operation = operation(type: DESELECTSHAPE, shapeId: (textBoxShapeSwift.shapeId.value))
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
        textField.text = self.textInTextBox
        textField.font = UIFont(name: "Helvetica", size: 20)
        textField.allowsEditingTextAttributes = true
        textField.layer.borderWidth = 5
        textField.layer.borderColor = UIColor.black.cgColor
        textField.clearsOnInsertion = true
        textField.delegate = self
        textField.isScrollEnabled = false
        
        return textField
    }
    
    func updateTextView(textView : UITextView){
        
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
    
    private func textFieldDidEndEditing(_ textField: UITextField) {
        // self.actorName = textField.text!
        // //self.actorName = textField.text!
        // let actorShapeSwift = shapeSwift as! ActorSwift
        // let shapeJSON = actorShapeSwift.toShape()
        // let operationModifyJSON: operation = operation(type:MODIFYSHAPE, shape: shapeJSON, user: "")
        // let operationsSelectJSON: operation = operation(type:SELECTSHAPE, shape: shapeJSON, user: "")
        // sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationsSelectJSON]))
        // sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationModifyJSON]))
        
        
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
                let shapeToMove = sender.view as! TextBoxView
                let newPosition: [PositionJSON]
                let shapeSwift = shapeToMove.shapeSwift as! TextBoxSwift
                newPosition = [PositionJSON(x: float_t((shapeSwift.positions[0].x) + translation.x), y: float_t((shapeSwift.positions[0].y) + translation.y))]
                let textBoxView = sender.view as! TextBoxView
                let shapeJSON: shape = shape(type:shapeSwift.type, positions: newPosition, length: float_t(shapeSwift.length), width: float_t(shapeSwift.width), title: nil, id: id(value: shapeSwift.shapeId.value), author: shapeSwift.author, className: "", attributes: "", methods: "", text: shapeToMove.textBoxUIView.text, actorName: "", picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""))
                
                
                
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


