//
//  MenuViewController.swift
//  iOSDataCollection
//
//  Created by ROLF J. on 2022/08/02.
//

import UIKit

class MenuViewController: UIViewController {
    
    // MARK: - Instance member
    // 로그아웃
    let saveIDButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setTitle("저장하기", for: .normal)
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = .systemBlue
        buttonConfiguration.baseForegroundColor = .white
        button.configuration = buttonConfiguration
        
        return button
    }()

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    // MARK: - Method

}
