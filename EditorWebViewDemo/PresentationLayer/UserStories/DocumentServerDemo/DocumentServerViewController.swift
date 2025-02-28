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

class DocumentServerViewController: BaseViewController {

    // MARK: - Properties
    
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
        if Env.documentServerExampleUrl.replacingOccurrences(of: "https://", with: "").isEmpty {
            showAlert(title: "Error", message: "You must specify the document server example page address for \"DOCUMENT_SERVER_EXAMPLE_URL\" value in configuration file.")
            return
        }
        
        guard let url = URL(string: Env.documentServerExampleUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
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
