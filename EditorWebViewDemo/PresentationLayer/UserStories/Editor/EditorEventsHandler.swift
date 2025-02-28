/*
 * (c) Copyright Ascensio System SIA 2010-2025
 *
 * This program is a free software product. You can redistribute it and/or
 * modify it under the terms of the GNU Affero General Public License (AGPL)
 * version 3 as published by the Free Software Foundation. In accordance with
 * Section 7(a) of the GNU AGPL its Section 15 shall be amended to the effect
 * that Ascensio System SIA expressly excludes the warranty of non-infringement
 * of any third-party rights.
 *
 * This program is distributed WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR  PURPOSE. For
 * details, see the GNU AGPL at: http://www.gnu.org/licenses/agpl-3.0.html
 *
 * You can contact Ascensio System SIA at 20A-6 Ernesta Birznieka-Upish
 * street, Riga, Latvia, EU, LV-1050.
 *
 * The  interactive user interfaces in modified source and object code versions
 * of the Program must display Appropriate Legal Notices, as required under
 * Section 5 of the GNU AGPL version 3.
 *
 * Pursuant to Section 7(b) of the License you must retain the original Product
 * logo when distributing the program. Pursuant to Section 7(e) we decline to
 * grant you any rights under trademark law for use of our trademarks.
 *
 * All the Product's GUI elements, including illustrations and icon sets, as
 * well as technical writing content are licensed under the terms of the
 * Creative Commons Attribution-ShareAlike 4.0 International. See the License
 * terms at http://creativecommons.org/licenses/by-sa/4.0/legalcode
 *
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
