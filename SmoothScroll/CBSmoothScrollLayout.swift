//
//  CBAnimatedLayout.swift
//  AnimatedCollection
//
//  Created by Anton Skopin on 20/12/2018.
//  Copyright © 2018 cuberto. All rights reserved.
//

import UIKit

@objc protocol UICollectionViewSmoothScrollLayoutDelegate: UICollectionViewDelegate {
    @objc optional func collectionView(_ collectionView: UICollectionView, didUpdateAnimationTo progress: CGFloat)
    @objc optional func collectionView(_ collectionView: UICollectionView, titleSizeForProgress progress: CGFloat) -> CGSize
}

private class SeparatorDecoration: UICollectionReusableView {
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        backgroundColor = superview?.backgroundColor
    }
}

private class ShadowDecoration: UICollectionReusableView {
    let blackView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 10, height: 10)))
        view.backgroundColor = .black
        view.clipsToBounds = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(blackView)
        clipsToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(blackView)
        clipsToBounds = false
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        update(toSize: layoutAttributes.frame.size)
    }
    
    func update(toSize size: CGSize) {
        if size.equalTo(blackView.frame.size) {
            return
        }
        blackView.unBlur()
        blackView.frame = CGRect(x: (frame.width - size.width)/2.0, y: (frame.height - size.height)/2.0,
                                 width: size.width, height: size.height)
        blackView.blur(blurRadius: 27.0)
    }
}

class CBSmoothScrollLayout: UICollectionViewLayout {
    
    static let kCBAnimatedLayoutHeader: String = "kCBAnimatedLayoutHeader"
    static let kCBAnimatedLayoutTitle: String = "kCBAnimatedLayoutTitle"
    static let kCBAnimatedLayoutMenu: String = "kCBAnimatedLayoutMenu"
    
    private static let kCBAnimatedLayoutMenuShadow: String = "kCBAnimatedLayoutMenuShadow"
    private static let kCBAnimatedLayoutHorSeparator: String = "kCBAnimatedLayoutHorSeparator"
    private static let kCBAnimatedLayoutVertSeparator: String = "kCBAnimatedLayoutVertSeparator"
    
    private var lastAnimationUpdate: CGFloat?
    
    public var spacing: CGFloat = 1.0  {
        didSet { resetStoredValues() }
    }
    public var cellsMaxMargin: CGFloat = 18.0 {
        didSet { resetStoredValues() }
    }
    public var headerMaxHeight: CGFloat = round(UIScreen.main.bounds.height * 0.486)  {
        didSet { resetStoredValues() }
    }
    public var headerMinHeight: CGFloat = 197 {
        didSet { resetStoredValues() }
    }
    public var menuMaxHeight: CGFloat = 157 {
        didSet { resetStoredValues() }
    }
    public var menuMinHeight: CGFloat = 67  {
        didSet { resetStoredValues() }
    }
    public var menuToCellsStartOffset: CGFloat = -34  {
        didSet { resetStoredValues() }
    }
    public var menuToCellsEndOffset: CGFloat = 10  {
        didSet { resetStoredValues() }
    }
    public var menuToHeaderEndOffset: CGFloat = -42  {
        didSet { resetStoredValues() }
    }
    public var menuMaxMargin: CGFloat = 20.0  {
        didSet { resetStoredValues() }
    }
    public var menuShadowOffset: CGFloat = 10.0  {
        didSet { resetStoredValues() }
    }
    public var titleStartOffset: CGPoint = CGPoint(x: 50.0, y: 31)  { //Offset to menu top
        didSet { resetStoredValues() }
    }
    public var titleEndOffset: CGPoint = CGPoint(x: 100.0, y: 60)  { //Offset to header top
        didSet { resetStoredValues() }
    }
    
    
    private var defaultCellZIndex: Int = 5
    public var animationScrollLength: CGFloat = 150.0  {
        didSet {
            orderChangeProgress  = nil
            lastCellZIndex = defaultCellZIndex
        }
    }
    
    private var width: CGFloat = 0
    private var numberOfItems = 0
    private var animationProgress: CGFloat {
        let offset = collectionView?.contentOffset.y ?? 0
        let normalizedOffset = max(0.0, min(1.0, offset/animationScrollLength))
        return normalizedOffset
    }
    
    override init() {
        super.init()
        registerDecorationViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        registerDecorationViews()
    }
    
    private func registerDecorationViews() {
        register(ShadowDecoration.self, forDecorationViewOfKind: CBSmoothScrollLayout.kCBAnimatedLayoutMenuShadow)
        register(SeparatorDecoration.self, forDecorationViewOfKind: CBSmoothScrollLayout.kCBAnimatedLayoutHorSeparator)
        register(SeparatorDecoration.self, forDecorationViewOfKind: CBSmoothScrollLayout.kCBAnimatedLayoutVertSeparator)
    }
    
    public override var collectionViewContentSize: CGSize {
        let itemsHeight = CGFloat(ceil(Double(numberOfItems)/2.0)) * itemSize
        let offset = collectionView?.contentOffset.y ?? 0
        if offset <= 0 {
            return CGSize(width: width, height: ceil(headerMaxHeight + menuMaxHeight + menuToCellsStartOffset + itemsHeight))
        }
        return CGSize(width: width, height: ceil(itemsHeight + cellOffset(forProgress: animationProgress)))
    }
    
    private var cellsMargin: CGFloat {
        return cellsMaxMargin * (1 - animationProgress)
    }
    
    private var itemSize: CGFloat {
        return (width - spacing - cellsMargin * 2)/2.0
    }
    
    private var contentOffset: CGSize {
        return CGSize(width: (collectionView?.contentInset.left ?? 0) + (collectionView?.contentOffset.x ?? 0),
                      height: (collectionView?.contentInset.top ?? 0) + (collectionView?.contentOffset.y ?? 0))
    }
    
    private func cellOffset(forProgress progress: CGFloat) -> CGFloat {
        guard headerMaxHeight > 0 else {
            return 0
        }
        let offset = collectionView?.contentOffset.y ?? 0
        if offset < 0 {
            return menuFrame(forProgress: progress).maxY + menuToCellsStartOffset
        }
        let maxOffset = headerMaxHeight + menuMaxHeight + menuToCellsStartOffset
        let minOffset = headerMinHeight + menuMinHeight + menuToHeaderEndOffset + animationScrollLength + menuToCellsEndOffset
        return maxOffset - (maxOffset - minOffset) * progress
    }
    
    private func headerSize(forProgress progress: CGFloat) -> CGFloat {
        guard headerMaxHeight > 0 else {
            return 0
        }
        let offset = collectionView?.contentOffset.y ?? 0
        if offset <= 0 {
            return headerMaxHeight - offset * 2
        }
        return headerMaxHeight - (headerMaxHeight - headerMinHeight) * progress
    }
    
    private func menuFrame(forProgress progress: CGFloat) -> CGRect {
        guard menuMaxHeight > 0 else {
            return .zero
        }
        let offset = collectionView?.contentOffset.y ?? 0
        if offset <= 0 {
            return CGRect(x: 0, y: headerSize(forProgress: progress) + offset, width: width, height: menuMaxHeight)
        }
        let minY = headerMinHeight + menuToHeaderEndOffset
        let maxY = headerMaxHeight
        let minWidth = width - menuMaxMargin * 2
        let menuWidth = width - (width - minWidth) * progress
        let menuHeight = menuMaxHeight - (menuMaxHeight - menuMinHeight) * progress
        let menuY = maxY - (maxY - minY) * progress
        let menuX = menuMaxMargin * progress
        return CGRect(x: menuX, y: menuY, width: menuWidth, height: menuHeight)
    }
    
    private func titleLocation(forProgress progress: CGFloat) -> CGPoint {
        let offset = collectionView?.contentOffset.y ?? 0
        let startPoint = CGPoint(x: menuFrame(forProgress: 0).minX + titleStartOffset.x,
                                 y: menuFrame(forProgress: 0).minY + titleStartOffset.y)
        let endPoint = CGPoint(x: titleEndOffset.x,
                               y: titleEndOffset.y)
        if offset <= 0 {
            return startPoint
        } else {
            
            return CGPoint(x: startPoint.x + (endPoint.x - startPoint.x) * animationProgress,
                           y: startPoint.y + (endPoint.y - startPoint.y) * animationProgress)
        }
    }
    
    private func resetStoredValues() {
        orderChangeProgress  = nil
        lastCellZIndex = 4
    }
    
    override open func prepare() {
        super.prepare()
        width = collectionView?.bounds.width ?? 0
        numberOfItems = collectionView?.numberOfItems(inSection: 0) ?? 0
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var result: [UICollectionViewLayoutAttributes] = []
        for item in 0..<self.numberOfItems {
            if let attrForItem = self.layoutAttributesForItem(at: IndexPath(item: item, section: 0)) {
                if attrForItem.frame.intersects(rect) {
                    result.append(attrForItem)
                    result.append(contentsOf: separators(forCellWithAttributes: attrForItem))
                }
            }
        }
        if let headerAttr = headerAttributes() {
            result.append(headerAttr)
        }
        if let menuAttr = menuAttributes() {
            result.append(menuAttr)
        }
        if let shadowAttr = shadowAttributes() {
            result.append(shadowAttr)
        }
        if let titleAttr = titleAttributes() {
            result.append(titleAttr)
        }
        if animationProgress != lastAnimationUpdate,
           let collectionView = collectionView,
           let delegate = (collectionView.delegate as? UICollectionViewSmoothScrollLayoutDelegate) {
            delegate.collectionView?(collectionView, didUpdateAnimationTo: animationProgress)
            lastAnimationUpdate = animationProgress
        }
        return result
    }
    
    private func separators(forCellWithAttributes attributes: UICollectionViewLayoutAttributes) -> [UICollectionViewLayoutAttributes] {
        var result: [UICollectionViewLayoutAttributes] = []
        let column = attributes.indexPath.item % 2
        guard column == 0 else {
            return []
        }
        let row = attributes.indexPath.item / 2
        let lastRow = Int(ceil(Double(numberOfItems)/2.0))
        if row < lastRow {
            let horSeparator = UICollectionViewLayoutAttributes(forDecorationViewOfKind:type(of: self).kCBAnimatedLayoutHorSeparator, with: attributes.indexPath)
            horSeparator.frame = CGRect(x: attributes.frame.minX,
                                        y: attributes.frame.maxY,
                                        width: attributes.frame.width * 2 + spacing,
                                        height: spacing)
            horSeparator.zIndex = attributes.zIndex + 1
            result.append(horSeparator)
        }
        let vertSeparator = UICollectionViewLayoutAttributes(forDecorationViewOfKind:type(of: self).kCBAnimatedLayoutVertSeparator, with: attributes.indexPath)
        vertSeparator.frame = CGRect(x: attributes.frame.maxX,
                                    y: attributes.frame.minY,
                                    width: spacing,
                                    height: attributes.frame.height + (row < lastRow ? spacing : 0))
        vertSeparator.zIndex = attributes.zIndex + 1
        result.append(vertSeparator)
        return result
    }
    
    private func headerAttributes() -> UICollectionViewLayoutAttributes? {
        guard headerSize(forProgress: animationProgress) > 0 else {
            return nil
        }
        let headerAttr = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: type(of: self).kCBAnimatedLayoutHeader, with: IndexPath(item: 0, section: 0))
        headerAttr.zIndex = 2
        headerAttr.frame = CGRect(x: contentOffset.width, y: contentOffset.height, width: width, height: headerSize(forProgress: animationProgress))
        return headerAttr
    }
    
    private func menuAttributes() -> UICollectionViewLayoutAttributes? {
        guard menuFrame(forProgress: animationProgress) != .zero else {
            return nil
        }
        let menuAttr = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: type(of: self).kCBAnimatedLayoutMenu, with: IndexPath(item: 0, section: 0))
        menuAttr.zIndex = 4
        menuAttr.frame = menuFrame(forProgress: animationProgress).offsetBy(dx: max(contentOffset.width, 0), dy: max(contentOffset.height, 0))
        return menuAttr
    }
    
    private func shadowAttributes() -> UICollectionViewLayoutAttributes? {
        guard menuFrame(forProgress: animationProgress) != .zero else {
            return nil
        }
        let shadowAttrs = UICollectionViewLayoutAttributes(forDecorationViewOfKind:type(of: self).kCBAnimatedLayoutMenuShadow, with: IndexPath(item: 0, section: 0))
        shadowAttrs.zIndex = 3
        let shadowWidth = (width - menuMaxMargin * 2) * 0.9
        let shadowHeight = menuMinHeight * 0.5
        if let orderChangeProgress = orderChangeProgress, orderChangeProgress < 1.0 {
            shadowAttrs.alpha =  min((max(animationProgress - orderChangeProgress, 0) / (1.0 - orderChangeProgress)), 1.0) * 0.6
        } else {
            shadowAttrs.alpha = 0
        }
        shadowAttrs.frame = CGRect(x: (width - shadowWidth)/2.0,
                                   y: menuFrame(forProgress: animationProgress).maxY - shadowHeight + menuShadowOffset,
                                   width: shadowWidth, height: shadowHeight).offsetBy(dx: max(contentOffset.width, 0), dy: max(contentOffset.height, 0))
        return shadowAttrs
    }
    
    
    private func titleAttributes() -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView,
              let delegate = (collectionView.delegate as? UICollectionViewSmoothScrollLayoutDelegate),
              let titleSize = delegate.collectionView?(collectionView, titleSizeForProgress: animationProgress) else {
              return nil
        }
        let titleAttr = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: type(of: self).kCBAnimatedLayoutTitle, with: IndexPath(item: 0, section: 0))
        titleAttr.zIndex = defaultCellZIndex + 1
        titleAttr.frame = CGRect(origin: titleLocation(forProgress: animationProgress),
                                 size: titleSize).offsetBy(dx: max(contentOffset.width, 0), dy: max(contentOffset.height, 0))
        return titleAttr
    }
    
    private var orderChangeProgress: CGFloat?
    private var lastCellZIndex: Int = 5
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        let offsetMenuY = menuFrame(forProgress: animationProgress).offsetBy(dx: 0, dy: max(contentOffset.height, 0)).maxY
        attr.zIndex = offsetMenuY >= cellOffset(forProgress: animationProgress) && animationProgress < 1.0 ? defaultCellZIndex : 0
        if attr.zIndex != lastCellZIndex && orderChangeProgress == nil {
            orderChangeProgress = animationProgress
        }
        let column = indexPath.item % 2
        let row = indexPath.item / 2
        attr.frame = CGRect(x: cellsMargin + CGFloat(column) * itemSize + CGFloat(column) * spacing,
                            y: cellOffset(forProgress: animationProgress) + CGFloat(row) * itemSize + CGFloat(row) * spacing,
                            width: itemSize, height: itemSize)
        return attr
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}
