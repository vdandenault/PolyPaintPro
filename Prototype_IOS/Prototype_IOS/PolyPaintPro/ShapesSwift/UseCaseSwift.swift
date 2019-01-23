//
//  UseCaseSwift.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-11-28.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation

import UIKit

class UseCaseSwift : ShapesSwift {
    var text: String
    var length: CGFloat
    var width: CGFloat
    
    init(type : String, positions: [CGPoint], text: String, length: CGFloat, width: CGFloat, id: IdSwift, author: String) {
        self.text = text
        self.length = length
        self.width = width
        super.init(type: USECASE, positions: positions, id: id, author: author)
    }
    
    override func toShape()-> shape{
        var jsonPositions : Array<PositionJSON> = []
        for position in positions {
            jsonPositions.append(PositionJSON(x: float_t(position.x), y: float_t(position.y)))
        }
        return shape(type: type, positions: jsonPositions, length: float_t(length), width: float_t(width), title: text, id: id(value: shapeId.value), author: author, className: "", attributes: "", methods: "", text: "", actorName: "", picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: shapeId.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: shapeId.value, positionOnShape: ""))
    }
    
}
