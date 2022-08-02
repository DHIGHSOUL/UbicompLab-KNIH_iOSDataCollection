//
//  SceneDelegate.swift
//  iOSDataCollection
//
//  Created by ROLF J. on 2022/07/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        window?.overrideUserInterfaceStyle = .dark
        
        if UserDefaults.standard.integer(forKey: "appAuthorization") == 1 {
            guard let windowScene = (scene as? UIWindowScene) else { return }
            window = UIWindow(windowScene: windowScene)
            let firstViewController = MainViewController()
            
            window?.rootViewController = firstViewController
            window?.makeKeyAndVisible()
            
            let tabBarController = WindowTabBarViewController()
            window?.rootViewController = tabBarController
        } else {
            guard let windowScene = (scene as? UIWindowScene) else { return }
            window = UIWindow(windowScene: windowScene)
            let userInfoViewController = UserInfoViewController()
            
            window?.rootViewController = userInfoViewController
            window?.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }


}

