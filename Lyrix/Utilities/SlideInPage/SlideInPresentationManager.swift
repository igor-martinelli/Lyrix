import UIKit

class SlideInPresentationManager: NSObject, UIViewControllerTransitioningDelegate {
    private let direction: SlideInPresentationController.PresentationDirection
    
    init(direction: SlideInPresentationController.PresentationDirection) {
        self.direction = direction
    }
    
    func presentationController(forPresented presented: UIViewController,
                              presenting: UIViewController?,
                              source: UIViewController) -> UIPresentationController? {
        let presentationController = SlideInPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            direction: direction)
        return presentationController
    }
    
    func animationController(forPresented presented: UIViewController,
                           presenting: UIViewController,
                           source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideInPresentationAnimator(isPresentation: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideInPresentationAnimator(isPresentation: false)
    }
} 