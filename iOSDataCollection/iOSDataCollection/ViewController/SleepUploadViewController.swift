//
//  SleepUploadViewController.swift
//  iOSDataCollection
//
//  Created by ROLF J. on 2022/08/21.
//

import UIKit

class SleepUploadViewController: UIViewController {
    
    // MARK: - Instance members
    // 오늘의 업로드의 완료되었는지 표시하기 위한 Label
    private let uploadCompleteLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    //

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        sleepUploadViewLayout()
    }
    
    // MARK: - Method
    // Sleep Upload View의 Layout 지정
    private func sleepUploadViewLayout() {
        
    }
    
    // MARK: - @objc Method

}
