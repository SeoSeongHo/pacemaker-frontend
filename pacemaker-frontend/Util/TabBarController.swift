//
//  TabBarController.swift
//  pacemaker-frontend
//
//  Created by 이지원 on 2021/11/27.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Assign self for delegate for that ViewController can respond to UITabBarControllerDelegate methods
        self.delegate = self
        
        let appearance = UITabBarAppearance()
        appearance.stackedLayoutAppearance.selected.iconColor = .black
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]

        self.tabBar.standardAppearance = appearance
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tabOne = MatchViewController(reactor: MatchViewReactor())
        let tabOneBarItem = UITabBarItem(title: "Match", image: UIImage(systemName: "person.3.fill"), tag:1)
        
        tabOne.tabBarItem = tabOneBarItem
        
        let tabTwo = HistoryViewController(reactor: HistoryViewReactor())
        let tabTwoNavigationController = UINavigationController(rootViewController: tabTwo)

        let tabTwoBarItem = UITabBarItem(title: "History", image: UIImage(systemName: "clock.arrow.circlepath"), tag:2)
        tabTwoNavigationController.tabBarItem = tabTwoBarItem

        self.viewControllers = [tabOne, tabTwoNavigationController]
    }
    
//     UITabBarControllerDelegate method
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
}
