//
//  AnchorPoint.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-11-16.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation
import UIKit

var firstAnchorTapped = false
var firstAnchorPointLine: AnchorPoint!

var secondPointTapped = false
var secondAnchorPointLine: AnchorPoint!

class AnchorPoint: UIView {
    
    var anchorPoint: CGRect!
    var AnchorPointTapped = false
    var isFirstAnchor: Bool = false
    var isSecondAnchor: Bool = false
    var anchorPointAttachedTo: ShapeView!
    var anchorPointLinesGoesTo:  [ShapeView] = []
    var anchorPointIsUsed: Bool = false
    
    
    init(frame: CGRect, anchorPointAttachedTo: ShapeView) {
        super.init(frame: frame)
        self.anchorPointAttachedTo = anchorPointAttachedTo
        self.backgroundColor = UIColor.black
        self.layer.cornerRadius = 2
    }
    
    func setAnchorPoint(anchorPoint: CGRect) {
        self.anchorPoint = anchorPoint
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if ( selectedStatePolyPaintPro == enumStatePolyPaintPro.userD ) {
            if (!firstAnchorTapped && !AnchorPointTapped) {
                AnchorPointTapped = true
                self.backgroundColor = UIColor.red
                firstAnchorTapped = true
                isFirstAnchor = true
                anchorPointAttachedTo = self.superview as! ShapeView
                anchorPointIsUsed = true
                firstAnchorPointLine = self
            }
            if (firstAnchorTapped && !secondPointTapped && !AnchorPointTapped) {
                AnchorPointTapped = true
                self.backgroundColor = UIColor.red
                secondPointTapped = true
                isSecondAnchor = true
                anchorPointLinesGoesTo.append((self.superview as! ShapeView))
                anchorPointIsUsed = true
                secondAnchorPointLine = self
            }
        }
    }
}
