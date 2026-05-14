/*
 * Copyright (C) Ascensio System SIA, 2009-2026
 *
 * This program is a free software product. You can redistribute it and/or
 * modify it under the terms of the GNU Affero General Public License (AGPL)
 * version 3 as published by the Free Software Foundation, together with the
 * additional terms provided in the LICENSE file.
 *
 * This program is distributed WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. For
 * details, see the GNU AGPL at: https://www.gnu.org/licenses/agpl-3.0.html
 *
 * You can contact Ascensio System SIA by email at info@onlyoffice.com
 * or by postal mail at 20A-6 Ernesta Birznieka-Upisha Street, Riga,
 * LV-1050, Latvia, European Union.
 *
 * The interactive user interfaces in modified versions of the Program
 * are required to display Appropriate Legal Notices in accordance with
 * Section 5 of the GNU AGPL version 3.
 *
 * No trademark rights are granted under this License.
 *
 * All non-code elements of the Product, including illustrations,
 * icon sets, and technical writing content, are licensed under the
 * Creative Commons Attribution-ShareAlike 4.0 International License:
 * https://creativecommons.org/licenses/by-sa/4.0/legalcode
 *
 * This license applies only to such non-code elements and does not
 * modify or replace the licensing terms applicable to the Program's
 * source code, which remains licensed under the GNU Affero General
 * Public License v3.
 *
 * SPDX-License-Identifier: AGPL-3.0-only
 */

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
