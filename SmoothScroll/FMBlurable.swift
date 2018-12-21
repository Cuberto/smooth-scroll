//
//  FMBlurable.swift
//  FMBlurable
//
//  Created by SIMON_NON_ADMIN on 18/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//
// Thanks to romainmenke (https://twitter.com/romainmenke) for hint on a larger sample...

import UIKit

private struct BlurableKey {
    static var blurable = "blurable"
}

extension UIView {

    func blur(blurRadius : CGFloat) {
        if self.superview == nil {
            return
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: frame.width, height: frame.height), false, 1)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let capturedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext();
        
        guard let blur = CIFilter(name: "CIGaussianBlur"),
            let image = capturedImage else {
                return
        }
        
        blur.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        blur.setValue(blurRadius, forKey: kCIInputRadiusKey)
        
        let ciContext  = CIContext(options: nil)
        
        let result = blur.value(forKey: kCIOutputImageKey) as! CIImage
        
        let boundingRect = CGRect(x:0,
                                  y: 0,
                                  width: frame.width,
                                  height: frame.height).insetBy(dx: -blurRadius*3, dy: -blurRadius*3)
        
        let cgImage = ciContext.createCGImage(result, from: boundingRect)
        
        let filteredImage = UIImage(cgImage: cgImage!)
        
        let blurOverlay = BlurOverlay()
        blurOverlay.frame = boundingRect
        
        blurOverlay.image = filteredImage
        blurOverlay.contentMode = .center
        
        if let superview = superview as? UIStackView,
            let index = (superview as UIStackView).arrangedSubviews.firstIndex(of: self) {
            removeFromSuperview()
            superview.insertArrangedSubview(blurOverlay, at: index)
        } else {
            blurOverlay.center = CGPoint(x: frame.midX, y: frame.midY)
            UIView.transition(from: self,
                              to: blurOverlay,
                              duration: 0.2,
                              options: .curveEaseIn,
                              completion: nil)
        }
        
        objc_setAssociatedObject(self,
                                 &BlurableKey.blurable,
                                 blurOverlay,
                                 objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
    
    func unBlur() {
        guard let blurOverlay = objc_getAssociatedObject(self, &BlurableKey.blurable) as? BlurOverlay else {
            return
        }
        if let superview = blurOverlay.superview as? UIStackView,
            let index = (blurOverlay.superview as! UIStackView).arrangedSubviews.firstIndex(of: blurOverlay) {
            blurOverlay.removeFromSuperview()
            superview.insertArrangedSubview(self, at: index)
        } else {
            frame.origin = blurOverlay.frame.origin
            UIView.transition(from: blurOverlay,
                              to: self,
                              duration: 0.2,
                              options: .curveEaseIn,
                              completion: nil)
        }
        
        objc_setAssociatedObject(self,
                                 &BlurableKey.blurable,
                                 nil,
                                 objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }

    var isBlurred: Bool {
        return objc_getAssociatedObject(self, &BlurableKey.blurable) is BlurOverlay
    }
}

class BlurOverlay: UIImageView {
}
