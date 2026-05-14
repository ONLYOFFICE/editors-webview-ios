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
import QuickLook

class PreviewController: NSObject {
    
    // MARK: - Properties
    
    var fileUrl = URL(fileURLWithPath: "")
    
    // MARK: - Lifecycle Methods
    
    func present(url: URL, in parent: UIViewController, complation: @escaping (() -> Void)) {
        download(url: url) { fileUrl in
            DispatchQueue.main.async {
                guard let fileUrl = fileUrl else {
                    complation()
                    return
                }
                
                self.fileUrl = fileUrl
                
                let quickLookController = QLPreviewController()
                quickLookController.dataSource = self
                quickLookController.delegate = self
                
                if QLPreviewController.canPreview(fileUrl as QLPreviewItem) {
                    quickLookController.currentPreviewItemIndex = 0
                    parent.present(quickLookController, animated: true, completion: nil)
                }
                complation()
            }
        }
    }
    
    private func download(url: URL, complation: @escaping ((URL?) -> Void)) {
        let fileName = url.queryValue(for: "filename") ?? "demo"
        
        DispatchQueue.global().async {
            do {
                let data = try? Data(contentsOf: url)
                
                let fileURL = FileManager().temporaryDirectory.appendingPathComponent(fileName)
                try data?.write(to: fileURL, options: .atomic)
                
                complation(fileURL)
            } catch {
                complation(nil)
            }
        }
    }
    
}

// MARK: - QLPreviewController DataSource

extension PreviewController: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return fileUrl as QLPreviewItem
    }
    
}

// MARK: - QLPreviewController Delegate

extension PreviewController: QLPreviewControllerDelegate {
    
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        do {
            try FileManager.default.removeItem(at: fileUrl)
        } catch {}
    }
}
