//
//  PolyPaintPro.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-10-04.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import UIKit
import Alamofire

let shapeNotificationKey = "shapeHasBeenCreated"
class ToolBarSliderView: NSObject {
    var isVisible: Bool = false
    var sideView: UIView
    init (sideView: UIView){
        self.sideView = sideView
        self.sideView.isHidden = !isVisible
    }
}

var importedImage: Bool = false

class PolyPaintPro: UIViewController, UINavigationControllerDelegate {
    
    
    var shapesToolBarSliderView: ToolBarSliderView?
    var settingsToolBarSliderView:ToolBarSliderView?
    var userCaseDiagramView:ToolBarSliderView?
    var workspace = Workspace.init()
    var isPrivate:Bool!
    var isProctected:Bool!
    var isNSFW:Bool!
    var password: String!
    
    
    let isConnected = User.shared.wifi
    
    @IBOutlet weak var passwordView: RoundUIView!
    
    let blackView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTagView.isHidden = true
        shapesToolBarSliderView = ToolBarSliderView(sideView: shapesView)
        settingsToolBarSliderView = ToolBarSliderView(sideView: settingsView)
        userCaseDiagramView = ToolBarSliderView(sideView: userCaseDView)
        self.canvas.setWorkspace(workspace: self.workspace)
        Socket.shared.socketOperationDelegate = self
        Socket.shared.socketSesssionIdDelegate = self
        Socket.shared.socketSaveImageOnServerFromSocket = self
        Socket.shared.socketShapeContent = self
        Socket.shared.socketSessionEject = self
        canvas.canvasDoAlert = self
        if isPrivate != nil {
            privateToggle.isOn = isPrivate
        }
        else {
            privateToggle.isOn = false
            isPrivate = false
        }
        if isProctected != nil {
            protectedToggle.isOn = isProctected
        }
        else {
            protectedToggle.isOn = false
            isProctected = false
        }
        if isNSFW != nil {
            NSFWToggle.isOn = isNSFW
        }
        else {
            NSFWToggle.isOn = false
            isNSFW = false
        }
        if(password == nil) {
            password = ""
        }
        passwordView.isHidden = true
        checkOffline()
    }
    
    
    
    func checkOffline() {
        if (User.shared.offLineImage()) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                for shapeOFF in User.shared.localShapes {
                    switch shapeOFF.currentShapeType {
                    case 0:
                        let startingPoint = shapeOFF.frame.origin
                        let idJSON = id(value: "")
                        let position1 :PositionJSON = PositionJSON(x: float_t(startingPoint.x) ,y:float_t(startingPoint.y))
                        let position2 :PositionJSON = PositionJSON(x: float_t(startingPoint.x + 200) ,y:float_t(startingPoint.y))
                        let position3 :PositionJSON = PositionJSON(x: float_t(startingPoint.x + 200) ,y:float_t(startingPoint.y - 150))
                        let position4 :PositionJSON = PositionJSON(x: float_t(startingPoint.x) ,y:float_t(startingPoint.y - 150))
                        
                        let positions : Array<PositionJSON> = [position1,position2,position3,position4]
                        let shapeJSON: shape = shape(type:RECTANGLE, positions: positions, length:150 , width:200 , title: "", id:idJSON, author: "", className: "", attributes: "", methods: "", text: "", actorName: "", picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: idJSON.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: idJSON.value, positionOnShape: ""))
                        let operationJSON: operation = operation(type:ADDSHAPE, shape: shapeJSON, user: "")
                        self.sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSON]))
                        break
                    case 1:
                        let startingPoint = shapeOFF.frame.origin
                        let idJSON = id(value: "")
                        let position1 :PositionJSON = PositionJSON(x: float_t(startingPoint.x) ,y:float_t(startingPoint.y))
                        let position2 :PositionJSON = PositionJSON(x: float_t(startingPoint.x + 150) ,y:float_t(startingPoint.y  + 100))
                        let position3 :PositionJSON = PositionJSON(x: float_t(startingPoint.x - 150/2) ,y:float_t(startingPoint.y + 100))
                        let positions : Array<PositionJSON> = [position1,position2,position3]
                        let shapeJSON: shape = shape(type:TRIANGLE, positions: positions, length: 100, width: 150, title: "", id:idJSON, author: "", className: "", attributes: "", methods: "", text: "", actorName: "", picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: idJSON.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: idJSON.value, positionOnShape: ""))
                        let operationJSON: operation = operation(type:ADDSHAPE, shape: shapeJSON, user: "")
                        self.sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSON]))
                        break
                    case 2:
                        let startingPoint = shapeOFF.frame.origin
                        let idJSON = id(value: "")
                        let position :PositionJSON = PositionJSON(x: float_t(startingPoint.x),y:float_t(startingPoint.y))
                        let positions : Array<PositionJSON> = [position]
                        let shapeJSON: shape = shape(type:ELLIPSE, positions: positions, length: 200, width: 300, title: "", id:idJSON, author: "", className: "", attributes: "", methods: "", text: "", actorName: "", picture : "",lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: idJSON.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: idJSON.value, positionOnShape: ""))
                        let operationJSON: operation = operation(type:ADDSHAPE, shape: shapeJSON, user: "")
                        self.sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSON]))
                        break
                    default:
                        break
                    }
                }
                User.shared.localShapes = []
                
//                for picture in User.shared.localPictures {
//                    let data = UIImagePNGRepresentation(picture.image!)
//                    let pngImage = data?.base64EncodedString()
//                    if (!(pngImage?.isEmpty)!) {
//                        let idJSON = id(value: "")
//                        let position :PositionJSON = PositionJSON(x: float_t(picture.center.x) ,y:float_t(picture.center.y))
//                        let positions : Array<PositionJSON> = [position]
//                        let shapeJSON =  shape(type: PICTURE, positions: positions, length: nil, width: nil, title: "", id: idJSON, author: "", className: "", attributes: "", methods: "", text: "", actorName: "", picture: pngImage, lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: idJSON.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: idJSON.value, positionOnShape: ""))
//                        let operationJSON = operation(type:ADDSHAPE, shape: shapeJSON, user: "")
//                        self.sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSON]))
//                        importedImage = true
//                    }
//                }
//                User.shared.localPictures = []
//
//                for text in User.shared.localTexts {
//                    let startingPoint = text.frame.origin
//                    let idJSON = id(value: "")
//                    let position :PositionJSON = PositionJSON(x: float_t(startingPoint.x) ,y:float_t(startingPoint.y))
//                    let positions : Array<PositionJSON> = [position]
//                    let shapeJSON: shape = shape(type:TEXTBOX, positions: positions, length: 150, width: 200, title: "", id:idJSON, author: "", className: "", attributes: "", methods: "", text: text.text, actorName: "", picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: idJSON.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: idJSON.value, positionOnShape: ""))
//                    let operationJSON: operation = operation(type:ADDSHAPE, shape: shapeJSON, user: "")
//                    self.sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSON]))
//                }
//                User.shared.localTexts = []
//
//                for actor in User.shared.localActor {
//                    let startingPoint = actor.startingPoint
//                    let idJSON = id(value: "")
//                    let position :PositionJSON = PositionJSON(x: float_t(startingPoint!.x) ,y:float_t(startingPoint!.y))
//                    let positions : Array<PositionJSON> = [position]
//                    let shapeJSON: shape = shape(type:ACTOR, positions: positions, length: 150, width: 100, title: "", id:idJSON, author: "", className: "", attributes: "", methods: "", text: "", actorName: actor.actorName, picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: idJSON.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: idJSON.value, positionOnShape: ""))
//                    let operationJSON: operation = operation(type:ADDSHAPE, shape: shapeJSON, user: "")
//                    self.sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSON]))
//                }
//                User.shared.localActor = []
//
//                for classD in User.shared.localClassD {
//                    let startingPoint = classD.startingPoint!
//                    let idJSON = id(value: "")
//                    let position1 :PositionJSON = PositionJSON(x: float_t(startingPoint.x) ,y:float_t(startingPoint.y))
//                    let position2 :PositionJSON = PositionJSON(x: float_t(startingPoint.x + 200) ,y:float_t(startingPoint.y))
//                    let position3 :PositionJSON = PositionJSON(x: float_t(startingPoint.x + 200) ,y:float_t(startingPoint.y + 250))
//                    let position4 :PositionJSON = PositionJSON(x: float_t(startingPoint.x) ,y:float_t(startingPoint.y + 250))
//                    let positions : Array<PositionJSON> = [position1,position2,position3,position4]
//                    let shapeJSON: shape = shape(type:CLASSRECTANGLE, positions: positions, length: 400, width: 600, title: "", id:idJSON, author: "", className: "Class name", attributes: "- attribute: String", methods: "+ method(): void", text: "", actorName: "", picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: idJSON.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: idJSON.value, positionOnShape: ""))
//                    let operationJSON: operation = operation(type:ADDSHAPE, shape: shapeJSON, user: "")
//                    self.sendOperations(jsonDataStruct: JSONDataStruct( operations: [operationJSON]))
//                }
//                User.shared.localClassD = []
            }
        }
    }
        
        func sendOperations(jsonDataStruct: JSONDataStruct) {
            let sent: Bool  = self.workspace.sendOperations(jsonDataStruct: jsonDataStruct)
        }
        
        @IBOutlet weak var tagTextField: UITextField!
        @IBOutlet weak var passwordTextField: UITextField!
        @IBOutlet weak var NSFWToggle: UISwitch!
        @IBOutlet weak var settingsView: UIView!
        @IBOutlet weak var shapesView: UIView!
        @IBOutlet weak var protectedToggle: UISwitch!
        @IBOutlet weak var privateToggle: UISwitch!
        @IBOutlet weak var canvas: CanvasView!
        @IBOutlet weak var userCaseDView: UIView!
        @IBOutlet weak var addTagView: RoundUIView!
        
        func slideView(toolBarSlider: ToolBarSliderView){
            if toolBarSlider.isVisible {
                toolBarSlider.sideView.isHidden = toolBarSlider.isVisible
                toolBarSlider.isVisible = false
            } else {
                toolBarSlider.sideView.isHidden = toolBarSlider.isVisible
                toolBarSlider.isVisible = true
            }
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
            })
        }
        
        @IBAction func homeButtonTapped(_ sender: Any) {
            if (User.shared.wifi) {
                performSegue(withIdentifier: "toHomeViewFPPP", sender: self)
                self.workspace.leaveWorkspace()
            }
            else {
                performSegue(withIdentifier: "toLogInViewFPPP", sender: self)
            }
        }
        
        //MARK: -STATES
        
        func moveView(operationModifyShape: ModifyShapeSwift,canvasSubviews: [ShapeView]) {
            for shape in canvasSubviews {
                if(operationModifyShape.shape.shapeId.value == shape.shapeSwift.shapeId.value){
                    let dx: float_t = (float_t(operationModifyShape.shape.positions[0].x) - float_t(shape.shapeSwift.positions[0].x))
                    let dy: float_t = (float_t(operationModifyShape.shape.positions[0].y) - float_t(shape.shapeSwift.positions[0].y))
                    
                    shape.transform = shape.transform.translatedBy(x: CGFloat(dx), y: CGFloat(dy))
                    
                    shape.shapeSwift.positions = operationModifyShape.shape.positions
                    if(shape.shapeSwift.type == ACTOR) {
                        let actorSwift = shape.shapeSwift as! ActorSwift
                        let operationMofifyShapeActor = operationModifyShape.shape as! ActorSwift
                        actorSwift.actorName = operationMofifyShapeActor.actorName
                        let actorView: ActorView = shape as! ActorView
                        if(operationMofifyShapeActor.actorName != ""){
                            actorView.actorNameTextUIView.text = operationMofifyShapeActor.actorName
                        }
                    }
                    
                    if(shape.shapeSwift.type == CLASSRECTANGLE){
                        var classRectangleSwift = shape.shapeSwift as! ClassRectangleSwift
                        var operationMofifyShapeClassRectangle = operationModifyShape.shape as! ClassRectangleSwift
                        classRectangleSwift = operationMofifyShapeClassRectangle
                        let classView: ClassView = shape as! ClassView
                        var indexPath = NSIndexPath(row: 0, section: 0)
                        let cellClassName = classView.methodsTable.cellForRow(at: indexPath as IndexPath) as! ClassCell
                        indexPath = NSIndexPath(row: 1, section: 0)
                        let cellAttributs = classView.methodsTable.cellForRow(at: indexPath as IndexPath) as! ClassCell
                        indexPath = NSIndexPath(row: 2, section: 0)
                        let cellMethode = classView.methodsTable.cellForRow(at: indexPath as IndexPath) as! ClassCell
                        cellClassName.textField.text = classRectangleSwift.className
                        cellAttributs.textField.text = classRectangleSwift.attributes
                        cellMethode.textField.text = classRectangleSwift.methods
                    }
                    
                    if(shape.shapeSwift.type == TEXTBOX){
                        let textBoxSwift = shape.shapeSwift as! TextBoxSwift
                        let operationMofifyShapeActor = operationModifyShape.shape as! TextBoxSwift
                        textBoxSwift.text = operationMofifyShapeActor.text
                        let textBoxView: TextBoxView = shape as! TextBoxView
                        textBoxView.textBoxUIView.text = operationMofifyShapeActor.text
                    }
                    
                    if(shape.shapeSwift.type == ELLIPSE){
                        
                        
                        let ellipseSwift = shape.shapeSwift as! EllipseSwift
                        let operationMofifyShapeEllipse = operationModifyShape.shape as! EllipseSwift
                        if(!operationMofifyShapeEllipse.title.isEmpty){
                            
                            ellipseSwift.title = operationMofifyShapeEllipse.title
                            let ellipseView = shape as! UseCase
                            ellipseView.useCaseTextUIView.text = operationMofifyShapeEllipse.title
                        }
                    }
                    
                }
            }
        }
        
        @IBAction func shapesTapped(_ sender: UIButton) {
            selectedStatePolyPaintPro = enumStatePolyPaintPro.shapes
            slideView(toolBarSlider: shapesToolBarSliderView!)
        }
        
        @IBAction func ellipseButtonTapped(_ sender: UIButton) {
            selectedShapeButton = enumShapes.ellipse
            slideView(toolBarSlider: shapesToolBarSliderView!)
            Sounds.shared.playSounds(fileName:"Ping")
        }
        
        @IBAction func triangleButtonTapped(_ sender: UIButton) {
            selectedShapeButton = enumShapes.triangle
            slideView(toolBarSlider: shapesToolBarSliderView!)
            Sounds.shared.playSounds(fileName:"Ping")
        }
        
        @IBAction func exportButtonTapped(_ sender: UIButton) {
            CameraHandler.shared.saveImage(image: self.canvas)
            Alert.showBasic(title: "Saved !", message: "You've saved your image", vc: self)
        }
        
        @IBAction func lineButtonTapped(_ sender: UIButton) {
            selectedShapeButton = enumShapes.line
            slideView(toolBarSlider: shapesToolBarSliderView!)
        }
        
        @IBAction func arrowButtonTapped(_ sender: UIButton) {
            selectedShapeButton = enumShapes.arrow
            slideView(toolBarSlider: shapesToolBarSliderView!)
        }
        
        @IBAction func rectangleButtonTapped(_ sender: UIButton) {
            selectedShapeButton = enumShapes.rectangle
            slideView(toolBarSlider: shapesToolBarSliderView!)
            Sounds.shared.playSounds(fileName:"Ping")
        }
        
        @IBAction func duplicatButtonTapped(_ sender: UIButton) {
            selectedStatePolyPaintPro = enumStatePolyPaintPro.duplicate
        }
        @IBAction func cursorTapped(_ sender: Any) {
            selectedStatePolyPaintPro = enumStatePolyPaintPro.cursor
        }
        
        @IBAction func cutButtonTapped(_ sender: UIButton) {
            selectedStatePolyPaintPro = enumStatePolyPaintPro.cut
        }
        
        @IBAction func pasteButtonTapped(_ sender: Any) {
            selectedStatePolyPaintPro = enumStatePolyPaintPro.paste
        }
        
        @IBAction func eraseButtonTapped(_ sender: UIButton) {
            selectedStatePolyPaintPro = enumStatePolyPaintPro.erase
        }
        
        @IBAction func labelButtonTapped(_ sender: UIButton) {
            selectedStatePolyPaintPro = enumStatePolyPaintPro.label
        }
        
        @IBAction func leftArrowTapped(_ sender: Any) {
            selectedStatePolyPaintPro = enumStatePolyPaintPro.stackPut
        }
        
        @IBAction func rightArrowTapped(_ sender: Any) {
            selectedStatePolyPaintPro = enumStatePolyPaintPro.stackPop
        }
        
        @IBAction func classDiagramTapped(_ sender: Any) {
            selectedStatePolyPaintPro = enumStatePolyPaintPro.classD
        }
        
        @IBAction func userCaseDiagramTapped(_ sender: Any) {
            selectedStatePolyPaintPro = enumStatePolyPaintPro.userD
            slideView(toolBarSlider: userCaseDiagramView!)
        }
        
        @IBAction func lassoTapped(_ sender: Any) {
            selectedStatePolyPaintPro = enumStatePolyPaintPro.lasso
        }
        
        
        
        //MARK:- Not in States
        
        @IBAction func importImageButtonTapped(_ sender: UIButton) {
            CameraHandler.shared.showActionSheet(vc: self)
            CameraHandler.shared.imagePickedBlock = { (image) in
                let imageView = UIImageView(image: image)
                self.canvas.setImportImage(imageView: imageView)
            }
        }
        
        @IBAction func settingsTapped(_ sender: Any) {
            slideView(toolBarSlider: settingsToolBarSliderView!)
        }
        @IBAction func clearButtonTapped(_ sender: Any) {
            self.canvas.clearCanvasSend()
        }
        
        // User Case Diagram
        
        @IBAction func actorTapped(_ sender: Any) {
            slideView(toolBarSlider: userCaseDiagramView!)
            selectedStateUserCaseD = enumUserCaseDiagrame.actor
        }
        
        @IBAction func userCaseDArrowTapped(_ sender: Any) {
            slideView(toolBarSlider: userCaseDiagramView!)
            selectedStateUserCaseD = enumUserCaseDiagrame.arrow
        }
        
        @IBAction func dottedTapped(_ sender: Any) {
            slideView(toolBarSlider: userCaseDiagramView!)
            selectedStateUserCaseD = enumUserCaseDiagrame.dotted
        }
        
        @IBAction func heritageTapped(_ sender: Any) {
            slideView(toolBarSlider: userCaseDiagramView!)
            selectedStateUserCaseD = enumUserCaseDiagrame.heritage
        }
        
        @IBAction func twoWayTapped(_ sender: Any) {
            slideView(toolBarSlider: userCaseDiagramView!)
            selectedStateUserCaseD = enumUserCaseDiagrame.twoWayArrow
        }
        
        @IBAction func aggregationTapped(_ sender: Any) {
            slideView(toolBarSlider: userCaseDiagramView!)
            selectedStateUserCaseD = enumUserCaseDiagrame.agggregation
        }
        
        @IBAction func compositionTapped(_ sender: Any) {
            slideView(toolBarSlider: userCaseDiagramView!)
            selectedStateUserCaseD = enumUserCaseDiagrame.composition
        }
        
        @IBAction func lineTapped(_ sender: Any) {
            slideView(toolBarSlider: userCaseDiagramView!)
            selectedStateUserCaseD = enumUserCaseDiagrame.line
        }
        
        @IBAction func useCaseTapped(_ sender: Any) {
            slideView(toolBarSlider: userCaseDiagramView!)
            selectedStateUserCaseD = enumUserCaseDiagrame.userCase
        }
        
        
        
        //Toggles
        
        @IBAction func protectedToggleTapped(_ sender: Any) {
            isProctected = protectedToggle.isOn
            if (isProctected) {
                if let window = UIApplication.shared.keyWindow {
                    self.blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
                    window.addSubview(blackView)
                    self.blackView.frame = window.frame
                    self.blackView.alpha = 0
                    UIView.animate(withDuration: 0.5, animations: {
                        self.blackView.alpha = 1
                        window.addSubview(self.passwordView)
                        self.passwordView.isHidden = false
                    })
                }
            }
            else {
                password = ""
                postImageSettingsToServer(isPrivate: isPrivate, isProctected: isProctected, password: password, isNSFW: isNSFW) { error in
                    if let error = error {
                        Alert.showBasic(title: "Error", message: "You did not save the image", vc: self)
                        fatalError(error.localizedDescription)
                    }
                }
            }
        }
        
        @IBAction func newPasswordGoTapped(_ sender: Any) {
            if (!(passwordTextField.text?.isEmpty)!) {
                password = passwordTextField.text!
                UIView.animate(withDuration: 0.5) {
                    self.passwordView.isHidden = true
                    self.blackView.alpha = 0
                }
                postImageSettingsToServer(isPrivate: isPrivate, isProctected: isProctected, password: password, isNSFW: isNSFW) { error in
                    if let error = error {
                        Alert.showBasic(title: "Error", message: "You did not save the image", vc: self)
                        self.protectedToggle.isOn = false
                        self.isProctected = false
                        fatalError(error.localizedDescription)
                    }
                }
            }
            else {
                Alert.showBasic(title: "Empty Name", message: "Please enter a name", vc: self)
            }
        }
        
        
        @IBAction func newPasswordExitTapped(_ sender: Any) {
            UIView.animate(withDuration: 0.5) {
                self.passwordView.isHidden = true
                self.blackView.alpha = 0
            }
            password = ""
        }
        
        @IBAction func privateToggleTapped(_ sender: Any) {
            let tmpBool : Bool = protectedToggle.isOn
            isPrivate = tmpBool
            postImageSettingsToServer(isPrivate: isPrivate, isProctected: isProctected, password: password, isNSFW: isNSFW) { error in
                if let error = error {
                    Alert.showBasic(title: "Error", message: "You did not save the image", vc: self)
                    self.isPrivate = !tmpBool
                    self.protectedToggle.isOn = !tmpBool
                    fatalError(error.localizedDescription)
                }
            }
            
        }
        
        @IBAction func NSFWToggleTapped(_ sender: Any) {
            let tmpBool : Bool = NSFWToggle.isOn
            isNSFW = NSFWToggle.isOn
            postImageSettingsToServer(isPrivate: isPrivate, isProctected: isProctected, password: password, isNSFW: isNSFW) { error in
                if let error = error {
                    Alert.showBasic(title: "Error", message: "You did not save the image", vc: self)
                    self.isNSFW = !tmpBool
                    self.NSFWToggle.isOn = !tmpBool
                    fatalError(error.localizedDescription)
                }
            }
        }
        
        @IBAction func addTagTapped(_ sender: Any) {
            slideView(toolBarSlider: settingsToolBarSliderView!)
            self.blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            self.view.addSubview(blackView)
            self.blackView.frame = self.view.frame
            self.blackView.alpha = 0
            UIView.animate(withDuration: 0.5, animations: {
                self.blackView.alpha = 1
                self.view.addSubview(self.addTagView)
                self.addTagView.isHidden = false
            })
        }
        
        @IBAction func addTagDismissTapped(_ sender: Any) {
            UIView.animate(withDuration: 0.5) {
                self.addTagView.isHidden = true
                self.blackView.alpha = 0
            }
            tagTextField.text = ""
        }
        
        @IBAction func addTagGoTapped(_ sender: Any) {
            if (!(tagTextField.text!.isEmpty)) {
                postTagToServer(tag: tagTextField.text!){ error in
                    if let error = error {
                        Alert.showBasic(title: "Error", message: "You did not save the tag", vc: self)
                        fatalError(error.localizedDescription)
                    }
                    else {
                        UIView.animate(withDuration: 0.5) {
                            self.addTagView.isHidden = true
                            self.blackView.alpha = 0
                        }
                        self.tagTextField.text = ""
                    }
                }
            }
            else {
                Alert.showBasic(title: "Empty Name", message: "Please enter a tag", vc: self)
            }
        }
        
        func saveImageToServer() {
            UIGraphicsBeginImageContext(self.canvas.frame.size)
            self.canvas.layer.render(in: UIGraphicsGetCurrentContext()!)
            guard let compressedPNGImage = UIGraphicsGetImageFromCurrentImageContext()
                else {
                    Alert.showBasic(title: "ERROR", message: "Cannot Save Image", vc: self)
                    return
            }
            UIGraphicsEndImageContext()
            let data = UIImagePNGRepresentation(compressedPNGImage)
            let pngString = data?.base64EncodedString()
            postImageToServer(imageId: self.workspace.sessionID, pngImage: pngString!){ error in
                if let error = error {
                    Alert.showBasic(title: "Error", message: "You did not save the image", vc: self)
                    fatalError(error.localizedDescription)
                }
            }
        }
        
        func postImageToServer(imageId: String, pngImage: String, completion: @escaping (Error?) -> Void) {
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = "project3server.herokuapp.com"
            urlComponents.path = "/api/accounts/image/" + imageId
            guard let url = urlComponents.url
                else {
                    print("Could not create URL from components")
                    return
            }
            let parameters = ["pngImage": pngImage] as [String : Any]
            let headers: HTTPHeaders = [ "Authorization": User.shared.token]
            //REQUEST CREATION
            Alamofire.request(url,
                              method: .put,
                              parameters: parameters,
                              headers: headers)
                .validate()
                .responseJSON { response in
                    guard response.result.isSuccess else {
                        print("Error while getting response")
                        Alert.showBasic(title: "Error", message: "Error in sending image, please check your internet conection", vc: self)
                        return
                    }
                    guard let value = response.result.value as? [String: Any]
                        else {
                            print("ERROR IN RESPONSE")
                            return
                    }
                    var Message:String = ""
                    if let message = value["message"] as? String {
                        Message = message
                    }
                    if let success = value["success"] as? Bool {
                        if (!success) {
                            Alert.showBasic(title: "Error, you can't do that !", message: Message, vc: self)
                        }
                    }
            }
            completion(nil)
        }
        func postImageSettingsToServer(isPrivate: Bool, isProctected: Bool, password: String, isNSFW: Bool,  completion: @escaping (Error?) -> Void) {
            let imageId = self.workspace.sessionID
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = "project3server.herokuapp.com"
            urlComponents.path = "/api/accounts/image/" + imageId
            guard let url = urlComponents.url
                else {
                    print("Could not create URL from components")
                    return
            }
            let parameters = ["isPrivate" : isPrivate, "protection": isProctected, "password": password, "isBlurred": isNSFW] as [String : Any]
            let headers: HTTPHeaders = [ "Authorization": User.shared.token]
            //REQUEST CREATION
            var Message:String = ""
            Alamofire.request(url,
                              method: .put,
                              parameters: parameters,
                              headers: headers)
                .validate()
                .responseJSON { response in
                    guard response.result.isSuccess else {
                        print("Error while getting response")
                        Alert.showBasic(title: "Error", message: "Error in sending image, please check your internet conection", vc: self)
                        return
                    }
                    guard let value = response.result.value as? [String: Any]
                        else {
                            print("ERROR IN RESPONSE")
                            return
                    }
                    
                    if let message = value["message"] as? String {
                        Message = message
                    }
                    if let success = value["success"] as? Bool {
                        if (!success) {
                            Alert.showBasic(title: "Error, you can't do that !", message: Message, vc: self)
                        }
                    }
            }
            Alert.showBasic(title: "Success", message: Message, vc: self)
            completion(nil)
        }
        
        func postTagToServer(tag: String,  completion: @escaping (Error?) -> Void) {
            let imageId = self.workspace.sessionID
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = "project3server.herokuapp.com"
            urlComponents.path = "/api/accounts/image/" + imageId
            guard let url = urlComponents.url
                else {
                    print("Could not create URL from components")
                    return
            }
            let parameters = ["tags": tag] as [String : Any]
            let headers: HTTPHeaders = [ "Authorization": User.shared.token]
            //REQUEST CREATION
            var Message:String = ""
            Alamofire.request(url,
                              method: .put,
                              parameters: parameters,
                              headers: headers)
                .validate()
                .responseJSON { response in
                    guard response.result.isSuccess else {
                        print("Error while getting response")
                        Alert.showBasic(title: "Error", message: "Error in sending image, please check your internet conection", vc: self)
                        return
                    }
                    guard let value = response.result.value as? [String: Any]
                        else {
                            print("ERROR IN RESPONSE")
                            return
                    }
                    
                    if let message = value["message"] as? String {
                        Message = message
                    }
                    if let success = value["success"] as? Bool {
                        if (!success) {
                            Alert.showBasic(title: "Error, you can't do that !", message: Message, vc: self)
                        }
                    }
            }
            completion(nil)
        }
    }
    
    
    extension PolyPaintPro: SocketOperationDelegate {
        func receivedOperations(operation: OperationSwift) {
            switch operation.type{
            case SELECTSHAPE:
                let operationSelectShape = operation as! SelectShape
                let canvasSubviews = canvas.subviews as! [ShapeView]
                for shape in canvasSubviews {
                    if(operationSelectShape.shapeId == shape.shapeSwift.shapeId.value){
                        selectedShape = shape
                        isSelectedShape = true
                        shape.backgroundColor = UIColor.lightGray
                    }
                }
            case ERASESHAPE:
                let operationSelectShape = operation as! EraseShape
                let canvasSubviews = canvas.subviews as! [ShapeView]
                for shape in canvasSubviews {
                    if(operationSelectShape.shapeId == shape.shapeSwift.shapeId.value){
                        shape.removeFromSuperview()
                    }
                }
            case DESELECTSHAPE:
                let operationSelectShape = operation as! DeselectShape
                let canvasSubviews = canvas.subviews as! [ShapeView]
                if(!canvasSubviews.isEmpty){
                    for shape in canvasSubviews {
                        if(operationSelectShape.shapeId == shape.shapeSwift.shapeId.value){
                            shape.backgroundColor = UIColor.clear
                            selectedShape = nil
                            isSelectedShape = false
                        }
                        if(shape.shapeSwift.type == CLASSRECTANGLE){
                            shape.backgroundColor = UIColor.red
                        }
                    }
                }
            case MODIFYSHAPE:
                let operationModifyShape = operation as! ModifyShapeSwift
                let canvasSubviews = canvas.subviews as! [ShapeView]
                switch operationModifyShape.shape.type {
                case ELLIPSE, RECTANGLE, TRIANGLE, ACTOR, CLASSRECTANGLE, TEXTBOX, PICTURE:
                    self.moveView(operationModifyShape: operationModifyShape, canvasSubviews: canvasSubviews)
                    
                    
                default:
                    break
                }
            case RESET:
                let canvasSubviews = canvas.subviews as! [ShapeView]
                for shape in canvasSubviews {
                    shape.removeFromSuperview()
                }
            case ADDSHAPE:
                let operationAddShape = operation as! AddShapeSwift
                let shape = operationAddShape.shape
                switch shape.type{
                case ACTOR :
                    let shapeActorSwift = shape as! ActorSwift
                    let frame = CGRect(x: shapeActorSwift.positions[0].x, y: shapeActorSwift.positions[0].y, width: shapeActorSwift.width, height: shapeActorSwift.length)
                    let newActor = ActorView(frame: frame , shape: 10, startingPoint: shapeActorSwift.positions[0], workspace: self.canvas.workspace, shapeSwift : shapeActorSwift)
                    self.canvas.addSubview(newActor)
                    selectedStatePolyPaintPro = enumStatePolyPaintPro.cursor
                case CLASSRECTANGLE :
                    let shapeClassRectangleSwift = shape as! ClassRectangleSwift
                    let frame = CGRect(x: shapeClassRectangleSwift.positions[0].x, y: shapeClassRectangleSwift.positions[0].y, width: abs(shapeClassRectangleSwift.positions[1].x - shapeClassRectangleSwift.positions[0].x) , height: abs(shapeClassRectangleSwift.positions[1].y - shapeClassRectangleSwift.positions[2].y) )
                    let newClassView = ClassView(frame: frame , shape: 10, startingPoint: shapeClassRectangleSwift.positions[0], workspace: self.canvas.workspace, shapeSwift : shapeClassRectangleSwift)
                    newClassView.setClassName(className: shapeClassRectangleSwift.className)
                    newClassView.backgroundColor? = UIColor.red
                    self.canvas.addSubview(newClassView)
                    selectedStatePolyPaintPro = enumStatePolyPaintPro.cursor
                case ELLIPSE :
                    let shapeEllipseSwift = shape as! EllipseSwift
                    if (shapeEllipseSwift.title.isEmpty) {
                        canvas.createShapeUIViewOnline(positions: shapeEllipseSwift.positions, width: shapeEllipseSwift.width, height: shapeEllipseSwift.length, shapeSwift: shapeEllipseSwift, shape: 2)
                    }
                    else {
                        let frame = CGRect(x: shapeEllipseSwift.positions[0].x, y: shapeEllipseSwift.positions[0].y , width: shapeEllipseSwift.width, height: shapeEllipseSwift.length)
                        let newUseCase = UseCase(frame: frame , shape: 2, startingPoint: shapeEllipseSwift.positions[0], workspace: self.canvas.workspace, shapeSwift : shapeEllipseSwift)
                        self.canvas.addSubview(newUseCase)
                    }
                case RECTANGLE:
                    let shapeRectangleSwift = shape as! RectangleSwift
                    canvas.createShapeUIViewOnline(positions: shapeRectangleSwift.positions, width: shapeRectangleSwift.width, height: shapeRectangleSwift.length, shapeSwift: shapeRectangleSwift, shape: 0)
                case TEXTBOX:
                    let shapeTextBoxSwift = shape as! TextBoxSwift
                    canvas.hideKeyboardWhenTappedAround()
                    let frame = CGRect(x: shapeTextBoxSwift.positions[0].x, y:  shapeTextBoxSwift.positions[0].y, width: shapeTextBoxSwift.width, height: shapeTextBoxSwift.length )
                    let newText = TextBoxView(frame: frame , shape: 10, startingPoint: shapeTextBoxSwift.positions[0], workspace: self.canvas.workspace, shapeSwift : shapeTextBoxSwift)
                    canvas.addSubview(newText)
                    selectedStatePolyPaintPro = enumStatePolyPaintPro.cursor // TODO CREATE THE TEXTBOX
                case TRIANGLE:
                    
                    let shapeTriangleSwift = shape as! TriangleSwift
                    if(shapeTriangleSwift.positions[0].y < shapeTriangleSwift.positions[1].y) {
                        canvas.createShapeUIViewOnline(positions: shapeTriangleSwift.positions, width: shapeTriangleSwift.width,height: shapeTriangleSwift.length,shapeSwift: shapeTriangleSwift, shape: 1)
                    }
                    else if (shapeTriangleSwift.positions[0].y > shapeTriangleSwift.positions[1].y){
                        canvas.createShapeUIViewOnline(positions: shapeTriangleSwift.positions, width: shapeTriangleSwift.width,height: shapeTriangleSwift.length,shapeSwift: shapeTriangleSwift, shape: 5)
                    }
                    
                case PICTURE:
                    let shapePictureSwift = shape as! PictureSwift
                    let frame = CGRect(x: shapePictureSwift.positions[0].x, y: shapePictureSwift.positions[0].y, width: 200, height: 200)
                    let newPictureSwift = PictureView(frame: frame , shape: 10, startingPoint: shapePictureSwift.positions[0], workspace: self.canvas.workspace, shapeSwift : shapePictureSwift)
                    var pngImage:UIImage!
                    if ( !shapePictureSwift.picture.isEmpty) {
                        let dataDecoded:NSData = NSData(base64Encoded: shapePictureSwift.picture, options: NSData.Base64DecodingOptions(rawValue: 0))!
                        pngImage = UIImage(data: dataDecoded as Data)!
                    }
                    newPictureSwift.setImage(image: pngImage)
                    self.canvas.addSubview(newPictureSwift)
                    selectedStatePolyPaintPro = enumStatePolyPaintPro.cursor
                    break
                default:
                    break
                    
                }
            case RESET:
                self.canvas.clearCanvasReceived()
            default:
                break
            }
        }
    }
    
    extension PolyPaintPro: SocketShapeContent {
        func loadImageContent(shapes: [ShapesSwift]) {
            for shape in shapes {
                switch shape.type{
                case ACTOR :
                    let shapeActorSwift = shape as! ActorSwift
                    let frame = CGRect(x: shapeActorSwift.positions[0].x, y: shapeActorSwift.positions[0].y, width: shapeActorSwift.width, height: shapeActorSwift.length)
                    let newActor = ActorView(frame: frame , shape: 10, startingPoint: shapeActorSwift.positions[0], workspace: self.canvas.workspace, shapeSwift : shapeActorSwift)
                    self.canvas.addSubview(newActor)
                    selectedStatePolyPaintPro = enumStatePolyPaintPro.cursor
                case CLASSRECTANGLE :
                    let shapeClassRectangleSwift = shape as! ClassRectangleSwift
                    let frame = CGRect(x: shapeClassRectangleSwift.positions[0].x, y: shapeClassRectangleSwift.positions[0].y, width: abs(shapeClassRectangleSwift.positions[1].x - shapeClassRectangleSwift.positions[0].x) , height: abs(shapeClassRectangleSwift.positions[1].y - shapeClassRectangleSwift.positions[2].y) )
                    let newClassView = ClassView(frame: frame , shape: 10, startingPoint: shapeClassRectangleSwift.positions[0], workspace: self.canvas.workspace, shapeSwift : shapeClassRectangleSwift)
                    newClassView.setClassName(className: shapeClassRectangleSwift.className)
                    var indexPath = NSIndexPath(row: 0, section: 0)
                    let cellClassName = newClassView.methodsTable.cellForRow(at: indexPath as IndexPath) as! ClassCell
                    indexPath = NSIndexPath(row: 1, section: 0)
                    let cellAttributs = newClassView.methodsTable.cellForRow(at: indexPath as IndexPath) as! ClassCell
                    indexPath = NSIndexPath(row: 2, section: 0)
                    let cellMethode = newClassView.methodsTable.cellForRow(at: indexPath as IndexPath) as! ClassCell
                    cellClassName.textField.text = shapeClassRectangleSwift.className
                    cellAttributs.textField.text = shapeClassRectangleSwift.attributes
                    cellMethode.textField.text = shapeClassRectangleSwift.methods
                    newClassView.backgroundColor? = UIColor.red
                    self.canvas.addSubview(newClassView)
                    selectedStatePolyPaintPro = enumStatePolyPaintPro.cursor
                case ELLIPSE :
                    let shapeEllipseSwift = shape as! EllipseSwift
                    if(shapeEllipseSwift.title.isEmpty){
                        canvas.createShapeUIViewOnline(positions: shapeEllipseSwift.positions, width: shapeEllipseSwift.width, height: shapeEllipseSwift.length, shapeSwift: shapeEllipseSwift, shape: 2)}
                    else{
                        let frame = CGRect(x: shapeEllipseSwift.positions[0].x, y: shapeEllipseSwift.positions[0].y , width: shapeEllipseSwift.width, height: shapeEllipseSwift.length)
                        let newUseCase = UseCase(frame: frame , shape: 2, startingPoint: shapeEllipseSwift.positions[0], workspace: self.canvas.workspace, shapeSwift : shapeEllipseSwift)
                        self.canvas.addSubview(newUseCase)
                    }
                case RECTANGLE:
                    let shapeRectangleSwift = shape as! RectangleSwift
                    canvas.createShapeUIViewOnline(positions: shapeRectangleSwift.positions, width: shapeRectangleSwift.width, height: shapeRectangleSwift.length, shapeSwift: shapeRectangleSwift, shape: 0)
                case TRIANGLE:
                    let shapeTriangleSwift = shape as! TriangleSwift
                    if(shapeTriangleSwift.positions[0].y < shapeTriangleSwift.positions[1].y) {
                        canvas.createShapeUIViewOnline(positions: shapeTriangleSwift.positions, width: shapeTriangleSwift.width,height: shapeTriangleSwift.length,shapeSwift: shapeTriangleSwift, shape: 1)
                    }
                    else if (shapeTriangleSwift.positions[0].y > shapeTriangleSwift.positions[1].y){
                        canvas.createShapeUIViewOnline(positions: shapeTriangleSwift.positions, width: shapeTriangleSwift.width,height: shapeTriangleSwift.length,shapeSwift: shapeTriangleSwift, shape: 5)
                    }
                case PICTURE:
                    let shapePictureSwift = shape as! PictureSwift
                    let frame = CGRect(x: shapePictureSwift.positions[0].x, y: shapePictureSwift.positions[0].y, width: 200, height: 200)
                    let newPictureSwift = PictureView(frame: frame , shape: 10, startingPoint: shapePictureSwift.positions[0], workspace: self.canvas.workspace, shapeSwift : shapePictureSwift)
                    var pngImage:UIImage!
                    if ( !shapePictureSwift.picture.isEmpty) {
                        let dataDecoded:NSData = NSData(base64Encoded: shapePictureSwift.picture, options: NSData.Base64DecodingOptions(rawValue: 0))!
                        pngImage = UIImage(data: dataDecoded as Data)!
                    }
                    newPictureSwift.setImage(image: pngImage)
                    self.canvas.addSubview(newPictureSwift)
                    selectedStatePolyPaintPro = enumStatePolyPaintPro.cursor
                    break
                case TEXTBOX:
                    let shapeTextBoxSwift = shape as! TextBoxSwift
                    canvas.hideKeyboardWhenTappedAround()
                    let frame = CGRect(x: shapeTextBoxSwift.positions[0].x, y:  shapeTextBoxSwift.positions[0].y, width: shapeTextBoxSwift.width, height: shapeTextBoxSwift.length)
                    let newText = TextBoxView(frame: frame , shape: 10, startingPoint: shapeTextBoxSwift.positions[0], workspace: self.canvas.workspace, shapeSwift : shapeTextBoxSwift)
                    canvas.addSubview(newText)
                    selectedStatePolyPaintPro = enumStatePolyPaintPro.cursor
                default:
                    break
                }
            }
        }
    }
    
    extension PolyPaintPro: SocketSessionIDDelegate {
        func setSessionId(sessionId: String) {
            self.workspace.setSessionId(sessionId: sessionId)
        }
    }
    extension PolyPaintPro: SocketSaveImageOnSaverDelegate {
        func saveImageOnServerFromSocket() {
            self.saveImageToServer()
        }
    }
    
    extension PolyPaintPro: CanvasDoAlert {
        func doAlert(name: String, message: String) {
            Alert.showBasic(title: name, message: message, vc: self)
        }
    }
    
    extension PolyPaintPro: SocketSessionEject {
        func ejectUser() {
            Alert.showBasic(title: "Alert !", message: "You've been ejected from this session", vc: self)
            self.dismiss(animated: true) {
                self.performSegue(withIdentifier: "toHomeViewFPPP", sender: self)
                self.workspace.leaveWorkspace()
            }
        }
}






