//
//  DocumentServerEditorViewController.swift
//  EditorWebViewDemo
//
//  Created by Alexander Yuzhin on 09.03.2022.
//  Copyright © 2022 Ascensio System SIA. All rights reserved.
//

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
