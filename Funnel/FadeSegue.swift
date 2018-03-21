//
//  FadeSegue.swift
//  Funnel
//
//  Created by Jeremy Irvine on 3/17/18.
//  Copyright © 2018 Bamboo Technologies. All rights reserved.
//

import UIKit

class FadeSegue: UIStoryboardSegue {
    override func perform() {
        // Get the view of the source
        let sourceViewControllerView = self.source.view
        // Get the view of the destination
        let destinationViewControllerView = self.destination.view
        
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        // Make the destination view the size of the screen
        destinationViewControllerView?.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        
        // Insert destination below the source
        // Without this line the animation works but the transition is not smooth as it jumps from white to the new view controller
        destinationViewControllerView?.alpha = 0;
        sourceViewControllerView?.addSubview(destinationViewControllerView!);
        // Animate the fade, remove the destination view on completion and present the full view controller
        UIView.animate(withDuration: 0.5, animations: {
            destinationViewControllerView?.alpha = 1;
//            sourceViewControllerView?.alpha = 0
        }, completion: { (finished) in
//            destinationViewControllerView?.removeFromSuperview()
            self.source.present(self.destination, animated: false, completion: nil)
        })
    }
    }

