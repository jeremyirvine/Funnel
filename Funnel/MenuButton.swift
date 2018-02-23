//
//  MenuButton.swift
//  Funnel
//
//  Created by Jeremy Irvine on 2/22/18.
//  Copyright © 2018 Bamboo Technologies. All rights reserved.
//

import UIKit

class MenuButton: UIButton {
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
