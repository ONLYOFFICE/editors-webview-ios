//
//  PreviewController.swift
//  EditorWebViewDemo
//
//  Created by Alexander Yuzhin on 18.03.2022.
//  Copyright © 2022 Ascensio System SIA. All rights reserved.
//

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
