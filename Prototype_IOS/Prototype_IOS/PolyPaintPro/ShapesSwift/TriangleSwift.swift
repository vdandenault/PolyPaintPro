//
//  TriangleSwift.swift
//  Prototype_IOS
//
//  Created by Jeremie Miglierina on 18-11-16.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//
import UIKit
import Foundation

class TriangleSwift : ShapesSwift {
    var length: CGFloat
    var width: CGFloat
    
    init(type : String, positions: [CGPoint], length: CGFloat, width: CGFloat, id: IdSwift, author: String) {
        self.width = width
        self.length = length
        super.init(type: TRIANGLE, positions: positions, id: id, author: author)
    }
    
    override func toShape()-> shape{
        var jsonPositions : Array<PositionJSON> = []
        for position in positions {
            jsonPositions.append(PositionJSON(x: float_t(position.x), y: float_t(position.y)))
        }
        return shape(type: type, positions: jsonPositions, length: float_t(length), width: float_t(width), title: "", id: id(value: shapeId.value), author: author, className: "", attributes: "", methods: "", text: "", actorName: "", picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: shapeId.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: shapeId.value, positionOnShape: ""))
    }
}
