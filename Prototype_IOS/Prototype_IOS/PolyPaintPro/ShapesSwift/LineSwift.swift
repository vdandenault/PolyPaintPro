//
//  LineSwift.swift
//  Prototype_IOS
//
//  Created by Jeremie Miglierina on 18-11-16.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation
import UIKit
class LineSwift : ShapesSwift {
    
    var lineType: String
    var arrowHeadType: String
    var arrowTailType: String
    var headTitle: String
    var mainTitle: String
    var tailTitle: String
    var headAnchorPointSwift: AnchorPointSwift
    var tailAnchorPointSwift: AnchorPointSwift
    var length: CGFloat
    var width: CGFloat
    var title: String
    
    init(type : String, positions: [CGPoint], length: CGFloat, width: CGFloat, title: String, id: IdSwift, author: String, lineType: String,arrowHeadType: String,arrowTailType: String,headTitle: String,mainTitle: String, tailTitle: String, headAnchorPoint: AnchorPointSwift,tailAnchorPoint: AnchorPointSwift ) {
        self.lineType = lineType
        self.arrowHeadType = arrowHeadType
        self.arrowTailType = arrowTailType
        self.headTitle = headTitle
        self.mainTitle = mainTitle
        self.tailTitle = tailTitle
        self.headAnchorPointSwift = headAnchorPoint
        self.tailAnchorPointSwift = tailAnchorPoint
        self.length = length
        self.width = width
        self.title = title
        super.init(type: type, positions: positions, id: id, author: author)
    }
    
    override func toShape()-> shape{
        var jsonPositions : Array<PositionJSON> = []
        for position in positions {
            jsonPositions.append(PositionJSON(x: float_t(position.x), y: float_t(position.y)))
        }
        return shape(type: type, positions: jsonPositions, length: float_t(length), width: float_t(width), title: title, id: id(value: shapeId.value), author: author, className: "", attributes: "", methods: "", text: "", actorName: "", picture : "", lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: shapeId.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: shapeId.value, positionOnShape: ""))
    }
}
