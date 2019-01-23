//
//  useCase.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-11-28.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import UIKit

class UseCase: ShapeView, UITextViewDelegate {

    var useCaseTextUIView: UITextView!
    var text: String = "Use Case"
    
    override init(frame: CGRect, shape: intmax_t, startingPoint: CGPoint, workspace: Workspace, shapeSwift: ShapesSwift) {
        super.init(frame: frame, shape: shape, startingPoint: startingPoint, workspace: workspace, shapeSwift: shapeSwift)
        let textFrame = CGRect(x: frame.width/4, y: frame.height/2 - 30 , width: frame.width, height: 30)
        useCaseTextUIView = makeTextView(frame: textFrame)
        useCaseTextUIView.delegate = self
        useCaseTextUIView.isScrollEnabled = false
        self.addSubview(useCaseTextUIView)
        textViewDidChange(useCaseTextUIView)
        
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(UseCase.handdleDrag(_:)))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(UseCase.handdlePinch(_ :)))
        let tapDelete = UITapGestureRecognizer(target: self, action: #selector(UseCase.handdleTapDelete(_:)))
        self.addGestureRecognizer(dragGesture)
        self.addGestureRecognizer(pinch)
        self.addGestureRecognizer(tapDelete)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keybordWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeTextView(frame: CGRect) -> UITextView {
        let textField = UITextView(frame: frame)
        textField.backgroundColor = UIColor.clear
        textField.textAlignment = .left
        textField.textColor = UIColor.black
        textField.text = self.text
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
            useCaseTextUIView.resignFirstResponder()
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
    
    @objc override func handdleDrag(_ sender: UIPanGestureRecognizer) {
        if (selectedStatePolyPaintPro == enumStatePolyPaintPro.cursor) {
            if(User.shared.wifi){
                let translation = sender.translation(in: self)
                let shapeToMove = sender.view as! UseCase
                let newPosition: [PositionJSON]
                let shapeSwift = shapeToMove.shapeSwift as! EllipseSwift
                newPosition = [PositionJSON(x: float_t((shapeSwift.positions[0].x) + translation.x), y: float_t((shapeSwift.positions[0].y) + translation.y))]
                //let textBoxView = sender.view as! UseCase
                let shapeJSON: shape = shape(type:shapeSwift.type, positions: newPosition, length: float_t(shapeSwift.length), width: float_t(shapeSwift.width), title: shapeToMove.useCaseTextUIView.text, id: id(value: shapeSwift.shapeId.value), author: shapeSwift.author, className: "", attributes: "", methods: "", text: "", actorName: "", picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""))
                
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
    
    @objc func keybordWillChange(notification: Notification) {
        if (User.shared.wifi && !User.shared.offLineImage()) {
            guard ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil else {
                return
            }
            self.text = useCaseTextUIView.text!
            let useCaseShapeSwift = shapeSwift as! EllipseSwift
            useCaseShapeSwift.title = self.text
            let shapeJSON = useCaseShapeSwift.toShape()
            let operationJSONSelect: operation = operation(type: SELECTSHAPE, shapeId: (useCaseShapeSwift.shapeId.value))
            let operationModifyJSON: operation = operation(type:MODIFYSHAPE, shape: shapeJSON, user: "")
            let operationJSONDeselect: operation = operation(type: DESELECTSHAPE, shapeId: (useCaseShapeSwift.shapeId.value))
            sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSONSelect]))
            sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationModifyJSON]))
            sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSONDeselect]))
        }
   }
}



