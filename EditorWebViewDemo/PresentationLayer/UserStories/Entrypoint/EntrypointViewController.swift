//
//  EntrypointViewController.swift
//  EditorWebViewDemo
//
//  Created by Alexander Yuzhin on 09.03.2022.
//  Copyright © 2022 Ascensio System SIA. All rights reserved.
//

import UIKit

class EntrypointViewController: BaseViewController {
   
    // MARK: - Creation Properties
    
    class override var storyboardName: String { return "Entrypoint" }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }

    
    // MARK: - Load data

    private func loadData() {
        navigator.navigate(to: .menu)
    }

}
