//
//  CBBaseMenu.swift
//  AnimatedCollection
//
//  Created by Anton Skopin on 21/12/2018.
//  Copyright © 2018 cuberto. All rights reserved.
//

import UIKit

class CBBaseMenu: UICollectionReusableView, CBAnimatable {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    func configure() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: -2.0)
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.0
    }
    
    func update(toAnimationProgress progress: CGFloat) {
        layer.cornerRadius = 14 * progress
        layer.shadowOpacity = Float(progress * 0.5)
    }
}
