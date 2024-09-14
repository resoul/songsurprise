//
//  OnboardController.swift
//  songsurprise
//
//  Created by resoul on 14.09.2024.
//

import UIKit

protocol OnboardDelegate: AnyObject {
    func didViewAllScreens()
}

class OnboardController: UIViewController {
    
    weak var delegate: OnboardDelegate?
    private let items: [OrderModel]
    private var currentIndex = 0
    private var currentController: UIViewController?
    
    private lazy var getStartedButton: GradientButton = {
        let button = GradientButton(type: .custom)
        button.setTitle("Next", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleStartedButton), for: .touchUpInside)
        
        return button
    }()
    
    init(items: [OrderModel]) {
        self.items = items
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .systemBackground
        
        let controller = UIViewController()
        currentController = controller
        addChildController(controller)
        
        view.addSubview(getStartedButton)
        getStartedButton.constraints(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 25, bottom: 25, right: 25), size: .init(width: 0, height: 50))
    }
    
    @objc
    func handleStartedButton() {
        currentIndex = currentIndex + 1
        guard currentIndex != items.count else {
            delegate?.didViewAllScreens()
            return
        }
        
        if items.count == (currentIndex + 1) {
            getStartedButton.setTitle("Get Started", for: .normal)
        }
        
        guard let currentVC = currentController else { return }
        currentVC.willMove(toParent: nil)
        currentVC.view.removeFromSuperview()
        currentVC.removeFromParent()
        
        let controller = UIViewController()
        currentController = controller
        addChildController(controller)
    }
    
    private func addChildController(_ childVC: UIViewController) {
        addChild(childVC)
        childVC.view.frame = view.bounds
        
        let onboard = OnboardView()
        
        childVC.view.addSubview(onboard)
        onboard.constraints(top: childVC.view.safeAreaLayoutGuide.topAnchor, leading: childVC.view.leadingAnchor, bottom: childVC.view.safeAreaLayoutGuide.bottomAnchor, trailing: childVC.view.trailingAnchor)
        onboard.setup(title: items[currentIndex].title, description: items[currentIndex].description, icon: UIImage(named: items[currentIndex].icon))
        
        view.insertSubview(childVC.view, belowSubview: getStartedButton)
        childVC.didMove(toParent: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
