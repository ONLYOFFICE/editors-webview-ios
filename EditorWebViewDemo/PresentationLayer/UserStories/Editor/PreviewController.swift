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
