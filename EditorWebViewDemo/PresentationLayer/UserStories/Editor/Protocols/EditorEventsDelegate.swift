//
//  EditorEventsDelegate.swift
//  EditorWebViewDemo
//
//  Created by Alexander Yuzhin on 18.03.2022.
//  Copyright © 2022 Ascensio System SIA. All rights reserved.
//

import Foundation

protocol EditorEventsDelegate {
    func onAppReady()
    func onDocumentReady()
    func onDownloadAs(fileType: String, url: String)
    func onError(code: String, description: String)
    func onInfo(mode: String)
    func onRequestClose()
    func onRequestInsertImage(type: String)
    func onRequestUsers()
    func onWarning(code: String, description: String)
}
