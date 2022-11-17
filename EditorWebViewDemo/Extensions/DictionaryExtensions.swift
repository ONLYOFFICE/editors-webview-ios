//
//  DictionaryExtensions.swift
//  EditorWebViewDemo
//
//  Created by Alexander Yuzhin on 16.11.2022.
//  Copyright © 2022 Ascensio System SIA. All rights reserved.
//

import Foundation

public extension Dictionary {
    
    func jsonString(prettify: Bool = false) -> String? {
        guard JSONSerialization.isValidJSONObject(self) else { return nil }
        let options = (prettify == true) ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: options) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
}
