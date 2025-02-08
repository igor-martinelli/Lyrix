import UIKit

class SlideInPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let isPresentation: Bool
    
    init(isPresentation: Bool) {
        self.isPresentation = isPresentation
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let key = isPresentation ? UITransitionContextViewControllerKey.to : UITransitionContextViewControllerKey.from
        guard let controller = transitionContext.viewController(forKey: key) else { return }
        
        if isPresentation {
            transitionContext.containerView.addSubview(controller.view)
        }
        
        let presentedFrame = transitionContext.finalFrame(for: controller)
        var dismissedFrame = presentedFrame
        dismissedFrame.origin.x = transitionContext.containerView.frame.size.width
        
        let initialFrame = isPresentation ? dismissedFrame : presentedFrame
        let finalFrame = isPresentation ? presentedFrame : dismissedFrame
        
        controller.view.frame = initialFrame
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                controller.view.frame = finalFrame
            },
            completion: { finished in
                if !self.isPresentation {
                    controller.view.removeFromSuperview()
                }
                transitionContext.completeTransition(finished)
            })
    }
} 