//
//  CardView.swift
//  Funnel
//
//  Created by Jeremy Irvine on 2/21/18.
//  Copyright © 2018 Bamboo Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class CardView: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        layer.shadowRadius  =   4.0
        layer.masksToBounds =  true
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBInspectable var borderRadius: CGFloat {
        get {
            return layer.cornerRadius
        } 
        set(newValue) {
            self.layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var borderColor : UIColor? {
        set (newValue) {
            self.layer.borderColor = (newValue ?? UIColor.clear).cgColor
        }
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
    }
    @IBInspectable var shadowColorFromUIColor: UIColor {
        get {
            if let cgShadow = layer.shadowColor {
                return UIColor(cgColor: cgShadow)
            } else {
                return UIColor.clear
            }
        }
        set(newValue) {
            layer.shadowColor = newValue.cgColor
        }
    }
    @IBInspectable var shadowOffset: CGSize {
        get {
            let cgOffset = layer.shadowOffset
            return cgOffset ?? CGSize(width: 0, height: 0)
        }
        set(newValue) {
            layer.shadowOffset = newValue
        }
    }
    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set(newValue) {
            layer.shadowOpacity = newValue
        }
    }
}
