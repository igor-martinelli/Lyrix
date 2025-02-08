import UIKit
import SwiftUI

class SettingsViewController: UIViewController {
    private var searchHistory: Binding<[Track]>
    
    init(searchHistory: Binding<[Track]>) {
        self.searchHistory = searchHistory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settingsView = SettingsView(
            showSettings: .constant(true),
            searchHistory: searchHistory
        )
        
        let hostingController = UIHostingController(rootView: settingsView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: self)
        
        // Set background color for both the view and the hosting controller
        view.backgroundColor = UIColor(ThemeManager.settingsBackgroundColor)
        hostingController.view.backgroundColor = UIColor(ThemeManager.settingsBackgroundColor)
    }
} 