//
//  WelcomeCoordinator.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 01.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

enum WelcomeCoordinatorStep: String, Step {
  case initial
  case dismiss
  case none
}

final class WelcomeCoordinator: Coordinator {
  
  // MARK: - Common Properties
  
  lazy var rootViewController: UIViewController = {
    let navigationController = UINavigationController()
    navigationController.navigationBar.backgroundColor = .white
    navigationController.navigationBar.barTintColor = .black
    navigationController.navigationBar.tintColor = .nearbyWeatherStandard
    return navigationController
  }()
  
  var childCoordinators = [Coordinator]()
  
  // MARK: - Properties
  
  weak var appDelegate: AppDelegateProtocol?

  // MARK: - Initialization
  
  init(appDelegate: AppDelegateProtocol) {
    self.appDelegate = appDelegate
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(Self.didReceiveStep),
      name: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kWelcomeCoordinatorExeceuteRoutingStep),
      object: nil
    )
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Navigation
  
  @objc func didReceiveStep(_ notification: Notification) {
    guard let userInfo = notification.userInfo as? [String: String],
      let stepString = userInfo[Constants.Keys.AppCoordinator.kStep],
      let step = WelcomeCoordinatorStep(rawValue: stepString) else {
        return
    }
    _ = navigateToStep(step)
  }
  
  func navigateToStep(_ step: Step) -> Coordinator? {
    guard let step = step as? WelcomeCoordinatorStep else { return nil }
    
    switch step {
    case .initial:
      summonWelcomeWindow()
      return nil
    case .dismiss:
      dismissWelcomeWindow()
      return nil
    case .none:
      return nil
    }
  }
}
  
  // MARK: - Navigation Helper Functions

extension WelcomeCoordinator {
  
  private func summonWelcomeWindow() {
   
    let welcomeViewController = R.storyboard.welcome.welcomeScreenViewController()!
    let root = rootViewController as? UINavigationController
    root?.setViewControllers([welcomeViewController], animated: false)
    
    let splashScreenWindow = UIWindow(frame: UIScreen.main.bounds)
    splashScreenWindow.rootViewController = root
    splashScreenWindow.windowLevel = UIWindow.Level.alert
    splashScreenWindow.makeKeyAndVisible()
    
    appDelegate?.splashScreenWindow = splashScreenWindow
  }
  
  private func dismissWelcomeWindow() {
    UIView.animate(withDuration: 0.2, animations: { [weak self] in
      self?.appDelegate?.splashScreenWindow?.alpha = 0
      self?.appDelegate?.splashScreenWindow?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
      }, completion: { [weak self] _ in
        self?.appDelegate?.splashScreenWindow?.resignKey()
        self?.appDelegate?.splashScreenWindow = nil
        self?.appDelegate?.window?.makeKeyAndVisible()
    })
  }
}