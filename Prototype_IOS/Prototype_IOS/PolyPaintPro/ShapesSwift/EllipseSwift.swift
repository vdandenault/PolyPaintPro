//
//  EllipseSwift.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 18-10-26.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation
import UIKit


class EllipseSwift : ShapesSwift {
    
    var length: CGFloat
    var width: CGFloat
    var title: String
    
    init(type : String, positions: [CGPoint], length: CGFloat, width: CGFloat, title: String, id: IdSwift, author: String) {
        self.width = width
        self.length = length
        self.title = title
        super.init(type: ELLIPSE, positions: positions, id: id, author: author)
    }
    
    override func toShape()-> shape{
        var jsonPositions : Array<PositionJSON> = []
        for position in positions {
            jsonPositions.append(PositionJSON(x: float_t(position.x), y: float_t(position.y)))
        }
        return shape(type: type, positions: jsonPositions, length: float_t(length), width: float_t(width), title: title, id: id(value: shapeId.value), author: author, className: "", attributes: "", methods: "", text: "", actorName: "", picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: shapeId.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: shapeId.value, positionOnShape: ""))
    }
}


