//
//  ArrowHeadSwift.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-11-27.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import UIKit

class ArrowHeadSwift: UIView {

    var corner: cornerArrow!
    
    init(frame: CGRect, corner: cornerArrow) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.corner = corner
    }
    
    override func draw(_ rect: CGRect) {
        drawArrowHead()
    }
    
    func drawArrowHead() {
        switch corner {
        case .bottomRight?:
            guard let ctx = UIGraphicsGetCurrentContext() else { return }
            ctx.beginPath()
            ctx.move(to: CGPoint(x: frame.size.width - 5, y: frame.size.height - 5))
            ctx.addLine(to: CGPoint(x: 5, y: frame.size.height - 5))
            ctx.addLine(to: CGPoint(x:  frame.size.width - 5, y: 5 ))
            ctx.setLineWidth(5)
            ctx.closePath()
            ctx.strokePath()
        case .bottomLeft?:
            guard let ctx = UIGraphicsGetCurrentContext() else { return }
            ctx.beginPath()
            ctx.move(to: CGPoint(x: 5, y: frame.size.height - 5))
            ctx.addLine(to: CGPoint(x: 5, y: 5))
            ctx.addLine(to: CGPoint(x: frame.size.width - 5, y: frame.size.height - 5))
            ctx.setLineWidth(5)
            ctx.closePath()
            ctx.strokePath()
            break
        case .topLeft?:
            guard let ctx = UIGraphicsGetCurrentContext() else { return }
            ctx.beginPath()
            ctx.move(to: CGPoint(x: 5, y: 5))
            ctx.addLine(to: CGPoint(x: frame.size.width, y: 5))
            ctx.addLine(to: CGPoint(x: 5, y: frame.size.height))
            ctx.setLineWidth(5)
            ctx.closePath()
            ctx.strokePath()
            break
        case .topRight?:
            guard let ctx = UIGraphicsGetCurrentContext() else { return }
            ctx.beginPath()
            ctx.move(to: CGPoint(x: frame.size.width - 5, y: 5))
            ctx.addLine(to: CGPoint(x: 5, y: 5))
            ctx.addLine(to: CGPoint(x:  frame.size.width - 5, y: frame.size.height - 5))
            ctx.setLineWidth(5)
            ctx.closePath()
            ctx.strokePath()
            break
        default:
            break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
