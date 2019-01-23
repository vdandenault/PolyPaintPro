//
//  pictureSwift.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-11-24.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation
import UIKit

class PictureSwift : ShapesSwift {
    var picture: String
    
    init(type : String, positions: [CGPoint], id: IdSwift, author: String, picture: String) {
        self.picture = picture
        super.init(type: PICTURE, positions: positions, id: id, author: author)
    }
    
    override func toShape()-> shape{
        var jsonPositions : Array<PositionJSON> = []
        for position in positions {
            jsonPositions.append(PositionJSON(x: float_t(position.x), y: float_t(position.y)))
        }
        return shape(type: type, positions: jsonPositions, length: nil, width: nil, title: "", id: id(value: shapeId.value), author: author, className: "", attributes: "", methods: "", text: "", actorName: "", picture : picture, lineType: "", arrowHeadType: "", arrowTailType: "", headTitle: "", mainTitle: "", tailTitle: "", headAnchorPoint: headAnchorPoint(shapeId: shapeId.value, positionOnShape: ""),tailAnchorPoint: tailAnchorPoint(shapeId: shapeId.value, positionOnShape: ""))
    }
}
