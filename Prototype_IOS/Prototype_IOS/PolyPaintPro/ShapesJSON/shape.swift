//
//  shape.swift
//  Prototype_IOS
//
//  Created by Jeremie Miglierina on 18-11-03.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//
import SocketIO
import Foundation

struct shape: Codable, SocketData{
    var type: String?
    var positions: [PositionJSON]?
    var length: float_t?
    var width: float_t?
    var title: String?
    var id: id?
    var author: String?
    var className: String?
    var attributes: String?
    var methods: String?
    var text: String?
    var actorName: String?
    var picture: String?
    var lineType: String?
    var arrowHeadType: String?
    var arrowTailType: String?
    var headTitle: String?
    var mainTitle: String?
    var tailTitle: String?
    var headAnchorPoint: headAnchorPoint?
    var tailAnchorPoint: tailAnchorPoint?
    
    
}
