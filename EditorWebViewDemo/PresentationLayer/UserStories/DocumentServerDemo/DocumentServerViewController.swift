//
//  DocumentServerViewController.swift
//  EditorWebViewDemo
//
//  Created by Alexander Yuzhin on 09.03.2022.
//  Copyright © 2022 Ascensio System SIA. All rights reserved.
//

import UIKit
import WebKit

class DocumentServerViewController: BaseViewController {

    // MARK: - Properties
    
    /// The address of the web interface of the document server for the demo.
    private var documentServerUrlString = Bundle.main.object(forInfoDictionaryKey: "DocumentServerURL") as? String ?? ""
    
    /// Part of the address of the link on which the document is opened.
    /// It is a marker for opening the document editor.
    private var openDocumentMarker = "/editor?"
    
    /// Additional options for opening a document link.
    private var additionalQueryParameters = ["type": "mobile"]
    
    private let activityIndicator: UIActivityIndicatorView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.hidesWhenStopped = true
        $0.startAnimating()
        return $0
    }(UIActivityIndicatorView(style: .medium))
    
    private let reloadItem: UIBarButtonItem = {
        $0.isEnabled = false
        return $0
    }(UIBarButtonItem(
        image: UIImage(systemName: "arrow.clockwise"),
        style: .plain,
        target: DocumentServerViewController.self,
        action: #selector(onReload)
    ))
    
    private let backItem: UIBarButtonItem = {
        $0.isEnabled = false
        return $0
    }(UIBarButtonItem(
        image: UIImage(systemName: "chevron.left"),
        style: .plain,
        target: DocumentServerViewController.self,
        action: #selector(onBack)
    ))
    
    private let forwardItem: UIBarButtonItem = {
        $0.isEnabled = false
        return $0
    }(UIBarButtonItem(
        image: UIImage(systemName: "chevron.right"),
        style: .plain,
        target: DocumentServerViewController.self,
        action: #selector(onForward)
    ))
    
    
    
    private let progressView: UIProgressView = {
        return $0
    }(UIProgressView(frame: .zero))
    
    private var webView: WKWebView!
    private var estimatedProgressObserver: NSKeyValueObservation?

    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Configure UI
        configureView()
        
        /// Loading the set portal url
        load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    private func configureView() {
        edgesForExtendedLayout = []
        
        /// Setup WebView
        let preferences = WKPreferences()
        let configuration = WKWebViewConfiguration()
        preferences.javaScriptEnabled = true
        configuration.preferences = preferences
        
        webView = WKWebView(frame: .zero, configuration: configuration)
        
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
        
        /// Setup indicator
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.bringSubviewToFront(activityIndicator)
        
        /// Setup progress
        view.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        progressView.leadingAnchor.constraint(equalTo: webView.leadingAnchor).isActive = true
        progressView.trailingAnchor.constraint(equalTo: webView.trailingAnchor).isActive = true
        
        progressView.progress = 0
        progressView.isHidden = true
        
        view.bringSubviewToFront(progressView)
        
        estimatedProgressObserver = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            self?.progressView.progress = Float(webView.estimatedProgress)
        }
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let fixed = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        fixed.width = 26
        toolbarItems = [backItem, fixed, forwardItem, spacer, reloadItem]
    }
    
    private func load() {
        if documentServerUrlString.isEmpty {
            showAlert(title: "Error", message: "You must specify the document server address, the \"DocumentServerURL\" value in the Info.plist file.")
            return
        }
        
        guard let url = URL(string: documentServerUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            return
        }
        
        webView.load(URLRequest(url: url))
    }

    // MARK: - Actions
    
    @objc
    private func onReload(_ sender: Any) {
        webView.reload()
    }
    
    @objc
    private func onBack(_ sender: Any) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @objc
    private func onForward(_ sender: Any) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
}


// MARK: - WKNavigation Delegate

extension DocumentServerViewController: WKNavigationDelegate {
    
    func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        if progressView.isHidden {
            progressView.isHidden = false
        }
        
        UIView.animate(withDuration: 0.33, animations: { [weak self] in
            self?.progressView.alpha = 1.0
        })
    }
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction:
                 WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        guard let urlString = navigationAction.request.url?.absoluteString else {
            decisionHandler(.cancel)
            return
        }

        // Open document link
        if urlString.contains(openDocumentMarker),
           let redirectUrl = navigationAction.request.url?.appendingQueryParameters(additionalQueryParameters)
        {
            decisionHandler(.cancel)
            navigator.navigate(to: .documentServerEditor(url: redirectUrl))
        } else {
            reloadItem.isEnabled = true
            backItem.isEnabled = webView.canGoBack
            forwardItem.isEnabled = webView.canGoForward
            
            title = navigationAction.request.url?.host ?? ""
            
            decisionHandler(.allow)
        }

    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        
        reloadItem.isEnabled = true
        backItem.isEnabled = webView.canGoBack
        forwardItem.isEnabled = webView.canGoForward
        
        UIView.animate(withDuration: 0.33, animations: { [weak self] in
            self?.progressView.alpha = 0.0
            },completion: { [weak self] isFinished in
                self?.progressView.isHidden = isFinished
        })
    }
    
}

extension DocumentServerViewController : WKUIDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        webView.load(navigationAction.request)
        return nil;
    }
    
}
