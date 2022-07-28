//
//  WindowTabBarViewController.swift
//  iOSDataCollection
//
//  Created by ROLF J. on 2022/07/25.
//

import UIKit

class WindowTabBarViewController: UITabBarController {

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTabBarLayout()
    }

    // MARK: - Method
    // 센서 확인, 측정 페이지로 이동하는 하단 탭바
    private func setUpTabBarLayout() {
        let firstViewController = UINavigationController(rootViewController: MainViewController())
        let secondViewControllor = UINavigationController(rootViewController: CheckSensorViewController())
        
        firstViewController.tabBarItem.image = UIImage(systemName: "house.fill")
        firstViewController.tabBarItem.title = "측정"
        secondViewControllor.tabBarItem.image = UIImage(systemName: "checkmark.circle.fill")
        secondViewControllor.tabBarItem.title = "센서"
        
        tabBar.backgroundColor = .systemGray6
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .lightGray
        
        viewControllers = [firstViewController, secondViewControllor]
    }
}
