//
//  AppDelegate.swift
//  EditorWebViewDemo
//
//  Created by Alexander Yuzhin on 09.03.2022.
//  Copyright © 2022 Ascensio System SIA. All rights reserved.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
    
        window = UIWindow()
        window?.backgroundColor = .systemBackground
        window?.rootViewController = EntrypointViewController.instance()
        window?.makeKeyAndVisible()
        
        return true
    }

}

