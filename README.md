# Cuberto's development lab:

Cuberto is a leading digital agency with solid design and development expertise. We build mobile and web products for startups. Drop us a line.

# SmoothScroll

![Animation](https://raw.githubusercontent.com/Cuberto/smooth-scroll/master/Screenshots/animation.gif)

## Example

To run the example project, clone the repo and run AnimatedCollection.xcodeproj

## Requirements

- iOS 11.0+
- Xcode 10.0

## Installation

Add SmoothScroll folder to your project

## Usage

1. Create a new UICollectionView in your storyboard or nib (or instantiate it from code).

2. Set layout to `Custom` and set its class to CBSmoothScrollLayout

3. Register supplemetary views for Header, Menu and Title of kinds 
- `CBSmoothScrollLayout.kCBAnimatedLayoutHeader`
- `CBSmoothScrollLayout.kCBAnimatedLayoutMenu`
- `CBSmoothScrollLayout.kCBAnimatedLayoutTitle`
respectively

4. Check your collection view delegate to return right views from method `collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath)`

5. Check your collection view delegate to conform `UICollectionViewSmoothScrollLayoutDelegate` protocol to provide correct size of title and handle animation progress

6. Customize cells and supplementary views for your own purposes. You are free to inherit from base classes provided by us, or create your own from scratch


You can use provided `CBViewAnimator` to propagate animation state to all views that conforms to CBAnimatable protocol. Just register views to animator and call `updateAnimation(toProgress progress: CGFloat)` from delegate.
All parts of layout can be tuned by changing params of `CBSmoothScrollLayout`

## Author

Cuberto Design, info@cuberto.com

## License

SmoothScroll is available under the MIT license. See the LICENSE file for more info.
