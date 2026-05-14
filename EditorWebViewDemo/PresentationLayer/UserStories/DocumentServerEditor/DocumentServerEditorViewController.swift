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

class DocumentServerEditorViewController: BaseViewController {

    // MARK: - Properties
    
    private let activityIndicator: UIActivityIndicatorView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.hidesWhenStopped = true
        $0.startAnimating()
        return $0
    }(UIActivityIndicatorView(style: .medium))
    
    private lazy var webViewConfiguration: WKWebViewConfiguration = {
        let preferences = WKPreferences()
        let dropSharedWorkersScript = WKUserScript(
            source: "delete window.SharedWorker;",
            injectionTime: WKUserScriptInjectionTime.atDocumentStart,
            forMainFrameOnly: false
        )
        preferences.javaScriptEnabled = true
        $0.userContentController.addUserScript(dropSharedWorkersScript)
        $0.preferences = preferences
        return $0
    }(WKWebViewConfiguration())
    
    public var url: URL?
    private var webView: WKWebView!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Configure UI
        configureView()
        
        /// Loading the set url
        load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    private func configureView() {
        /// Setup WebView and layout
        
        webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        if let webViewSuperview = webView.superview {
            webView.topAnchor.constraint(equalTo: webViewSuperview.topAnchor).isActive = true
            webView.leadingAnchor.constraint(equalTo: webViewSuperview.leadingAnchor).isActive = true
            webView.bottomAnchor.constraint(equalTo: webViewSuperview.bottomAnchor).isActive = true
            webView.trailingAnchor.constraint(equalTo: webViewSuperview.trailingAnchor).isActive = true
        }
        
        /// Workaround display on iPadOS 
        if UIDevice.current.userInterfaceIdiom == .pad {
            webView.customUserAgent = "Mozilla/5.0 (iPad; CPU OS 11_0 like Mac OS X) AppleWebKit/604.1.25 (KHTML, like Gecko) Version/11.0 Mobile/15A5304j Safari/604.1"
        }
        
        /// Setup indicator and layout
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.bringSubviewToFront(activityIndicator)
    }
    
    private func load() {
        guard let url = url else {
            return
        }
        
        webView.load(URLRequest(url: url))
    }

}

// MARK: - WKNavigation Delegate

extension DocumentServerEditorViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        guard let urlString = navigationAction.request.url?.absoluteString else {
            decisionHandler(.cancel)
            return
        }
        
        /// Push back button from editor.
        /// Navigate to previous screen
        if urlString == Env.documentServerExampleUrl {
            decisionHandler(.cancel)
            navigationController?.popViewController(animated: true)
        } else {
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
}

extension DocumentServerEditorViewController : WKUIDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        webView.load(navigationAction.request)
        return nil;
    }
    
}
