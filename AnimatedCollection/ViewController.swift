//
//  ViewController.swift
//  AnimatedCollection
//
//  Created by Anton Skopin on 19/12/2018.
//  Copyright © 2018 cuberto. All rights reserved.
//

import UIKit

class TestCell: CBBaseGridCell {
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
}

class HeaderBlock: CBBaseHeader {
    @IBOutlet weak var csTextBottom: NSLayoutConstraint!
    @IBOutlet weak var csImageTop: NSLayoutConstraint!
    
    override func update(toAnimationProgress progress: CGFloat) {
        super.update(toAnimationProgress: progress)
        csTextBottom.constant = 44 + 200 * progress
        csImageTop.constant = -400 * progress * 1.5
        UIView.animate(withDuration: 0.01) {
            self.layoutIfNeeded()
        }
    }
}

class ManuBlock: CBBaseMenu {
    @IBOutlet weak var csImageLeft: NSLayoutConstraint!
    
    override func update(toAnimationProgress progress: CGFloat) {
        super.update(toAnimationProgress: progress)
        csImageLeft.constant = 50 - (50 - 30) * progress
        UIView.animate(withDuration: 0.01) {
            self.layoutIfNeeded()
        }
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let viewAnimator = CBViewAnimator()
    var titleSize: CGSize = .zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "Header", bundle: nil),
                                forSupplementaryViewOfKind: CBSmoothScrollLayout.kCBAnimatedLayoutHeader,
                                withReuseIdentifier: CBSmoothScrollLayout.kCBAnimatedLayoutHeader)
        collectionView.register(UINib(nibName: "Menu", bundle: nil),
                                forSupplementaryViewOfKind: CBSmoothScrollLayout.kCBAnimatedLayoutMenu,
                                withReuseIdentifier: CBSmoothScrollLayout.kCBAnimatedLayoutMenu)
        collectionView.register(UINib(nibName: "Title", bundle: nil),
                                forSupplementaryViewOfKind: CBSmoothScrollLayout.kCBAnimatedLayoutTitle,
                                withReuseIdentifier: CBSmoothScrollLayout.kCBAnimatedLayoutTitle)
        if let title = UINib(nibName: "Title", bundle: nil).instantiate(withOwner: nil, options: nil).first as? UIView {
            title.sizeToFit()
            titleSize = title.frame.size
        }
    }
}

extension ViewController: UICollectionViewSmoothScrollLayoutDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let supplementaryView: UICollectionReusableView
        switch kind {
        case CBSmoothScrollLayout.kCBAnimatedLayoutHeader,
             CBSmoothScrollLayout.kCBAnimatedLayoutMenu,
             CBSmoothScrollLayout.kCBAnimatedLayoutTitle:
            supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath)
        default:
            fatalError("unexpected element type")
        }
        if let animatableView = supplementaryView as? CBAnimatable {
            viewAnimator.register(animatableView: animatableView)
        }
        return supplementaryView
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }
    var startDate: Date {
        return dateFormatter.date(from: "11:00") ?? Date()
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "test", for: indexPath)
        if let cell = cell as? TestCell {
            cell.lblTime.text = dateFormatter.string(from: startDate.addingTimeInterval(TimeInterval(60*30*indexPath.item)))
            viewAnimator.register(animatableView: cell)
            cell.lblPrice.text = "$\(Int.random(in: 1...12) * 10)"
        }
        return cell
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, didUpdateAnimationTo progress: CGFloat) {
        viewAnimator.updateAnimation(toProgress: progress)
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, titleSizeForProgress progress: CGFloat) -> CGSize {
        return titleSize
    }
    
}
