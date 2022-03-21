//
//  EditorEventsHandler.swift
//  EditorWebViewDemo
//
//  Created by Alexander Yuzhin on 18.03.2022.
//  Copyright © 2022 Ascensio System SIA. All rights reserved.
//

import UIKit
import WebKit

class EditorEventsHandler: NSObject {
    
    // MARK: - Properties
    
    var delegate: EditorEventsDelegate?
    
    // MARK: - Lifecycle Methods
    
    convenience init(configuration: WKWebViewConfiguration) {
        self.init()
        
        configuration.userContentController.add(self, name: EditorEvent.onAppReady.rawValue)
        configuration.userContentController.add(self, name: EditorEvent.onDocumentReady.rawValue)
        configuration.userContentController.add(self, name: EditorEvent.onDownloadAs.rawValue)
        configuration.userContentController.add(self, name: EditorEvent.onError.rawValue)
        configuration.userContentController.add(self, name: EditorEvent.onInfo.rawValue)
        configuration.userContentController.add(self, name: EditorEvent.onRequestClose.rawValue)
        configuration.userContentController.add(self, name: EditorEvent.onRequestInsertImage.rawValue)
        configuration.userContentController.add(self, name: EditorEvent.onRequestUsers.rawValue)
        configuration.userContentController.add(self, name: EditorEvent.onWarning.rawValue)
    }

}

// MARK: - ScriptMessageHandler

extension EditorEventsHandler: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage)
    {
        let event = EditorEvent(rawValue: message.name)
        
        switch event {
        case .onAppReady:
            delegate?.onAppReady()
        case .onDocumentReady:
            delegate?.onDocumentReady()
        case .onDownloadAs:
            guard
                let json = message.body as? [String: Any],
                let fileType = json["fileType"] as? String,
                let url = json["url"] as? String
            else { return }

            delegate?.onDownloadAs(fileType: fileType, url: url)
        case .onError:
            guard
                let json = message.body as? [String: Any],
                let code = json["code"] as? String,
                let description = json["description"] as? String
            else { return }
            delegate?.onError(code: code, description: description)
        case .onInfo:
            guard
                let json = message.body as? [String: Any],
                let mode = json["mode"] as? String
            else { return }
            delegate?.onInfo(mode: mode)
        case .onRequestClose:
            delegate?.onRequestClose()
        case .onRequestInsertImage:
            guard
                let json = message.body as? [String: Any],
                let type = json["type"] as? String
            else { return }
            delegate?.onRequestInsertImage(type: type)
        case .onRequestUsers:
            delegate?.onRequestUsers()
        case .onWarning:
            guard
                let json = message.body as? [String: Any],
                let code = json["code"] as? String,
                let description = json["description"] as? String
            else { return }
            delegate?.onWarning(code: code, description: description)
        default:
            print("Unhandle editor event: \(message.name)")
        }
    }
    
}
