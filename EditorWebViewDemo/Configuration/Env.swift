//
//  Env.swift
//  EditorWebViewDemo
//
//  Created by Alexander Yuzhin on 17.11.2022.
//  Copyright © 2022 Ascensio System SIA. All rights reserved.
//

import Foundation

struct Env {
    
    static fileprivate func value<T>(for key: String) -> T {
        guard let value = Bundle.main.infoDictionary?[key] as? T else {
            fatalError("Invalid or missing Info.plist key: \(key)")
        }
        return value
    }
    
    static var documentServerExampleUrl: String {
        "https://\(value(for: "DOCUMENT_SERVER_EXAMPLE_URL") as String)"
    }
    
    static var documentServerFilesUrl: String {
        "https://\(value(for: "DOCUMENT_SERVER_FILES_URL") as String)"
    }
    
    static var editorCallbackUrl: String {
        "https://\(value(for: "EDITOR_CALLBACK_URL") as String)"
    }
    
    static var documentServerUrl: String {
        "https://\(value(for: "DOCUMENT_SERVER_URL") as String)"
    }
    
    static var documentServerJwtSecret: String {
        value(for: "DOCUMENT_SERVER_JWT_SECRET") as String
    }
    
    
    
}
