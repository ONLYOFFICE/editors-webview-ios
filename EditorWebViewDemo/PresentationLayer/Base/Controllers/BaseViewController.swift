//
//  BaseViewController.swift
//  EditorWebViewDemo
//
//  Created by Alexander Yuzhin on 09.03.2022.
//  Copyright © 2022 Ascensio System SIA. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController  {
    
    // MARK: - Properties
    
    lazy var navigator = Navigator(navigationController: navigationController)
    
    // MARK: - Lifecycle Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }

}
