//
//  CanvasView.swift
//  Prototype_IOS
//
//  Created by Jeremie Miglierina on 18-10-12.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import UIKit

enum enumStatePolyPaintPro {
    case cursor, label, cut, erase, shapes, duplicate, paste, stackPop, stackPut, classD, userD, lasso
}

enum enumShapes {
    case null, rectangle, ellipse, triangle, arrow, line
}
enum enumUserCaseDiagrame {
    case null, actor, arrow, line, dotted, heritage, twoWayArrow, agggregation, composition, userCase
}

var selectedShapeButton = enumShapes.null
var selectedStatePolyPaintPro = enumStatePolyPaintPro.cursor
var selectedStateUserCaseD = enumUserCaseDiagrame.null

var selectedShape: ShapeView!
var isSelectedShape:Bool = false

var cutItem: ShapeView!
var isCut:Bool = false

var myStack = Stack<ShapeView>()
var lassoPath: CGPath!
var startingPointLasso:CGPath!
var lassoArrayCollab: [ShapeView] = []
var lassoArray: [ShapeView] = []
let blackColor = UIColor.black.cgColor
let blueColor = UIColor.blue.cgColor

protocol CanvasDoAlert: class {
    func doAlert(name: String, message: String)
}


class CanvasView: UIView  {
    
    let deleteGesture = UITapGestureRecognizer(target: self, action: #selector(CanvasView.deleteTapHanddler(_:)))
    var moveCounter: float_t = 0
    
    //var state:String! //TODO
    var selectedShapeView: UIView!
    var shapeInCanvasArray: [shape] = []
    var workspace : Workspace = Workspace()
    var startingPoint:CGPoint!
    var lastPoint: CGPoint!
    var endPoint: CGPoint!
    
    var lineColor:UIColor! = UIColor.black
    var lineWidth:CGFloat! = 10
    var path:UIBezierPath!
    var canvasDoAlert: CanvasDoAlert!
    
    var startPointLasso: CGPoint!
    var swiped = false
    var newLassoImage: UIImageView!
    var lassoEndPoint:CGPoint!
    
    func setWorkspace(workspace: Workspace){
        self.workspace = workspace
    }
    
    override func layoutSubviews() {
        self.clipsToBounds = true
        self.isMultipleTouchEnabled = false
        
    }
    
    
    func calculRectangleFourPoints(startingPoint: CGPoint, width: CGFloat, length: CGFloat) -> [PositionJSON]  {
        var positions: [PositionJSON] = []
        let halfWidth = width/2
        let halfLength = length/2
        let firstPoint = PositionJSON(x: float_t(startingPoint.x + halfLength), y: float_t(startingPoint.x + halfWidth))
        let secondPoint = PositionJSON(x:float_t(startingPoint.x + halfLength), y:float_t(startingPoint.x - halfWidth) )
        let thirdPoint = PositionJSON(x: float_t(startingPoint.x - halfLength), y:float_t(startingPoint.x + halfWidth) )
        let fourthPoint = PositionJSON(x: float_t(startingPoint.x - halfLength), y:float_t(startingPoint.x - halfWidth))
        positions.append(firstPoint)
        positions.append(secondPoint)
        positions.append(thirdPoint)
        positions.append(fourthPoint)
        return positions
    }
    
    
    func createShapeUIViewOnline(positions: [CGPoint],width: CGFloat, height: CGFloat,shapeSwift : ShapesSwift, shape: Int) {
        var frameShape: CGRect = CGRect()
        switch shapeSwift.type {
        case RECTANGLE:
            frameShape = CGRect(x: CGFloat(positions[0].x), y:  CGFloat(positions[0].y), width: CGFloat(abs(positions[1].x - positions[0].x)), height: CGFloat(abs(positions[3].y - positions[0].y)))
        case ELLIPSE, ACTOR, TEXTBOX:
            frameShape = CGRect(x: CGFloat(positions[0].x - width/2), y:  CGFloat(float_t(positions[0].y - height/2)), width: CGFloat(width), height: CGFloat(height))
        case TRIANGLE:
            if(shape == 1){
                frameShape = CGRect(x: CGFloat(positions[0].x - abs(positions[1].x - positions[0].x)/2), y:  CGFloat(positions[0].y), width: CGFloat(abs(positions[1].x - positions[0].x)), height: CGFloat(abs(positions[2].y - positions[0].y)))}
            else if(shape == 5){
                frameShape = CGRect(x: CGFloat(positions[0].x - abs(positions[1].x - positions[0].x)/2), y:  CGFloat(positions[1].y), width: CGFloat(abs(positions[1].x - positions[0].x)), height: CGFloat(abs(positions[2].y - positions[0].y)))}
            
        case ACTOR:
            frameShape = CGRect(x: CGFloat(positions[0].x), y:  CGFloat(positions[0].y), width: CGFloat(abs(positions[1].x - positions[0].x)), height: CGFloat(abs(positions[3].y - positions[0].y)))
        default:
            break
        }
        
        // TODO FONCTION DESSINER FRAME POUR LES CINQ TYPE DE FRAME
        let newShape = ShapeView(frame: frameShape, shape: shape, startingPoint: positions[0], workspace: self.workspace, shapeSwift : shapeSwift)
        newShape.addGestureRecognizer(deleteGesture)
        self.addSubview(newShape)
    }
    
    func createShapeUIViewOffline(positions: [CGPoint],width: CGFloat, height: CGFloat, shape: Int) {
        let frame = CGRect(x: positions[0].x - width/2, y:  positions[0].y - width/2, width: width+100, height: height+100)
        let newShape = ShapeView(frame: frame , shape: shape, startingPoint: positions[0], workspace: self.workspace, shapeSwift: ShapesSwift(positions: positions))
        newShape.addGestureRecognizer(deleteGesture)
        self.addSubview(newShape)
        addShapeToUserOffline(shape: newShape)
    }
    
    func addShapeToUserOffline(shape: ShapeView){
        User.shared.localShapes.append(shape)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        startingPoint = touch?.location(in: self )
        
        if (isSelectedShape && (selectedStatePolyPaintPro != enumStatePolyPaintPro.duplicate) &&
            (selectedStatePolyPaintPro != enumStatePolyPaintPro.cut) && (selectedStatePolyPaintPro != enumStatePolyPaintPro.paste)
            && selectedStatePolyPaintPro != enumStatePolyPaintPro.stackPut) {
            if(User.shared.wifi){
                let selectedShapeDeselect = selectedShape!
                let shapeId = selectedShapeDeselect.shapeSwift.shapeId.value
                let type = DESELECTSHAPE
                let operationJSON: operation = operation(type: type, shapeId: shapeId)
                sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSON]))
                
            }
            else{
                selectedShape.backgroundColor = UIColor.clear
                selectedShape = nil
                isSelectedShape = false
            }
        }
        switch selectedStatePolyPaintPro {
        case .cursor:
            break
        case .shapes:
            switch selectedShapeButton {
            case enumShapes.rectangle:
                if (User.shared.wifi) {
                    let idJSON = id(value: "")
                    let position1 :PositionJSON = PositionJSON(x: float_t(startingPoint.x) ,y:float_t(startingPoint.y))
                    let position2 :PositionJSON = PositionJSON(x: float_t(startingPoint.x + 200) ,y:float_t(startingPoint.y))
                    let position3 :PositionJSON = PositionJSON(x: float_t(startingPoint.x + 200) ,y:float_t(startingPoint.y - 150))
                    let position4 :PositionJSON = PositionJSON(x: float_t(startingPoint.x) ,y:float_t(startingPoint.y - 150))
                    
                    let positions : Array<PositionJSON> = [position1,position2,position3,position4]
                    let shapeJSON: shape = shape(type:RECTANGLE, positions: positions, length:150 , width:200 , title: "", id:idJSON, author: "", className: "", attributes: "", methods: "", text: "", actorName: "", picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: idJSON.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: idJSON.value, positionOnShape: ""))
                    let operationJSON: operation = operation(type:ADDSHAPE, shape: shapeJSON, user: "")
                    sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSON]))
                }
                else {
                    createShapeUIViewOffline(positions: [startingPoint], width: 150, height:100,
                                             shape: 0)
                }
                break
            case enumShapes.ellipse:
                if (User.shared.wifi) {
                    let idJSON = id(value: "")
                    let position :PositionJSON = PositionJSON(x: float_t(startingPoint.x),y:float_t(startingPoint.y))
                    let positions : Array<PositionJSON> = [position]
                    let shapeJSON: shape = shape(type:ELLIPSE, positions: positions, length: 200, width: 300, title: "", id:idJSON, author: "", className: "", attributes: "", methods: "", text: "", actorName: "", picture : "",lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: idJSON.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: idJSON.value, positionOnShape: ""))
                    let operationJSON: operation = operation(type:ADDSHAPE, shape: shapeJSON, user: "")
                    sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSON]))
                }
                else {
                    createShapeUIViewOffline(positions: [startingPoint], width: 100, height: 150, shape: 2)
                }
                
                break
            case enumShapes.triangle:
                if (User.shared.wifi) {
                    let idJSON = id(value: "")
                    let position1 :PositionJSON = PositionJSON(x: float_t(startingPoint.x) ,y:float_t(startingPoint.y))
                    let position2 :PositionJSON = PositionJSON(x: float_t(startingPoint.x + 150) ,y:float_t(startingPoint.y  + 100))
                    let position3 :PositionJSON = PositionJSON(x: float_t(startingPoint.x - 150/2) ,y:float_t(startingPoint.y + 100))
                    let positions : Array<PositionJSON> = [position1,position2,position3]
                    let shapeJSON: shape = shape(type:TRIANGLE, positions: positions, length: 100, width: 150, title: "", id:idJSON, author: "", className: "", attributes: "", methods: "", text: "", actorName: "", picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: idJSON.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: idJSON.value, positionOnShape: ""))
                    let operationJSON: operation = operation(type:ADDSHAPE, shape: shapeJSON, user: "")
                    sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSON]))
                }
                else {
                    createShapeUIViewOffline(positions: [startingPoint], width: 100, height: 150, shape: 1)
                }
                break
            case enumShapes.arrow:
                if (User.shared.wifi) {
                    canvasDoAlert.doAlert(name: "Error", message: "Please use the arrow from the User Case Diagram")
                }
                else {
                    createShapeUIViewOffline(positions: [startingPoint], width: 150, height:60, shape: 4)
                }
                break
            case enumShapes.line:
                if (User.shared.wifi) {
                    canvasDoAlert.doAlert(name: "Error", message: "Please use the line from the User Case Diagram")
                }
                else {
                    createShapeUIViewOffline(positions: [startingPoint], width: 150, height:60, shape: 3)
                }
                break
            default: break
            }
            break
        case .label:
            if (User.shared.wifi) {
                let idJSON = id(value: "")
                let position :PositionJSON = PositionJSON(x: float_t(startingPoint.x) ,y:float_t(startingPoint.y))
                let positions : Array<PositionJSON> = [position]
                let shapeJSON: shape = shape(type:TEXTBOX, positions: positions, length: 150, width: 200, title: "", id:idJSON, author: "", className: "", attributes: "", methods: "", text: "Insert text here!", actorName: "", picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: idJSON.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: idJSON.value, positionOnShape: ""))
                let operationJSON: operation = operation(type:ADDSHAPE, shape: shapeJSON, user: "")
                sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSON]))
            }
            else {
                self.hideKeyboardWhenTappedAround()
                let frame = CGRect(x: startingPoint.x - 300/2, y:  startingPoint.y - 300/2, width: 300, height: 200)
                let newText = self.makeTextView(frame: frame)
                self.addSubview(newText)
                //User.shared.localTexts.append(newText)
                selectedStatePolyPaintPro = enumStatePolyPaintPro.cursor
            }
            break
        case .cut:
            if (User.shared.wifi){
                if (isSelectedShape) {
                    cutItem = selectedShape
                    cutItem.backgroundColor = UIColor.clear
                    isCut = true
                    let shapeId = cutItem.shapeSwift.shapeId.value
                    let operationJSONSelect: operation = operation(type: SELECTSHAPE, shapeId: shapeId)
                    let operationJSONErase: operation = operation(type: ERASESHAPE, shapeId: shapeId)
                    sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSONSelect]))
                    sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSONErase]))
                    selectedShape = nil
                    isSelectedShape = false
                }
                else {
                    canvasDoAlert.doAlert(name: "No selected shape !", message: "Error, please select a shape to cut. ")
                }
            }
            else {
                if (isSelectedShape) {
                    cutItem = selectedShape
                    cutItem.backgroundColor = UIColor.clear
                    isCut = true
                    selectedShape.removeFromSuperview()
                    selectedShape = nil
                    isSelectedShape = false
                }
                else {
                    canvasDoAlert.doAlert(name: "No selected shape !", message: "Error, please select a shape to cut. ")
                }
            }
            selectedStatePolyPaintPro = enumStatePolyPaintPro.cursor
            break
        case .paste:
            if (User.shared.wifi){
                if (isCut) {
                    let shapeJSON: shape = cutItem.shapeSwift.toShape()
                    let operationJSON: operation = operation(type:ADDSHAPE, shape: shapeJSON, user: "")
                    sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSON]))
                    isCut = false
                    cutItem = nil
                }
                else {
                    canvasDoAlert.doAlert(name: "Error", message: "Please cut an item first !")
                }
            }
            else {
                if (isCut) {
                    self.addSubview(cutItem)
                    isCut = false
                    cutItem = nil
                }
                else {
                    canvasDoAlert.doAlert(name: "Error", message: "Please cut an item first !")
                }
            }
            selectedStatePolyPaintPro = enumStatePolyPaintPro.cursor
            break
        case .duplicate:
            if (User.shared.wifi) {
                if (isSelectedShape) {
                    let shapeJSON: shape = selectedShape.shapeSwift.toShape()
                    let operationJSON: operation = operation(type:ADDSHAPE, shape: shapeJSON, user: "")
                    sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSON]))
                }
                else {
                    canvasDoAlert.doAlert(name: "Error", message: "Please select a shape first !")
                }
            }
            else {
                if(isSelectedShape) {
                    createShapeUIViewOffline(positions: [startingPoint] , width: selectedShape.frame.width, height: selectedShape.frame.height, shape: selectedShape.currentShapeType)
                }
                else {
                    canvasDoAlert.doAlert(name: "Error", message: "Please select a shape first !")
                }
            }
            break
        case .erase:
            break
        case .stackPop:
            if (User.shared.wifi) {
                if (!myStack.isEmpty) {
                    let shappeView = myStack.pop()
                    let shapeJSON: shape = shappeView!.shapeSwift.toShape()
                    let operationJSON: operation = operation(type:ADDSHAPE, shape: shapeJSON, user: "")
                    sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSON]))
                }
                else {
                    canvasDoAlert.doAlert(name: "Error", message: "Your stack is empty !")
                }
            }
            else {
                if (!myStack.isEmpty) {
                    let shappeView = myStack.pop()
                    self.addSubview(shappeView!)
                }
                else {
                    canvasDoAlert.doAlert(name: "Error", message: "Your stack is empty !")
                }
            }
            selectedStatePolyPaintPro = enumStatePolyPaintPro.cursor
            break
        case .stackPut:
            if (User.shared.wifi) {
                if (isSelectedShape) {
                    myStack.push(selectedShape)
                    let shapeId = selectedShape.shapeSwift.shapeId.value
                    let operationJSONSelect: operation = operation(type: SELECTSHAPE, shapeId: shapeId)
                    let operationJSONErase: operation = operation(type: ERASESHAPE, shapeId: shapeId)
                    sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSONSelect]))
                    sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSONErase]))
                }
                else {
                    canvasDoAlert.doAlert(name: "Error", message: "Please select a shape first !")
                }
            }
            else {
                if (isSelectedShape) {
                    myStack.push(selectedShape)
                    selectedShape.removeFromSuperview()
                }
                else {
                    canvasDoAlert.doAlert(name: "Error", message: "Please select a shape first !")
                }
            }
            selectedStatePolyPaintPro = enumStatePolyPaintPro.cursor
            break
        case .classD:
            if (User.shared.wifi) {
                let idJSON = id(value: "")
                let position1 :PositionJSON = PositionJSON(x: float_t(startingPoint.x) ,y:float_t(startingPoint.y))
                let position2 :PositionJSON = PositionJSON(x: float_t(startingPoint.x + 200) ,y:float_t(startingPoint.y))
                let position3 :PositionJSON = PositionJSON(x: float_t(startingPoint.x + 200) ,y:float_t(startingPoint.y + 250))
                let position4 :PositionJSON = PositionJSON(x: float_t(startingPoint.x) ,y:float_t(startingPoint.y + 250))
                let positions : Array<PositionJSON> = [position1,position2,position3,position4]
                let shapeJSON: shape = shape(type:CLASSRECTANGLE, positions: positions, length: 400, width: 600, title: "", id:idJSON, author: "", className: "Class name", attributes: "- attribute: String", methods: "+ method(): void", text: "", actorName: "", picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: idJSON.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: idJSON.value, positionOnShape: ""))
                let operationJSON: operation = operation(type:ADDSHAPE, shape: shapeJSON, user: "")
                sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSON]))
            }
            else {
                let frame = CGRect(x: startingPoint.x - 150, y:  startingPoint.y - 100, width: 300, height: 200)
                let newClassView = ClassView(frame: frame , shape: 10, startingPoint: startingPoint, workspace: self.workspace, shapeSwift : ShapesSwift())
                newClassView.setClassName(className: "Class Name")
                self.addSubview(newClassView)
                //User.shared.localClassD.append(newClassView)
                selectedStatePolyPaintPro = enumStatePolyPaintPro.cursor
            }
            break
        case .userD:
            switch selectedStateUserCaseD {
            case .null:
                break
            case.actor:
                if (User.shared.wifi) {
                    let idJSON = id(value: "")
                    let position :PositionJSON = PositionJSON(x: float_t(startingPoint.x) ,y:float_t(startingPoint.y))
                    let positions : Array<PositionJSON> = [position]
                    let shapeJSON: shape = shape(type:ACTOR, positions: positions, length: 150, width: 100, title: "", id:idJSON, author: "", className: "", attributes: "", methods: "", text: "", actorName: "Actor", picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: idJSON.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: idJSON.value, positionOnShape: ""))
                    let operationJSON: operation = operation(type:ADDSHAPE, shape: shapeJSON, user: "")
                    sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSON]))
                }
                else {
                    let frame = CGRect(x: startingPoint.x - 50, y:  startingPoint.y - 75, width: 100, height: 150)
                    let newActor = ActorView(frame: frame , shape: 10, startingPoint: startingPoint, workspace: self.workspace, shapeSwift : ShapesSwift())
                    self.addSubview(newActor)
                    //User.shared.localActor.append(newActor)
                }
                break
            case .userCase:
                if (User.shared.wifi) {
                    let idJSON = id(value: "")
                    let position :PositionJSON = PositionJSON(x: float_t(startingPoint.x),y:float_t(startingPoint.y))
                    let positions : Array<PositionJSON> = [position]
                    let shapeJSON: shape = shape(type:ELLIPSE, positions: positions, length: 200, width: 300, title: "Use Case", id:idJSON, author: "", className: "", attributes: "", methods: "", text: "", actorName: "", picture : "",lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: idJSON.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: idJSON.value, positionOnShape: ""))
                    let operationJSON: operation = operation(type:ADDSHAPE, shape: shapeJSON, user: "")
                    sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSON]))
                }
                else {
                    let frame = CGRect(x: startingPoint.x - 50, y:  startingPoint.y - 75, width: 150, height: 100)
                    let newUseCase = UseCase(frame: frame , shape: 2, startingPoint: startingPoint, workspace: self.workspace, shapeSwift : ShapesSwift())
                    self.addSubview(newUseCase)
                }
                break
            case .line:
                if (User.shared.wifi) {
                    canvasDoAlert.doAlert(name: "Error", message: "Please go offline for lines")
                }
                else {
                    if(!firstAnchorTapped) {
                        canvasDoAlert.doAlert(name: "Error", message: "Please select an AnchorPoint")
                    }
                        
                    else if(firstAnchorTapped && !secondPointTapped) {
                        canvasDoAlert.doAlert(name: "Error", message: "Please select an other AnchorPoint")
                    }
                    else if (firstAnchorTapped && secondPointTapped) {
                        createFrameLine(dotted: false, arrow: false, heritage: false, twoWay: false, aggregation: false, composition: false, firstAnchorPointParameter: firstAnchorPointLine, secondAnchorPointParameter: secondAnchorPointLine)
                        firstAnchorTapped = false
                        secondPointTapped = false
                        for shapeUI in self.subviews {
                            if let shape = shapeUI as? ShapeView {
                                for anchorPoint in shape.anchorPoints {
                                    anchorPoint.isFirstAnchor = false
                                    anchorPoint.isSecondAnchor = false
                                }
                            }
                        }
                        selectedStateUserCaseD = enumUserCaseDiagrame.null
                        selectedStatePolyPaintPro = enumStatePolyPaintPro.cursor
                    }
                }
                break
            case .arrow:
                if (User.shared.wifi) {
                    canvasDoAlert.doAlert(name: "Error", message: "Please go offline for lines")
                }
                else {
                    if(!firstAnchorTapped) {
                        canvasDoAlert.doAlert(name: "Error", message: "Please select an AnchorPoint")
                    }
                        
                    else if(firstAnchorTapped && !secondPointTapped) {
                        canvasDoAlert.doAlert(name: "Error", message: "Please select an other AnchorPoint")
                    }
                    else if (firstAnchorTapped && secondPointTapped) {
                        createFrameLine(dotted: false, arrow: true, heritage: false, twoWay: false, aggregation: false, composition: false, firstAnchorPointParameter: firstAnchorPointLine, secondAnchorPointParameter: secondAnchorPointLine)
                        firstAnchorTapped = false
                        secondPointTapped = false
                        for shapeUI in self.subviews {
                            if let shape = shapeUI as? ShapeView {
                                for anchorPoint in shape.anchorPoints {
                                    anchorPoint.isFirstAnchor = false
                                    anchorPoint.isSecondAnchor = false
                                }
                            }
                        }
                        selectedStateUserCaseD = enumUserCaseDiagrame.null
                        selectedStatePolyPaintPro = enumStatePolyPaintPro.cursor
                    }
                }
                break
            case .dotted:
                if (User.shared.wifi) {
                    canvasDoAlert.doAlert(name: "Error", message: "Please go offline for lines")
                }
                else {
                    if(!firstAnchorTapped) {
                        canvasDoAlert.doAlert(name: "Error", message: "Please select an AnchorPoint")
                    }
                        
                    else if(firstAnchorTapped && !secondPointTapped) {
                        canvasDoAlert.doAlert(name: "Error", message: "Please select an other AnchorPoint")
                    }
                    else if (firstAnchorTapped && secondPointTapped) {
                        createFrameLine(dotted: true, arrow: false, heritage: false, twoWay: false, aggregation: false, composition: false, firstAnchorPointParameter: firstAnchorPointLine, secondAnchorPointParameter: secondAnchorPointLine)
                        firstAnchorTapped = false
                        secondPointTapped = false
                        for shapeUI in self.subviews {
                            if let shape = shapeUI as? ShapeView {
                                for anchorPoint in shape.anchorPoints {
                                    anchorPoint.isFirstAnchor = false
                                    anchorPoint.isSecondAnchor = false
                                }
                            }
                        }
                        selectedStateUserCaseD = enumUserCaseDiagrame.null
                        selectedStatePolyPaintPro = enumStatePolyPaintPro.cursor
                    }
                }
                break
            case .heritage:
                if (User.shared.wifi) {
                    canvasDoAlert.doAlert(name: "Error", message: "Please go offline for lines")
                }
                else {
                    if(!firstAnchorTapped) {
                        canvasDoAlert.doAlert(name: "Error", message: "Please select an AnchorPoint")
                    }
                        
                    else if(firstAnchorTapped && !secondPointTapped) {
                        canvasDoAlert.doAlert(name: "Error", message: "Please select an other AnchorPoint")
                    }
                    else if (firstAnchorTapped && secondPointTapped) {
                        createFrameLine(dotted: false, arrow: false, heritage: true, twoWay: false, aggregation: false, composition: false, firstAnchorPointParameter: firstAnchorPointLine, secondAnchorPointParameter: secondAnchorPointLine)
                        firstAnchorTapped = false
                        secondPointTapped = false
                        for shapeUI in self.subviews {
                            if let shape = shapeUI as? ShapeView {
                                for anchorPoint in shape.anchorPoints {
                                    anchorPoint.isFirstAnchor = false
                                    anchorPoint.isSecondAnchor = false
                                }
                            }
                        }
                        selectedStateUserCaseD = enumUserCaseDiagrame.null
                        selectedStatePolyPaintPro = enumStatePolyPaintPro.cursor
                    }
                }
                break
            case .twoWayArrow:
                if (User.shared.wifi) {
                    canvasDoAlert.doAlert(name: "Error", message: "Please go offline for lines")
                }
                else {
                    if(!firstAnchorTapped) {
                        canvasDoAlert.doAlert(name: "Error", message: "Please select an AnchorPoint")
                    }
                        
                    else if(firstAnchorTapped && !secondPointTapped) {
                        canvasDoAlert.doAlert(name: "Error", message: "Please select an other AnchorPoint")
                    }
                    else if (firstAnchorTapped && secondPointTapped) {
                        createFrameLine(dotted: false, arrow: false, heritage: false, twoWay: true, aggregation: false, composition: false, firstAnchorPointParameter: firstAnchorPointLine, secondAnchorPointParameter: secondAnchorPointLine)
                        firstAnchorTapped = false
                        secondPointTapped = false
                        for shapeUI in self.subviews {
                            if let shape = shapeUI as? ShapeView {
                                for anchorPoint in shape.anchorPoints {
                                    anchorPoint.isFirstAnchor = false
                                    anchorPoint.isSecondAnchor = false
                                }
                            }
                        }
                        selectedStateUserCaseD = enumUserCaseDiagrame.null
                        selectedStatePolyPaintPro = enumStatePolyPaintPro.cursor
                    }
                }
                break
            case .agggregation:
                if (User.shared.wifi) {
                    canvasDoAlert.doAlert(name: "Error", message: "Please go offline for lines")
                }
                else {
                    if(!firstAnchorTapped) {
                        canvasDoAlert.doAlert(name: "Error", message: "Please select an AnchorPoint")
                    }
                        
                    else if(firstAnchorTapped && !secondPointTapped) {
                        canvasDoAlert.doAlert(name: "Error", message: "Please select an other AnchorPoint")
                    }
                    else if (firstAnchorTapped && secondPointTapped) {
                        createFrameLine(dotted: false, arrow: false, heritage: false, twoWay: false, aggregation: true, composition: false, firstAnchorPointParameter: firstAnchorPointLine, secondAnchorPointParameter: secondAnchorPointLine)
                        firstAnchorTapped = false
                        secondPointTapped = false
                        for shapeUI in self.subviews {
                            if let shape = shapeUI as? ShapeView {
                                for anchorPoint in shape.anchorPoints {
                                    anchorPoint.isFirstAnchor = false
                                    anchorPoint.isSecondAnchor = false
                                }
                            }
                        }
                        selectedStateUserCaseD = enumUserCaseDiagrame.null
                        selectedStatePolyPaintPro = enumStatePolyPaintPro.cursor
                    }
                }
                break
            case .composition:
                if (User.shared.wifi) {
                    canvasDoAlert.doAlert(name: "Error", message: "Please go offline for lines")
                }
                else {
                    if(!firstAnchorTapped) {
                        canvasDoAlert.doAlert(name: "Error", message: "Please select an AnchorPoint")
                    }
                        
                    else if(firstAnchorTapped && !secondPointTapped) {
                        canvasDoAlert.doAlert(name: "Error", message: "Please select an other AnchorPoint")
                    }
                    else if (firstAnchorTapped && secondPointTapped) {
                        createFrameLine(dotted: false, arrow: false, heritage: false, twoWay: false, aggregation: false, composition: true, firstAnchorPointParameter: firstAnchorPointLine, secondAnchorPointParameter: secondAnchorPointLine)
                        firstAnchorTapped = false
                        secondPointTapped = false
                        for shapeUI in self.subviews {
                            if let shape = shapeUI as? ShapeView {
                                for anchorPoint in shape.anchorPoints {
                                    anchorPoint.isFirstAnchor = false
                                    anchorPoint.isSecondAnchor = false
                                }
                            }
                        }
                        selectedStateUserCaseD = enumUserCaseDiagrame.null
                        selectedStatePolyPaintPro = enumStatePolyPaintPro.cursor
                    }
                }
                break
            }
            break
        case .lasso:
            if (!lassoArrayCollab.isEmpty) {
                for shape in lassoArrayCollab {
                    let operationJSON: operation = operation(type: DESELECTSHAPE, shapeId: shape.shapeSwift.shapeId.value)
                    sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSON]))
                }
                lassoArrayCollab.removeAll()
                selectedStatePolyPaintPro = enumStatePolyPaintPro.cursor
            }
            else if (!lassoArray.isEmpty) {
                for shape in lassoArray {
                    shape.backgroundColor = UIColor.clear
                }
                lassoArray.removeAll()
                selectedStatePolyPaintPro = enumStatePolyPaintPro.cursor
            }
            else {
                newLassoImage = UIImageView(frame: self.frame)
                self.addSubview(newLassoImage)
                lastPoint = startingPoint
                startPointLasso = startingPoint
            }
            break
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        startingPoint = touch.location(in: self)
        let currentPoint = touch.location(in: self)
        if (selectedStatePolyPaintPro == enumStatePolyPaintPro.lasso) {
            drawCircle(from: startPointLasso, toPoint: currentPoint, image: newLassoImage, color: blackColor)
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if (selectedStatePolyPaintPro == enumStatePolyPaintPro.lasso) {
            lassoEndPoint = touch?.location(in:self)
            doLasso()
        }
    }
    
    func makeImagePNGBase64(image: UIImageView) -> String {
        UIGraphicsBeginImageContext(self.frame.size)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        guard let compressedPNGImage = UIGraphicsGetImageFromCurrentImageContext()
            else {
                return ""
        }
        UIGraphicsEndImageContext()
        let data = UIImagePNGRepresentation(compressedPNGImage)
        let pngString = data?.base64EncodedString()
        return pngString!
    }
    
    func setImportImage(imageView: UIImageView) {
        if (User.shared.wifi && !importedImage) {
            let data = UIImagePNGRepresentation(imageView.image!)
            let pngImage = data?.base64EncodedString()
            if (!(pngImage?.isEmpty)!) {
                let idJSON = id(value: "")
                let position :PositionJSON = PositionJSON(x: float_t(imageView.center.x) ,y:float_t(imageView.center.y))
                let positions : Array<PositionJSON> = [position]
                let shapeJSON =  shape(type: PICTURE, positions: positions, length: nil, width: nil, title: "", id: idJSON, author: "", className: "", attributes: "", methods: "", text: "", actorName: "", picture: pngImage, lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: idJSON.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: idJSON.value, positionOnShape: ""))
                let operationJSON = operation(type:ADDSHAPE, shape: shapeJSON, user: "")
                sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSON]))
                importedImage = true
            }
            else {
                print("ERROR IN SENDING IMAGE")
            }
        }
        else {
            let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(CanvasView.imageMoveHanddler(_:)))
            let deleteGesture = UITapGestureRecognizer(target: self, action: #selector(CanvasView.deleteTapHanddler(_:)))
            imageView.addGestureRecognizer(dragGesture)
            imageView.addGestureRecognizer(deleteGesture)
            imageView.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
            imageView.contentMode = .scaleAspectFit
            imageView.center = self.center
            imageView.isUserInteractionEnabled = true
            self.addSubview(imageView)
            //User.shared.localPictures.append(imageView)
        }
    }
    
    @objc func imageMoveHanddler(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self)
        sender.view?.center = CGPoint(x: (sender.view?.center.x)! + translation.x, y: (sender.view?.center.y)! + translation.y)
        sender.setTranslation(CGPoint.zero, in: sender.view)
    }
    
    @objc func deleteTapHanddler(_ sender:UITapGestureRecognizer){
        switch selectedStatePolyPaintPro {
        case .erase:
            sender.view!.removeFromSuperview()
            //TO DO : DELETE FROM STACK
            break
        default:
            break
        }
    }
    
    //MARK - Input AddShape
    func sendOperations(jsonDataStruct: JSONDataStruct) {
        let sent: Bool  = self.workspace.sendOperations(jsonDataStruct: jsonDataStruct)
        if (!sent) {
        }
    }
    func drawShapeLayer(){
        let shapeLayer =  CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(shapeLayer)
        self.setNeedsDisplay()
    }
    
    func clearCanvasReceived() {
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
        guard self.layer.sublayers != nil else {
            myStack.clear()
            self.setNeedsDisplay()
            return
        }
        for layer in self.layer.sublayers! {
            layer.removeFromSuperlayer()
        }
        myStack.clear()
        self.setNeedsDisplay()
    }
    
    func clearCanvasSend() {
        if (User.shared.wifi) {
            let operationReset = operation(type: RESET, shape: shape(), user: "")
            sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationReset]))
        }
        else {
            for subView in self.subviews {
                subView.removeFromSuperview()
            }
            guard self.layer.sublayers != nil else {
                myStack.clear()
                self.setNeedsDisplay()
                return
            }
            for layer in self.layer.sublayers! {
                layer.removeFromSuperlayer()
            }
            myStack.clear()
            self.setNeedsDisplay()
        }
    }
}

extension CanvasView {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CanvasView.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        self.endEditing(true)
    }
}

extension CanvasView: UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    func makeTextView(frame: CGRect) -> UITextView {
        let textField = UITextView(frame: frame)
        textField.backgroundColor = UIColor.clear
        textField.textAlignment = .center
        textField.textColor = UIColor.black
        textField.text = "Text"
        textField.font = UIFont(name: "Helvetica", size: 30)
        textField.allowsEditingTextAttributes = true
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 2.0
        textField.clearsOnInsertion = true
        textField.delegate = self
        textField.isScrollEnabled = false
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(CanvasView.handleDrag(_:)))
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(CanvasView.handdleLongPressDelete(_:)))
        longPressGesture.delegate = self
        textField.addGestureRecognizer(dragGesture)
        textField.addGestureRecognizer(longPressGesture)
        textField.addGestureRecognizer(deleteGesture)
        
        return textField
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        selectedStatePolyPaintPro = enumStatePolyPaintPro.cursor
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: self.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        let origin = self.center
        let newFrame = CGRect(origin: origin, size: estimatedSize)
        textView.frame = newFrame
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func handleDrag(_ sender: UIPanGestureRecognizer) {
        if (selectedStatePolyPaintPro == enumStatePolyPaintPro.cursor) {
            if (User.shared.wifi) {
            }
            else{
                let translation = sender.translation(in: self)
                sender.view?.center = CGPoint(x: (sender.view?.center.x)! + translation.x, y: (sender.view?.center.y)! + translation.y)
                sender.setTranslation(CGPoint.zero, in: sender.view)
            }
        }
    }
    
    @objc func handdleLongPressDelete(_ sender: UILongPressGestureRecognizer) {
        if (selectedStatePolyPaintPro == enumStatePolyPaintPro.cursor) {
            sender.view!.removeFromSuperview() //QUESTIONVINCE
        }
    }
}

extension CanvasView {
    
    //MARK: -Lasso
    func doLasso() {
        let radius = abs(lassoEndPoint.y - startPointLasso.y)
        var startPoint = CGPoint(x: 0, y: 0)
        var startPointY: CGFloat = 0
        var startPointX: CGFloat = 0
        var width: CGFloat = 0
        var height: CGFloat = 0
        if (lassoEndPoint.y > startPointLasso.y) {
            startPointY = min(startPointLasso.y,lassoEndPoint.y)
            height = (lassoEndPoint.y + radius) - startPointLasso.y
        }
        else {
            startPointY = min(startPointLasso.y,lassoEndPoint.y - radius)
            height = startPointLasso.y - (lassoEndPoint.y - radius)
        }
        if (lassoEndPoint.x > startPointLasso.x) {
            startPointX = min(startPointLasso.x, lassoEndPoint.x)
            width = (lassoEndPoint.x + radius) - startPointLasso.x
        }
        else {
            startPointX = min(startPointLasso.x, lassoEndPoint.x - radius)
            width = startPointLasso.x - (lassoEndPoint.x - radius)
        }
        startPoint = CGPoint(x: startPointX, y: startPointY)
        let size = CGSize(width: width, height: height)
        let frame = CGRect(origin: startPoint, size: size)
        let lassoView = UIView(frame: frame)
        lassoView.backgroundColor = UIColor.clear
        self.addSubview(lassoView)
        fillLasso(view: lassoView)
        newLassoImage.removeFromSuperview()
        lassoView.removeFromSuperview()
    }
    
    func fillLasso(view: UIView) {
        for shapeUI in self.subviews {
            if let shape = shapeUI as? ShapeView {
                if isInsideView(view: view, point: shape.center) {
                    if (User.shared.wifi) {
                        lassoArrayCollab.append(shape)
                    }
                    else {
                        lassoArray.append(shape)
                        shape.backgroundColor = UIColor.lightGray
                    }
                }
            }
        }
        if (User.shared.wifi) {
            for shape in lassoArrayCollab {
                let operationJSONSelect: operation = operation(type: SELECTSHAPE, shapeId: shape.shapeSwift.shapeId.value)
                sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSONSelect]))
            }
        }
    }
    
    
    func isInsideView(view: UIView, point: CGPoint)-> Bool {
        if ((view.frame.origin.x < point.x && point.x < (view.frame.origin.x + view.frame.width)) && (view.frame.origin.y < point.y && (point.y < (view.frame.origin.y + view.frame.height)))) {
            return true
        }
        else {
            return false
        }
    }
    
    func drawCircle(from: CGPoint, toPoint: CGPoint, image: UIImageView, color: CGColor) {
        UIGraphicsBeginImageContext(image.frame.size)
        guard let ctx = UIGraphicsGetCurrentContext()
            else {
                return
        }
        ctx.beginPath()
        ctx.setStrokeColor(color)
        ctx.setLineWidth(5)
        let x = startingPoint.x
        let y = startingPoint.y
        let radius: CGFloat = (from.x - toPoint.x)
        let endAngle: CGFloat = CGFloat( 2 * Double.pi)
        ctx.addArc(center: CGPoint(x: x, y: y), radius: radius, startAngle: 0, endAngle: endAngle, clockwise: true)
        ctx.strokePath()
        image.image = UIGraphicsGetImageFromCurrentImageContext()
        image.alpha = 1.0
        UIGraphicsEndImageContext()
    }
    
    //MARK: -Lines
    func createFrameLine(dotted:Bool, arrow:Bool, heritage: Bool, twoWay: Bool, aggregation:Bool, composition: Bool, firstAnchorPointParameter: AnchorPoint, secondAnchorPointParameter: AnchorPoint) {
        
//        for shapeUI in self.subviews {
//            if let shape = shapeUI as? ShapeView {
//                for anchorPoint in shape.anchorPoints {
//                    if (anchorPoint.isFirstAnchor) {
//                        firstAnchorPointParameter = anchorPoint
//                    }
//                    else if (anchorPoint.isSecondAnchor) {
//                        secondAnchorPointParameter = anchorPoint
//                    }
//                }
//            }
//        }
        firstAnchorPointParameter.backgroundColor = UIColor.black
        secondAnchorPointParameter.backgroundColor = UIColor.black
        
        let firstAnchorPoint = firstAnchorPointParameter.superview!.convert(firstAnchorPointParameter.center, to: self)
        let secondAnchorPoint = secondAnchorPointParameter.superview!.convert(secondAnchorPointParameter.center, to: self)
        let startPointY: CGFloat = min(firstAnchorPoint.y,secondAnchorPoint.y)
        let startPointX: CGFloat = min(firstAnchorPoint.x,secondAnchorPoint.x)
        let startPoint = CGPoint(x: startPointX, y: startPointY)
        var width: CGFloat = 0
        var height: CGFloat = 0
        var bottom:Bool = false
        var top:Bool = false
        var left:Bool = false
        var right:Bool = false
        if ( firstAnchorPoint.y > secondAnchorPoint.y ){
            height = firstAnchorPoint.y - secondAnchorPoint.y
            top = true
        }
        else {
            height = secondAnchorPoint.y - firstAnchorPoint.y
            bottom = true
        }
        if (firstAnchorPoint.x > secondAnchorPoint.x ) {
            width = firstAnchorPoint.x - secondAnchorPoint.x
            left = true
            
        }
        else {
            width = secondAnchorPoint.x - firstAnchorPoint.x
            right = true
        }
        let corner: cornerArrow = selectedCorner(bottom: bottom, top: top, left: left, right: right)
        if (width < 30) {
            width = 30
        }
        if (height < 30) {
            height = 30
        }
        let size = CGSize(width: width, height: height)
        let frame = CGRect(origin: startPoint, size: size)
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor.clear
        self.addSubview(view)
        let startingPointImage = firstAnchorPointParameter.superview!.convert(firstAnchorPointParameter.center, to: view)
        let endPointImage = secondAnchorPointParameter.superview!.convert(secondAnchorPointParameter.center, to: view)
        drawLine(from: startingPointImage, toPoint: endPointImage, frame: frame, color: blackColor, dotted: dotted)
        if (arrow) {
            drawArrrowHead(corner: corner, frame: frame, simple: false)
        }
        if (heritage) {
            drawArrrowHead(corner: corner, frame: frame, simple: false)
        }
        if (twoWay) {
            switch corner {
            case .bottomRight:
                drawArrrowHead(corner: corner, frame: frame, simple: false)
                drawArrrowHead(corner: cornerArrow.topLeft, frame: frame, simple: false)
                break
            case .bottomLeft:
                drawArrrowHead(corner: corner, frame: frame, simple: false)
                drawArrrowHead(corner: cornerArrow.topRight, frame: frame, simple: false)
                break
            case .topLeft:
                drawArrrowHead(corner: corner, frame: frame, simple: false)
                drawArrrowHead(corner: cornerArrow.bottomRight, frame: frame, simple: false)
                break
            case .topRight:
                drawArrrowHead(corner: corner, frame: frame, simple: false)
                drawArrrowHead(corner: cornerArrow.bottomLeft, frame: frame, simple: false)
                break
            }
        }
        if (aggregation) {
            drawDiamondHead(corner: corner, frame: frame, fill: false)
        }
        if (composition) {
             drawDiamondHead(corner: corner, frame: frame, fill: true)
        }
    }
    
    func drawLine(from: CGPoint, toPoint: CGPoint, frame: CGRect, color: CGColor, dotted: Bool) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = frame
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 5
        let lineDashPattern: [NSNumber]  = [10, 5, 5, 5]
        if (dotted) {
            shapeLayer.lineDashPattern = lineDashPattern
        }
        let path = CGMutablePath()
        path.addLines(between: [from, toPoint])
        shapeLayer.path = path
        layer.addSublayer(shapeLayer)
    }
    
    func drawArrrowHead(corner: cornerArrow, frame: CGRect, simple: Bool) {
        switch corner {
        case .bottomRight:
            let origin = CGPoint(x: frame.origin.x - 15 + frame.width, y: frame.origin.y - 15 + frame.height)
            let headFrame = CGRect(origin: origin, size: CGSize(width: HEAD_SIZE, height: HEAD_SIZE))
            let headView = ArrowHeadSwift.init(frame: headFrame, corner: corner)
            headView.backgroundColor = UIColor.clear
            self.addSubview(headView)
            break
        case .bottomLeft:
            let origin = CGPoint(x: frame.origin.x, y: frame.origin.y - 15 + frame.height)
            let headFrame = CGRect(origin: origin, size: CGSize(width: HEAD_SIZE, height: HEAD_SIZE))
            let headView = ArrowHeadSwift.init(frame: headFrame, corner: corner)
            headView.backgroundColor = UIColor.clear
            self.addSubview(headView)
            break
        case .topLeft:
            let headFrame = CGRect(origin: frame.origin, size: CGSize(width: HEAD_SIZE, height: HEAD_SIZE))
            let headView = ArrowHeadSwift.init(frame: headFrame, corner: corner)
            headView.backgroundColor = UIColor.clear
            self.addSubview(headView)
            break
        case .topRight:
            let origin = CGPoint(x: frame.origin.x - 15 + frame.width, y: frame.origin.y)
            let headFrame = CGRect(origin: origin, size: CGSize(width: HEAD_SIZE, height: HEAD_SIZE))
            let headView = ArrowHeadSwift.init(frame: headFrame, corner: corner)
            headView.backgroundColor = UIColor.clear
            self.addSubview(headView)
            break
        }
    }
    
    func drawDiamondHead(corner: cornerArrow, frame: CGRect, fill:Bool) {
        switch corner {
        case .bottomRight:
            let origin = CGPoint(x: frame.origin.x - 20 + frame.width, y: frame.origin.y - 20 + frame.height)
            let testView = UIView(frame: CGRect(origin: origin, size: CGSize(width: HEAD_SIZE, height: HEAD_SIZE)))
            if (fill) {
                testView.backgroundColor = UIColor.black
            }
            else {
                testView.layer.borderWidth = 2
                testView.layer.borderColor = UIColor.black.cgColor
            }
            self.addSubview(testView)
            break
        case .bottomLeft:
            let origin = CGPoint(x: frame.origin.x, y: frame.origin.y - 30 + frame.height)
            let testView = UIView(frame: CGRect(origin: origin, size: CGSize(width: HEAD_SIZE, height: HEAD_SIZE)))
            if (fill) {
                testView.backgroundColor = UIColor.black
            }
            else {
                testView.layer.borderWidth = 2
                testView.layer.borderColor = UIColor.black.cgColor
            }
            self.addSubview(testView)
            break
        case .topLeft:
            let testView = UIView(frame: CGRect(origin: frame.origin, size: CGSize(width: HEAD_SIZE, height: HEAD_SIZE)))
            if (fill) {
                testView.backgroundColor = UIColor.black
            }
            else {
                testView.layer.borderWidth = 2
                testView.layer.borderColor = UIColor.black.cgColor
            }
            self.addSubview(testView)
            break
        case .topRight:
            let origin = CGPoint(x: frame.origin.x - 30 + frame.width, y: frame.origin.y)
            let testView = UIView(frame: CGRect(origin: origin, size: CGSize(width: HEAD_SIZE, height: HEAD_SIZE)))
            if (fill == true) {
                testView.backgroundColor = UIColor.black
            }
            else {
                testView.layer.borderWidth = 2
                testView.layer.borderColor = UIColor.black.cgColor
            }
            self.addSubview(testView)
            break
        }
    }
    
    func selectedCorner(bottom: Bool, top:Bool, left:Bool, right:Bool)-> cornerArrow {
        if (bottom && left) {
            return cornerArrow.bottomLeft
        }
        else if (bottom && right) {
            return cornerArrow.bottomRight
        }
        else if (top && left) {
            return cornerArrow.topLeft
        }
        else {
            return cornerArrow.topRight
        }
    }
}


enum cornerArrow {
    case topLeft, topRight, bottomLeft, bottomRight
}
