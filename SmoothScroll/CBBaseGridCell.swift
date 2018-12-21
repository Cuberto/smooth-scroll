//
//  CBBaseGridCell.swift
//  AnimatedCollection
//
//  Created by Anton Skopin on 21/12/2018.
//  Copyright © 2018 cuberto. All rights reserved.
//

import UIKit

class CBBaseGridCell: UICollectionViewCell, CBAnimatable {
    
    private var indexPath: IndexPath?
    
    let animator = UIViewPropertyAnimator(duration: 1.0, curve: .linear)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    func configure() {
        animator.addAnimations { [weak self] in
            self?.layer.cornerRadius = 10.0
        }
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        indexPath = layoutAttributes.indexPath
        switch layoutAttributes.indexPath.item {
        case 0:
            layer.maskedCorners = [.layerMinXMinYCorner]
        case 1:
            layer.maskedCorners = [.layerMaxXMinYCorner]
        default:
            layer.maskedCorners = []
        }
    }
    
    func update(toAnimationProgress progress: CGFloat) {
        animator.fractionComplete = 1 - progress
        if indexPath?.item == 0 || indexPath?.item == 1 {
            animator.fractionComplete = 1 - progress
        } else {
            animator.fractionComplete = 0
        }
    }
}
