//
//  CBViewAnimator.swift
//  AnimatedCollection
//
//  Created by Anton Skopin on 20/12/2018.
//  Copyright © 2018 cuberto. All rights reserved.
//

import UIKit

protocol CBAnimatable: AnyObject {
    func update(toAnimationProgress progress: CGFloat)
}

class CBViewAnimator {
    private var animatableViews: NSHashTable<AnyObject> = NSHashTable<AnyObject>.weakObjects()
    
    private var currentProgress: CGFloat = 0.0
    
    func register(animatableView view: CBAnimatable) {
        view.update(toAnimationProgress: currentProgress)
        animatableViews.add(view)
    }

    func updateAnimation(toProgress progress: CGFloat) {
        currentProgress = progress
        animatableViews.allObjects.forEach { (view) in
            if let view = view as? CBAnimatable {
                view.update(toAnimationProgress: progress)
            }
        }
    }
}
