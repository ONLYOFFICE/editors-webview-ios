//
//  EditorEvent.swift
//  EditorWebViewDemo
//
//  Created by Alexander Yuzhin on 18.03.2022.
//  Copyright © 2022 Ascensio System SIA. All rights reserved.
//

import Foundation

enum EditorEvent: String, CaseIterable {
    case onAppReady, onDocumentReady, onDownloadAs,
         onError, onInfo, onRequestClose,
         onRequestInsertImage, onRequestUsers, onWarning
}
