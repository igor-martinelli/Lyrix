import UIKit

class SlideInPresentationController: UIPresentationController {
    private let direction: PresentationDirection
    private var dimmingView: UIView!
    private var presentingViewOriginalFrame: CGRect = .zero
    
    // Constants
    private struct Constants {
        static let presentedViewWidthRatio: CGFloat = 0.8  // 80% of screen width
        static let presentingViewOpacity: CGFloat = 0.7    // Opacity when settings is shown
        static let dimmingViewOpacity: CGFloat = 0.3      // Dimming view background opacity
    }
    
    enum PresentationDirection {
        case right
    }
    
    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
         direction: PresentationDirection) {
        self.direction = direction
        super.init(presentedViewController: presentedViewController,
                  presenting: presentingViewController)
        setupDimmingView()
    }
    
    private func setupDimmingView() {
        dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: Constants.dimmingViewOpacity)
        dimmingView.alpha = 0.0
        
        let recognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTap(recognizer:)))
        dimmingView.addGestureRecognizer(recognizer)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true)
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        
        presentingViewOriginalFrame = presentingViewController.view.frame
        
        containerView.insertSubview(dimmingView, at: 0)
        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1.0
            presentingViewController.view.frame.origin.x = -containerView.bounds.width * Constants.presentedViewWidthRatio
            presentingViewController.view.alpha = Constants.presentingViewOpacity
            return
        }
        
        coordinator.animate { _ in
            self.dimmingView.alpha = 1.0
            self.presentingViewController.view.frame.origin.x = -containerView.bounds.width * Constants.presentedViewWidthRatio
            self.presentingViewController.view.alpha = Constants.presentingViewOpacity
        }
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0.0
            presentingViewController.view.frame = presentingViewOriginalFrame
            presentingViewController.view.alpha = 1.0
            return
        }
        
        coordinator.animate { _ in
            self.dimmingView.alpha = 0.0
            self.presentingViewController.view.frame = self.presentingViewOriginalFrame
            self.presentingViewController.view.alpha = 1.0
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        let width = containerView.bounds.width * Constants.presentedViewWidthRatio
        return CGRect(x: containerView.bounds.width - width,
                     y: 0,
                     width: width,
                     height: containerView.bounds.height)
    }
} 