////
////  arrowShape.swift
////  Prototype_IOS
////
////  Created by Vincent Dandenault on 2018-11-16.
////  Copyright © 2018 Vincent Dandenault. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//class ArrowShape: UIView {
//
//    var startingPoint:CGPoint!
//    var arrowHead: CGPoint!
//    var initialWidth: CGFloat!
//    var initialHeight: CGFloat!
//    var lineColor:UIColor! = UIColor.black
//    var lineWidth:CGFloat! = 10
//    var path:UIBezierPath!
//    var anchorPoints:[AnchorPoint] = []
//
//
//    init(frame: CGRect, startingPoint:CGPoint) {
//        super.init(frame: frame)
//        self.backgroundColor = UIColor.clear
//        self.startingPoint = startingPoint
//        self.isUserInteractionEnabled = true
//
//        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ArrowShape.handdleLongPress(_:)))
//        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(ArrowShape.handdleDrag(_:)))
//        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(ArrowShape.handdleDoubleTap(_:)))
//        doubleTap.numberOfTapsRequired = 2
//        let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(ArrowShape.handdlePinch(_ :)))
//        self.addGestureRecognizer(pinchGR)
//        self.addGestureRecognizer(doubleTap)
//        self.addGestureRecognizer(longPress)
//        self.addGestureRecognizer(dragGesture)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func drawArrow() {
//        guard let ctx = UIGraphicsGetCurrentContext() else { return }
//        ctx.beginPath()
//        ctx.move(to: CGPoint(x: 5, y: 35))
//        ctx.addLine(to: CGPoint(x: 145, y: 35))
//        ctx.move(to: CGPoint(x: 143, y: 35))
//        ctx.addLine(to: CGPoint(x: 120, y: 15))
//        ctx.move(to: CGPoint(x: 143, y: 35))
//        ctx.addLine(to: CGPoint(x: 120, y: 55))
//        ctx.setLineWidth(5)
//        ctx.strokePath()
//    }
//
//     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let ctx = UIGraphicsGetCurrentContext() else { return }
//        ctx.beginPath()
//        ctx.addLine(to: toPoint)
//        ctx.setLineCap(.round)
//        ctx.setBlendMode(.normal)
//        let color = UIColor.blue
//        let brushWidth: CGFloat = 10.0
//        ctx.setLineWidth(brushWidth)
//        ctx.setStrokeColor(color.cgColor)
//
//    }
//
//    func drawLine(rom fromPoint: CGPoint, to toPoint: CGPoint)
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else {
//            return
//        }
//        startingPoint = touch.location(in: self)
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let touch = touches.first
//        endPoint = touch?.location(in:self)
//    }
//}
//
//extension ArrowShape {
//    //HANDDLERS
//
//    //SELECTION
//    @objc func handdleLongPress(_ sender: UILongPressGestureRecognizer) {
//        if (selectedStatePolyPaintPro == enumStatePolyPaintPro.cursor && !isSelectedShape) {
////            isSelectedShape = true
////            selectedShape = self
//            sender.view?.backgroundColor = UIColor(red: 0.5569, green: 0.6706, blue: 0.8078, alpha: 1.0)
//        }
//    }
//
//    //MOVE
//    @objc func handdleDrag(_ sender: UIPanGestureRecognizer) {
//        if (selectedStatePolyPaintPro == enumStatePolyPaintPro.cursor) {
//            let translation = sender.translation(in: self)
//            sender.view?.center = CGPoint(x: (sender.view?.center.x)! + translation.x, y: (sender.view?.center.y)! + translation.y)
//            sender.setTranslation(CGPoint.zero, in: sender.view)
//        }
//    }
//
//    //ROTATION
//    @objc func handdleDoubleTap( _ sender: UITapGestureRecognizer) {
//        if (selectedStatePolyPaintPro == enumStatePolyPaintPro.cursor ) {
//            let rotationAngle: CGFloat = 1.5708
//            sender.view?.transform = (sender.view?.transform.rotated(by: rotationAngle))!
//        }
//    }
//    //PinchBigger
//    @objc func handdlePinch(_ sender: UIPinchGestureRecognizer) {
//        self.superview!.bringSubview(toFront: self)
//        let scale = sender.scale
//        self.transform = CGAffineTransform.init(scaleX: scale, y: scale)
//    }
//}

