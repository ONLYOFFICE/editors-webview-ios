//
//  UIViewControllerExtensions.swift
//  EditorWebViewDemo
//
//  Created by Alexander Yuzhin on 21.03.2022.
//  Copyright © 2022 Ascensio System SIA. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // MARK: - Create
    
    @objc
    public class var storyboardName: String {
        fatalError("Storyboard not defined:\(String(describing: self))")
    }
    
    public class func instance() -> Self {
        return instantiateFromStoryboardHelper(type: self, storyboardName: storyboardName)
    }
    
    class func instantiateFromStoryboardHelper<T>(type: T.Type, storyboardName: String) -> T {
        let storyboardId = String(describing: T.self).components(separatedBy: ".").last
        
        let storyboad = UIStoryboard(name: storyboardName, bundle: nil)
        let controller = storyboad.instantiateViewController(withIdentifier: storyboardId!) as! T
        
        return controller
    }
    
    // MARK: - Methods
    
    public func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true)
    }
}
