//
//  MainToSetupSegue.swift
//  Funnel
//
//  Created by Jeremy Irvine on 2/2/18.
//  Copyright © 2018 Bamboo Technologies. All rights reserved.
//

import UIKit

enum PresentingDirection {
    case top, right, left, bottom
    
    var bounds : CGRect {
        return UIScreen.main.bounds
    }
}

class MainToSetupSegue: NSObject, UIViewControllerAnimatedTransitioning {
    var presentingDirection: PresentingDirection
    
    init(direction: PresentingDirection) {
        self.presentingDirection = direction
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromVC = transitionContext.viewController(forKey: .from)
        let toVC = transitionContext.viewController(forKey: .to)
        let finalVCFrame = transitionContext.finalFrame(for: toVC!)
        let containerView = transitionContext.containerView
        
        UIView.animate(withDuration: 1) {
            fromVC?.view.alpha -= fromVC?.view.alpha!
            toVC?.view.alpha = 1
        }

     }
}
