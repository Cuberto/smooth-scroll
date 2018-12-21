//
//  CBTitleBlock.swift
//  AnimatedCollection
//
//  Created by Anton Skopin on 21/12/2018.
//  Copyright © 2018 cuberto. All rights reserved.
//

import UIKit

class CBTitleBlock: UICollectionReusableView, CBAnimatable {
    
    @IBOutlet weak var lblTitle: UILabel!
    var startColor: UIColor = #colorLiteral(red: 0.8941176471, green: 0.8, blue: 0.7607843137, alpha: 1)
    var finishColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    
    func update(toAnimationProgress progress: CGFloat) {
        lblTitle.textColor = UIColor(red: startColor.rgba.red + (finishColor.rgba.red - startColor.rgba.red) * progress,
                                     green: startColor.rgba.green + (finishColor.rgba.green - startColor.rgba.green) * progress,
                                     blue: startColor.rgba.blue + (finishColor.rgba.blue - startColor.rgba.blue) * progress,
                                     alpha: startColor.rgba.alpha + (finishColor.rgba.alpha - startColor.rgba.alpha) * progress)
    }
    
    override func sizeToFit() {
        lblTitle.sizeToFit()
        frame = CGRect(origin: frame.origin, size: lblTitle.frame.size)
    }
    
    override var intrinsicContentSize: CGSize {
        return lblTitle.intrinsicContentSize
    }
}
