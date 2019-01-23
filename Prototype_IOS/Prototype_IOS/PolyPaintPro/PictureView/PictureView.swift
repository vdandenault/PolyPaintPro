//
//  pictureView.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-11-28.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation
import UIKit

class PictureView: ShapeView {
   
    var image: UIImageView!
    
    override init(frame: CGRect, shape: intmax_t, startingPoint: CGPoint, workspace: Workspace, shapeSwift: ShapesSwift) {
        super.init(frame: frame, shape: shape, startingPoint: startingPoint, workspace: workspace, shapeSwift: shapeSwift)
        let imageFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        image = UIImageView(frame: imageFrame)
        image.contentMode = .scaleAspectFit
        self.addSubview(image)
        
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(PictureView.handdleDrag(_:)))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(PictureView.handdlePinch(_ :)))
        let tapDelete = UITapGestureRecognizer(target: self, action: #selector(PictureView.handdleTapDelete(_:)))
        self.addGestureRecognizer(dragGesture)
        self.addGestureRecognizer(pinch)
        self.addGestureRecognizer(tapDelete)
    }
    
    func setImage(image: UIImage) {
        self.image.image = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
                let shapeToMove = sender.view as! PictureView
                let newPosition: [PositionJSON]
                let shapeSwift = shapeToMove.shapeSwift as! PictureSwift
                newPosition = [PositionJSON(x: float_t((shapeSwift.positions[0].x) + translation.x), y: float_t((shapeSwift.positions[0].y) + translation.y))]
                let shapeJSON: shape = shape(type:shapeSwift.type, positions: newPosition, length: nil, width: nil, title: nil, id: id(value: shapeSwift.shapeId.value), author: shapeSwift.author, className: "", attributes: "", methods: "", text: "", actorName: "", picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""))
                
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

