//
//  StringExtensions.swift
//  EditorWebViewDemo
//
//  Created by Alexander Yuzhin on 16.11.2022.
//  Copyright © 2022 Ascensio System SIA. All rights reserved.
//

import Foundation

extension String {
    
    func toDictionary(options: JSONSerialization.ReadingOptions = []) -> [String: Any]? {
        if let data = data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: options) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
}
