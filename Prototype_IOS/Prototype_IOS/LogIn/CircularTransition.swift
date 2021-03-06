//
//  CircularTransition.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-11-25.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation
import UIKit

class CircularTransition: NSObject {
    
    var circle = UIView()
    
    var startingPoint = CGPoint.zero{
        didSet {
            circle.center = startingPoint
        }
    }
    
    var circleColor = UIColor.white
    
    var duration = 0.35
    
    enum CircularTransitionMode: Int {
        case present, dismiss, pop
    }
    
    var transitionMode:CircularTransitionMode = .present
}

extension CircularTransition : UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        if transitionMode == .present {
            if let presentedView = transitionContext.view(forKey: UITransitionContextViewKey.to) {
                let viewCenter = presentedView.center
                let viewSize = presentedView.frame.size
                circle = UIView()
                circle.frame = frameForCircle(withViewCenter: viewCenter, viewSize: viewSize, startPoint: startingPoint)
                circle.layer.cornerRadius = circle.frame.height/2
                circle.center = startingPoint
                circle.backgroundColor = circleColor
                circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                containerView.addSubview(circle)
                
                presentedView.center = startingPoint
                presentedView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                presentedView.alpha = 0
                
                containerView.addSubview(presentedView)
                
                UIView.animate(withDuration: duration, animations: {
                    self.circle.transform = CGAffineTransform.identity
                    presentedView.transform = CGAffineTransform.identity
                    presentedView.alpha = 1
                    presentedView.center = viewCenter
                }, completion: {(succes: Bool) in
                    transitionContext.completeTransition(succes)
                })
                }
            }
        else {
            let transitionModeKey = (transitionMode == .pop) ? UITransitionContextViewKey.to : UITransitionContextViewKey.from
            if let returningView = transitionContext.view(forKey: transitionModeKey) {
                let viewCenter = returningView.center
                let viewSize = returningView.frame.size
                
                circle.frame = frameForCircle(withViewCenter: viewCenter, viewSize: viewSize, startPoint: startingPoint)
                
                circle.layer.cornerRadius = circle.frame.height/2
                circle.center = startingPoint
                
                UIView.animate(withDuration: duration, animations: {
                    self.circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                    returningView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                    returningView.center = self.startingPoint
                    returningView.alpha = 0
                    
                    if self.transitionMode == .pop {
                        containerView.insertSubview(returningView, belowSubview: returningView)
                        containerView.insertSubview(self.circle, belowSubview: returningView)
                    }
                }, completion: {(succes: Bool) in
                  returningView.center = viewCenter
                    returningView.removeFromSuperview()
                    self.circle.removeFromSuperview()
                    
                    transitionContext.completeTransition(succes)
                })
                
                
            }
        }
    }
    func frameForCircle(withViewCenter viewCenter:CGPoint, viewSize: CGSize, startPoint: CGPoint) -> CGRect {
        let xLenght = fmax(startPoint.x, viewSize.width - startPoint.x)
        let yLenght = fmax(startPoint.y, viewSize.height - startPoint.y)
        
        let offestVector = sqrt(xLenght * xLenght + yLenght * yLenght) * 2
        let size = CGSize(width: offestVector, height: offestVector)
        
        return CGRect(origin: CGPoint.zero, size: size)
        
        
    }
    
}
