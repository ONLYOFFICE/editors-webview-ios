//
//  Navigator.swift
//  EditorWebViewDemo
//
//  Created by Alexander Yuzhin on 09.03.2022.
//  Copyright © 2022 Ascensio System SIA. All rights reserved.
//

import UIKit

enum Destination {

    case menu
    case documentServer
    case documentServerEditor(url: URL)
    case editor(config: String)
    case sampleCategory
    case sampleType(title: String, data: [[String: Any]])

}

class Navigator {
    
    // MARK: - Properties
    
    private weak var navigationController: UINavigationController?
    

    // MARK: - Initialize
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    
    // MARK: - Public
    
    func navigate(to destination: Destination) {
        let viewController = makeViewController(for: destination)
        
        switch destination {

        case .menu:
            UIApplication.shared.windows.first?.rootViewController = UINavigationController(rootViewController: viewController)
            
        default:
            navigationController?.pushViewController(viewController, animated: true)
            
        }
    }
    
    
    // MARK: - Private
    
    fileprivate func makeViewController(for destination: Destination) -> UIViewController {
        switch destination {
        
        case .menu:
            return MenuSampleViewController()
            
        case .documentServer:
            return DocumentServerViewController()

        case let .documentServerEditor(url):
            let controller = DocumentServerEditorViewController()
            controller.url = url
            return controller
            
        case .sampleCategory:
            return SamplesEditorModeViewController()
            
        case let .sampleType(title, data):
            let controller = SamplesEditorTypesViewController()
            controller.title = title
            controller.tableData = data
            return controller
            
        case let .editor(config):
            let controller = EditorViewController()
            controller.config = config
            return controller

        }
    }

}
