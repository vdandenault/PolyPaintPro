//
//  ShapeView.swift
//  Prototype_IOS
//
//  Created by Jeremie Miglierina on 18-10-24.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import UIKit

class ShapeView: UIView {
    
    var startingPoint:CGPoint!
    var currentShapeType: Int = 0
    var initialWidth: CGFloat!
    var initialHeight: CGFloat!
    var anchorPoints:[AnchorPoint] = []
    var shapeSwift: ShapesSwift!
    var workspace: Workspace
    var isFirstTimeForSelect = true
    var moveCounter: float_t = 0
    var lastRotation: CGFloat = 0
    
    init(frame: CGRect, shape: Int, startingPoint:CGPoint, workspace: Workspace, shapeSwift: ShapesSwift) {
        self.workspace = workspace
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.currentShapeType = shape
        self.startingPoint = startingPoint
        self.shapeSwift = shapeSwift
        self.isUserInteractionEnabled = true
        self.initialWidth = self.frame.width
        self.initialHeight = self.frame.height
        self.setGestures()
    }
    
     init(workspace: Workspace){
        
        
        
        self.workspace = workspace
        super.init(frame: CGRect())
        self.backgroundColor = UIColor.clear
        self.currentShapeType = 10
        self.startingPoint = CGPoint()
        self.shapeSwift = ShapesSwift()
        self.isUserInteractionEnabled = true
        self.initialWidth = self.frame.width
        self.initialHeight = self.frame.height
        self.setGestures()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        switch currentShapeType {
        case 0: drawRectangle()
        case 1: drawTriangle()
        case 2: drawCircle()
        case 3: drawLine()
        case 4: drawArrow()
        case 5: drawTriangleUpSideDown()
        default: print("default")
        }
    }
    
    func setGestures() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ShapeView.handdleLongPress(_:)))
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(ShapeView.handdleDrag(_:)))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(ShapeView.handdleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(ShapeView.handdlePinch(_ :)))
        let tapDelete = UITapGestureRecognizer(target: self, action: #selector(ShapeView.handdleTapDelete(_:)))
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(ShapeView.rotatedView(_:)))
        self.addGestureRecognizer(rotate)
        self.addGestureRecognizer(tapDelete)
        self.addGestureRecognizer(pinchGR)
        self.addGestureRecognizer(doubleTap)
        self.addGestureRecognizer(longPress)
        self.addGestureRecognizer(dragGesture)
    }
    
    func sendOperations(jsonDataStruct: JSONDataStruct) {
        let sent: Bool  = self.workspace.sendOperations(jsonDataStruct: jsonDataStruct)
        if (!sent) {
            print("Error in sent operation")
        }
    }
    
    func drawTriangle() {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.beginPath()
        ctx.move(to: CGPoint(x: frame.size.width/2, y: 5))
        ctx.addLine(to: CGPoint(x: frame.size.width - 5, y: frame.size.height - 5 ))
        ctx.addLine(to: CGPoint(x:  5, y: frame.size.height - 5))
        ctx.setLineWidth(5)
        ctx.closePath()
        ctx.strokePath()
        setAnchorPointsTriangle(width: frame.size.width, length: frame.size.height)
    }
    
    func drawTriangleUpSideDown() {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.beginPath()
        ctx.move(to: CGPoint(x: frame.size.width/2, y:  frame.size.height - 5))
        ctx.addLine(to: CGPoint(x: frame.size.width - 5, y:  5 ))
        ctx.addLine(to: CGPoint(x:  5, y:  5))
        ctx.setLineWidth(5)
        ctx.closePath()
        ctx.strokePath()
        setAnchorPointsTriangle(width: frame.size.width, length: frame.size.height)
    }
    
    func drawRectangle() {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        //4
        ctx.addRect(CGRect(x: 5, y: 5, width: frame.size.width - 10, height: frame.size.height - 10))
        ctx.setLineWidth(5)
        ctx.setStrokeColor(UIColor.black.cgColor)
        ctx.strokePath()
        setAnchorPointsRectangle(width: frame.size.width, length: frame.size.height)
    }
    
    func drawCircle() {
        let center = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0);
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.beginPath()
        ctx.setStrokeColor(UIColor.black.cgColor)
        let rectangle = CGRect(x: 5, y: 5, width: self.frame.width-10, height: self.frame.height-10)
        ctx.setLineWidth(5)
        rectangle.insetBy(dx: -10, dy: -10)
        ctx.addEllipse(in: rectangle)
        ctx.strokePath()
        setAnchorPointsCircle(center: center)
    }
    
    func drawLine(){
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        ctx.beginPath()
        ctx.move(to: CGPoint(x: 5, y: 35))
        ctx.addLine(to: CGPoint(x: 145, y: 35))
        ctx.setLineWidth(5)
        ctx.strokePath()
        
    }
    func drawArrow(){
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.beginPath()
        ctx.move(to: CGPoint(x: 5, y: (self.frame.height - 10)/2 ))
        ctx.addLine(to: CGPoint(x: self.frame.width - 10, y: (self.frame.height - 10)/2))
        ctx.move(to: CGPoint(x: self.frame.width - 10, y: (self.frame.height - 10)/2))
        ctx.addLine(to: CGPoint(x: self.frame.width - 30 , y: ((self.frame.height - 10)/2 + 15)))
        ctx.move(to: CGPoint(x: self.frame.width - 10, y: (self.frame.height - 10)/2))
        ctx.addLine(to: CGPoint(x: self.frame.width - 30 , y: ((self.frame.height - 10)/2 - 15)))
        ctx.setLineWidth(5)
        ctx.strokePath()
    }
}
extension ShapeView {
    //HANDDLERS
    func removeGestures() {
        for gesture in self.gestureRecognizers! {
            gesture.isEnabled = false
        }
    }
    
    
    //SELECTION
    @objc func handdleLongPress(_ sender: UILongPressGestureRecognizer) {
        if (selectedStatePolyPaintPro == enumStatePolyPaintPro.cursor && !isSelectedShape) {
            if (User.shared.wifi) {
                let view = sender.view as! ShapeView
                let shapeId = view.shapeSwift.shapeId.value
                let type = SELECTSHAPE
                let operationJSON: operation = operation(type: type, shapeId: shapeId)
                sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSON]))
            }
            else {
                isSelectedShape = true
                selectedShape = self
                sender.view?.backgroundColor = UIColor.lightGray
                
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        startingPoint = touch?.location(in: self )
        
        if (selectedStatePolyPaintPro == enumStatePolyPaintPro.erase) {
            if (User.shared.wifi) {
                if(!lassoArrayCollab.isEmpty){
                    for shapeLasso in lassoArrayCollab{
                        let shapeId = shapeLasso.shapeSwift.shapeId.value
                        let type = SELECTSHAPE
                        let operationJSONSelect: operation = operation(type: type, shapeId: shapeId)
                        let operationJSONErase: operation = operation(type: ERASESHAPE, shapeId: shapeId)
                        sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSONSelect]))
                        sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSONErase]))
                    }
                    lassoArrayCollab = []
                }
                else{
                    let view = touches.first?.view as! ShapeView
                    let shapeId = view.shapeSwift.shapeId.value
                    let type = SELECTSHAPE
                    let operationJSONSelect: operation = operation(type: type, shapeId: shapeId)
                    let operationJSONErase: operation = operation(type: ERASESHAPE, shapeId: shapeId)
                    sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSONSelect]))
                    sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSONErase]))
                }
            }
            else {
                if(!lassoArray.isEmpty){
                    for shapeLasso in lassoArray{
                        shapeLasso.removeFromSuperview()
                    }
                    lassoArray = []
                }
                else{
                    touches.first?.view?.removeFromSuperview()
                }
            }
        }
    }
    @objc func rotatedView(_ sender: UIRotationGestureRecognizer) {
        var originalRotation = CGFloat()
        if sender.state == .began {
            sender.rotation = lastRotation
            originalRotation = sender.rotation
        } else if sender.state == .changed {
            let newRotation = sender.rotation + originalRotation
            sender.view?.transform = CGAffineTransform(rotationAngle: newRotation)
        } else if sender.state == .ended {
            lastRotation = sender.rotation
        }
    }
    
    
    //MOVE
    @objc func handdleDrag(_ sender: UIPanGestureRecognizer) {
        
        if (selectedStatePolyPaintPro == enumStatePolyPaintPro.cursor) {
            if(!User.shared.wifi){
                let translation = sender.translation(in: self)
                sender.view?.center = CGPoint(x: (sender.view?.center.x)! + translation.x, y: (sender.view?.center.y)! + translation.y)
                sender.setTranslation(CGPoint.zero, in: sender.view)
                
                let shapeView = sender.view as! ShapeView
                for anchorPoint in shapeView.anchorPoints {
                    if(anchorPoint.anchorPointIsUsed == true){
                        let canvasView = shapeView.superview as! CanvasView
                        for shapeDestination in anchorPoint.anchorPointLinesGoesTo{
                            for anchorPointDestination in shapeDestination.anchorPoints{
                                if(anchorPointDestination.anchorPointIsUsed){
                                    
                                    for anchorValidation in anchorPointDestination.anchorPointLinesGoesTo{
                                        if(anchorValidation == shapeView){
                                            
                                            if(true){
                                                
                                                canvasView.createFrameLine(dotted: false, arrow: false, heritage: false, twoWay: false, aggregation: false, composition: false, firstAnchorPointParameter: anchorPoint, secondAnchorPointParameter: anchorPointDestination)
                                            }
                                            if(anchorPoint.isSecondAnchor){
                                                canvasView.createFrameLine(dotted: false, arrow: false, heritage: false, twoWay: false, aggregation: false, composition: false, firstAnchorPointParameter: anchorPoint, secondAnchorPointParameter: anchorPointDestination)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                
            }
            else {
                let translation = sender.translation(in: self)
                let shapeToMove = sender.view as! ShapeView
                let newPosition: [PositionJSON]
                switch shapeSwift?.type {
                case ELLIPSE?:
                    let shapeSwift = shapeToMove.shapeSwift as! EllipseSwift
                    newPosition = [PositionJSON(x: float_t((sender.view?.center.x)! + translation.x), y: float_t((sender.view?.center.y)! + translation.y))]
                    let shapeJSON: shape = shape(type:shapeSwift.type, positions: newPosition, length: float_t(shapeSwift.length), width: float_t(shapeSwift.width), title: shapeSwift.title, id: id(value: shapeSwift.shapeId.value), author: shapeSwift.author, className: "", attributes: "", methods: "", text: "", actorName: "", picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""))
                    
                    let operationJSONModify: operation = operation(type: MODIFYSHAPE, shape: shapeJSON, user: User.shared.name)
                    
                    
                    let operationJSONSelect: operation = operation(type: SELECTSHAPE, shapeId: (shapeJSON.id?.value)!)
                    let operationJSONDeselect: operation = operation(type: DESELECTSHAPE, shapeId: (shapeJSON.id?.value)!)
                    if(sender.state == UIGestureRecognizerState.began){
                        selectedShape = shapeToMove
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
                    break
                case RECTANGLE?:
                    let shapeSwift = shapeToMove.shapeSwift as! RectangleSwift
                    
                    newPosition = [PositionJSON(x: float_t((shapeSwift.positions[0].x) + translation.x), y: float_t((shapeSwift.positions[0].y) + translation.y)),PositionJSON(x: float_t((shapeSwift.positions[1].x) + translation.x), y: float_t((shapeSwift.positions[1].y) + translation.y)),PositionJSON(x: float_t((shapeSwift.positions[2].x) + translation.x), y: float_t((shapeSwift.positions[2].y) + translation.y)),PositionJSON(x: float_t((shapeSwift.positions[3].x) + translation.x), y: float_t((shapeSwift.positions[3].y) + translation.y))]
                    let shapeJSON: shape = shape(type:shapeSwift.type, positions: newPosition, length: nil, width: nil, title: nil, id: id(value: shapeSwift.shapeId.value), author: shapeSwift.author, className: "", attributes: "", methods: "", text: "", actorName: "", picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""))
                    let operationJSONModify: operation = operation(type: MODIFYSHAPE, shape: shapeJSON, user: User.shared.name)
                    let operationJSONSelect: operation = operation(type: SELECTSHAPE, shapeId: (shapeJSON.id?.value)!)
                    let operationJSONDeselect: operation = operation(type: DESELECTSHAPE, shapeId: (shapeJSON.id?.value)!)
                    if(sender.state == UIGestureRecognizerState.began){
                        selectedShape = shapeToMove
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
                    break
                    
                    
                case TRIANGLE?:
                    let shapeSwift = shapeToMove.shapeSwift as! TriangleSwift
                    newPosition = [PositionJSON(x: float_t((shapeSwift.positions[0].x) + translation.x), y: float_t((shapeSwift.positions[0].y) + translation.y)),PositionJSON(x: float_t((shapeSwift.positions[1].x) + translation.x), y: float_t((shapeSwift.positions[1].y) + translation.y)),PositionJSON(x: float_t((shapeSwift.positions[2].x) + translation.x), y: float_t((shapeSwift.positions[2].y) + translation.y))]
                    let shapeJSON: shape = shape(type:shapeSwift.type, positions: newPosition, length: nil, width: nil, title: nil, id: id(value: shapeSwift.shapeId.value), author: shapeSwift.author, className: "", attributes: "", methods: "", text: "", actorName: "", picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""))
                    
                    let operationJSONModify: operation = operation(type: MODIFYSHAPE, shape: shapeJSON, user: User.shared.name)
                    
                    
                    let operationJSONSelect: operation = operation(type: SELECTSHAPE, shapeId: (shapeJSON.id?.value)!)
                    let operationJSONDeselect: operation = operation(type: DESELECTSHAPE, shapeId: (shapeJSON.id?.value)!)
                    if(sender.state == UIGestureRecognizerState.began){
                        selectedShape = shapeToMove
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
                    break
                    
                case ACTOR?:
                    let shapeSwift = shapeToMove.shapeSwift as! ActorSwift
                    newPosition = [PositionJSON(x: float_t((shapeSwift.positions[0].x) + translation.x), y: float_t((shapeSwift.positions[0].y) + translation.y)),PositionJSON(x: float_t((shapeSwift.positions[1].x) + translation.x), y: float_t((shapeSwift.positions[1].y) + translation.y)),PositionJSON(x: float_t((shapeSwift.positions[2].x) + translation.x), y: float_t((shapeSwift.positions[2].y) + translation.y))]
                    let shapeJSON: shape = shape(type:shapeSwift.type, positions: newPosition, length: nil, width: nil, title: nil, id: id(value: shapeSwift.shapeId.value), author: shapeSwift.author, className: "", attributes: "", methods: "", text: "", actorName: "", picture : "",lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""))
                   
                    let operationJSONModify: operation = operation(type: MODIFYSHAPE, shape: shapeJSON, user: User.shared.name)
                    
                    
                    let operationJSONSelect: operation = operation(type: SELECTSHAPE, shapeId: (shapeJSON.id?.value)!)
                    let operationJSONDeselect: operation = operation(type: DESELECTSHAPE, shapeId: (shapeJSON.id?.value)!)
                    if(sender.state == UIGestureRecognizerState.began){
                        selectedShape = shapeToMove
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
                    break
                case CLASSRECTANGLE?:
                    let shapeSwift = shapeToMove.shapeSwift as! ClassRectangleSwift
                    newPosition = [PositionJSON(x: float_t((shapeSwift.positions[0].x) + translation.x), y: float_t((shapeSwift.positions[0].y) + translation.y)),PositionJSON(x: float_t((shapeSwift.positions[1].x) + translation.x), y: float_t((shapeSwift.positions[1].y) + translation.y)),PositionJSON(x: float_t((shapeSwift.positions[2].x) + translation.x), y: float_t((shapeSwift.positions[2].y) + translation.y))]
                    let shapeJSON: shape = shape(type:shapeSwift.type, positions: newPosition, length: nil, width: nil, title: nil, id: id(value: shapeSwift.shapeId.value), author: shapeSwift.author, className: "", attributes: "", methods: "", text: "", actorName: "", picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""))
                    
                    let operationJSONModify: operation = operation(type: MODIFYSHAPE, shape: shapeJSON, user: User.shared.name)
                    
                    
                    let operationJSONSelect: operation = operation(type: SELECTSHAPE, shapeId: (shapeJSON.id?.value)!)
                    let operationJSONDeselect: operation = operation(type: DESELECTSHAPE, shapeId: (shapeJSON.id?.value)!)
                    if(sender.state == UIGestureRecognizerState.began){
                        selectedShape = shapeToMove
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
                    break
                default:
                    break
                }
                
            }
            
            
        }
        
        if (selectedStatePolyPaintPro == enumStatePolyPaintPro.lasso) {
            if(User.shared.wifi){
                for shapeToMove in lassoArrayCollab{
                    let translation = sender.translation(in: self)
                    let newPosition: [PositionJSON]
                    switch shapeToMove.shapeSwift?.type {
                    case ELLIPSE?:
                        let shapeSwift = shapeToMove.shapeSwift as! EllipseSwift
                        newPosition = [PositionJSON(x: float_t((shapeToMove.center.x) + translation.x), y: float_t((shapeToMove.center.y) + translation.y))]
                        let shapeJSON: shape = shape(type:shapeSwift.type, positions: newPosition, length: float_t(shapeSwift.length), width: float_t(shapeSwift.width), title: shapeSwift.title, id: id(value: shapeSwift.shapeId.value), author: shapeSwift.author, className: "", attributes: "", methods: "", text: "", actorName: "", picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""))
        
                        let operationJSONModify: operation = operation(type: MODIFYSHAPE, shape: shapeJSON, user: User.shared.name)
                        
                        
                        let operationJSONSelect: operation = operation(type: SELECTSHAPE, shapeId: (shapeJSON.id?.value)!)
                        let operationJSONDeselect: operation = operation(type: DESELECTSHAPE, shapeId: (shapeJSON.id?.value)!)
                        if(sender.state == UIGestureRecognizerState.began){
                            selectedShape = shapeToMove
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
                        break
                    case RECTANGLE?:
                        let shapeSwift = shapeToMove.shapeSwift as! RectangleSwift
                        
                        newPosition = [PositionJSON(x: float_t((shapeSwift.positions[0].x) + translation.x), y: float_t((shapeSwift.positions[0].y) + translation.y)),PositionJSON(x: float_t((shapeSwift.positions[1].x) + translation.x), y: float_t((shapeSwift.positions[1].y) + translation.y)),PositionJSON(x: float_t((shapeSwift.positions[2].x) + translation.x), y: float_t((shapeSwift.positions[2].y) + translation.y)),PositionJSON(x: float_t((shapeSwift.positions[3].x) + translation.x), y: float_t((shapeSwift.positions[3].y) + translation.y))]
                        let shapeJSON: shape = shape(type:shapeSwift.type, positions: newPosition, length: nil, width: nil, title: nil, id: id(value: shapeSwift.shapeId.value), author: shapeSwift.author, className: "", attributes: "", methods: "", text: "", actorName: "", picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""))
                        let operationJSONModify: operation = operation(type: MODIFYSHAPE, shape: shapeJSON, user: User.shared.name)
                        let operationJSONSelect: operation = operation(type: SELECTSHAPE, shapeId: (shapeJSON.id?.value)!)
                        let operationJSONDeselect: operation = operation(type: DESELECTSHAPE, shapeId: (shapeJSON.id?.value)!)
                        if(sender.state == UIGestureRecognizerState.began){
                            selectedShape = shapeToMove
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
                        break
                        
                        
                    case TRIANGLE?:
                        let shapeSwift = shapeToMove.shapeSwift as! TriangleSwift
                        newPosition = [PositionJSON(x: float_t((shapeSwift.positions[0].x) + translation.x), y: float_t((shapeSwift.positions[0].y) + translation.y)),PositionJSON(x: float_t((shapeSwift.positions[1].x) + translation.x), y: float_t((shapeSwift.positions[1].y) + translation.y)),PositionJSON(x: float_t((shapeSwift.positions[2].x) + translation.x), y: float_t((shapeSwift.positions[2].y) + translation.y))]
                        let shapeJSON: shape = shape(type:shapeSwift.type, positions: newPosition, length: nil, width: nil, title: nil, id: id(value: shapeSwift.shapeId.value), author: shapeSwift.author, className: "", attributes: "", methods: "", text: "", actorName: "", picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""))
                        
                        let operationJSONModify: operation = operation(type: MODIFYSHAPE, shape: shapeJSON, user: User.shared.name)
                        
                        
                        let operationJSONSelect: operation = operation(type: SELECTSHAPE, shapeId: (shapeJSON.id?.value)!)
                        let operationJSONDeselect: operation = operation(type: DESELECTSHAPE, shapeId: (shapeJSON.id?.value)!)
                        if(sender.state == UIGestureRecognizerState.began){
                            selectedShape = shapeToMove
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
                        break
                        
                    case ACTOR?:
                        let shapeSwift = shapeToMove.shapeSwift as! ActorSwift
                        newPosition = [PositionJSON(x: float_t((shapeSwift.positions[0].x) + translation.x), y: float_t((shapeSwift.positions[0].y) + translation.y)),PositionJSON(x: float_t((shapeSwift.positions[1].x) + translation.x), y: float_t((shapeSwift.positions[1].y) + translation.y)),PositionJSON(x: float_t((shapeSwift.positions[2].x) + translation.x), y: float_t((shapeSwift.positions[2].y) + translation.y))]
                        let shapeJSON: shape = shape(type:shapeSwift.type, positions: newPosition, length: nil, width: nil, title: nil, id: id(value: shapeSwift.shapeId.value), author: shapeSwift.author, className: "", attributes: "", methods: "", text: "", actorName: "", picture : "",lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""))
                        
                        let operationJSONModify: operation = operation(type: MODIFYSHAPE, shape: shapeJSON, user: User.shared.name)
                        
                        
                        let operationJSONSelect: operation = operation(type: SELECTSHAPE, shapeId: (shapeJSON.id?.value)!)
                        let operationJSONDeselect: operation = operation(type: DESELECTSHAPE, shapeId: (shapeJSON.id?.value)!)
                        if(sender.state == UIGestureRecognizerState.began){
                            selectedShape = shapeToMove
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
                        break
                    case CLASSRECTANGLE?:
                        let shapeSwift = shapeToMove.shapeSwift as! ClassRectangleSwift
                        newPosition = [PositionJSON(x: float_t((shapeSwift.positions[0].x) + translation.x), y: float_t((shapeSwift.positions[0].y) + translation.y)),PositionJSON(x: float_t((shapeSwift.positions[1].x) + translation.x), y: float_t((shapeSwift.positions[1].y) + translation.y)),PositionJSON(x: float_t((shapeSwift.positions[2].x) + translation.x), y: float_t((shapeSwift.positions[2].y) + translation.y))]
                        let shapeJSON: shape = shape(type:shapeSwift.type, positions: newPosition, length: nil, width: nil, title: nil, id: id(value: shapeSwift.shapeId.value), author: shapeSwift.author, className: "", attributes: "", methods: "", text: "", actorName: "", picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: shapeSwift.shapeId.value, positionOnShape: ""))
                        
                        let operationJSONModify: operation = operation(type: MODIFYSHAPE, shape: shapeJSON, user: User.shared.name)
                        
                        
                        let operationJSONSelect: operation = operation(type: SELECTSHAPE, shapeId: (shapeJSON.id?.value)!)
                        let operationJSONDeselect: operation = operation(type: DESELECTSHAPE, shapeId: (shapeJSON.id?.value)!)
                        if(sender.state == UIGestureRecognizerState.began){
                            selectedShape = shapeToMove
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
                        break
                    default:
                        break
                    }
                }
            }
            else{
                if (!lassoArray.isEmpty){
                    let translation = sender.translation(in: self)
                    
                    for shape in lassoArray {
                        shape.transform = shape.transform.translatedBy(x: CGFloat(translation.x)/10, y: CGFloat(translation.y)/10)
                    }
                }
            }
        }
    }
    
    //ROTATION
    @objc func handdleDoubleTap( _ sender: UITapGestureRecognizer) {
        let rotationAngle: CGFloat = 1.5708
        if (User.shared.wifi) {
        }
        else {
            if (selectedStatePolyPaintPro == enumStatePolyPaintPro.cursor ) {
                sender.view?.transform = (sender.view?.transform.rotated(by: rotationAngle))!
            }
        }
    }
    //PinchBigger
    @objc func handdlePinch(_ sender: UIPinchGestureRecognizer) {
        if (User.shared.wifi) {
            
        }
        else {
            if (selectedStatePolyPaintPro == enumStatePolyPaintPro.cursor ) {
                self.superview!.bringSubview(toFront: self)
                let scale = sender.scale
                self.transform = CGAffineTransform.init(scaleX: scale, y: scale)
            }
        }
    }
    @objc func handdleTapDelete(_ sender: UITapGestureRecognizer) {
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
        if (selectedStatePolyPaintPro == enumStatePolyPaintPro.lasso) {
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
                for shapeLasso in lassoArray{
                    shapeLasso.removeFromSuperview()
                }
            }
        }
        
    }
}

// Anchor Points

extension ShapeView {
    func setAnchorPointsRectangle(width: CGFloat, length: CGFloat) {
        var frame = CGRect(x: (width * 0.5) - ANCHORPOINTSIZE * 0.5, y: 0, width: ANCHORPOINTSIZE, height: ANCHORPOINTSIZE)
        let anchorPoint = AnchorPoint(frame: frame, anchorPointAttachedTo: self)
        anchorPoints.append(anchorPoint)
        self.addSubview(anchorPoint)
        
        frame = CGRect(x: (width * 0.5) - ANCHORPOINTSIZE * 0.5, y: length - 10, width: ANCHORPOINTSIZE, height: ANCHORPOINTSIZE)
        let anchorPoint2 = AnchorPoint(frame: frame, anchorPointAttachedTo: self)
        anchorPoints.append(anchorPoint2)
        self.addSubview(anchorPoint2)
        
        frame = CGRect(x: 0, y: (length * 0.5) - ANCHORPOINTSIZE * 0.5 , width: ANCHORPOINTSIZE, height: ANCHORPOINTSIZE)
        let anchorPoint3 = AnchorPoint(frame: frame, anchorPointAttachedTo: self)
        anchorPoints.append(anchorPoint3)
        self.addSubview(anchorPoint3)
        
        frame = CGRect(x: width - ANCHORPOINTSIZE, y: (length * 0.5) - ANCHORPOINTSIZE * 0.5, width: ANCHORPOINTSIZE, height: ANCHORPOINTSIZE)
        let anchorPoint4 = AnchorPoint(frame: frame, anchorPointAttachedTo: self)
        anchorPoints.append(anchorPoint4)
        self.addSubview(anchorPoint4)
    }
    
    func setAnchorPointsTriangle(width: CGFloat, length: CGFloat) {
        var frame = CGRect(x: width/2 - ANCHORPOINTSIZE/2 , y: length - ANCHORPOINTSIZE*0.75  , width: ANCHORPOINTSIZE, height: ANCHORPOINTSIZE)
        let anchorPoint = AnchorPoint(frame: frame, anchorPointAttachedTo: self)
        anchorPoints.append(anchorPoint)
        self.addSubview(anchorPoint)
        
        frame = CGRect(x: width/4 - ANCHORPOINTSIZE/2, y: length/2 , width: ANCHORPOINTSIZE, height: ANCHORPOINTSIZE)
        let anchorPoint2 = AnchorPoint(frame: frame, anchorPointAttachedTo: self)
        anchorPoints.append(anchorPoint2)
        self.addSubview(anchorPoint2)
        
        frame = CGRect(x: (width * 3/4) - ANCHORPOINTSIZE/2, y: length/2 , width: ANCHORPOINTSIZE, height: ANCHORPOINTSIZE)
        let anchorPoint3 = AnchorPoint(frame: frame, anchorPointAttachedTo: self)
        anchorPoints.append(anchorPoint3)
        self.addSubview(anchorPoint3)
    }
    
    func setAnchorPointsCircle(center: CGPoint) {
        var frame = CGRect(x: center.x - self.frame.width/2 - LINEWIDTH/2, y: center.y, width: ANCHORPOINTSIZE, height: ANCHORPOINTSIZE)
        let anchorPoint = AnchorPoint(frame: frame, anchorPointAttachedTo: self)
        anchorPoints.append(anchorPoint)
        self.addSubview(anchorPoint)
        
        frame = CGRect(x: center.x + self.frame.width/2 - ANCHORPOINTSIZE * 0.5  - LINEWIDTH, y: center.y, width: ANCHORPOINTSIZE, height: ANCHORPOINTSIZE)
        let anchorPoint2 = AnchorPoint(frame: frame, anchorPointAttachedTo: self)
        anchorPoints.append(anchorPoint2)
        self.addSubview(anchorPoint2)
        
        frame = CGRect(x: center.x - ANCHORPOINTSIZE * 0.5 , y: center.y - self.frame.height/2, width: ANCHORPOINTSIZE, height: ANCHORPOINTSIZE)
        let anchorPoint3 = AnchorPoint(frame: frame, anchorPointAttachedTo: self)
        anchorPoints.append(anchorPoint3)
        self.addSubview(anchorPoint3)
        
        frame = CGRect(x: center.x - ANCHORPOINTSIZE * 0.5, y: center.y + self.frame.height/2 - ANCHORPOINTSIZE * 0.5 - LINEWIDTH, width: ANCHORPOINTSIZE, height: ANCHORPOINTSIZE)
        let anchorPoint4 = AnchorPoint(frame: frame, anchorPointAttachedTo: self)
        anchorPoints.append(anchorPoint4)
        self.addSubview(anchorPoint4)
    }
}
