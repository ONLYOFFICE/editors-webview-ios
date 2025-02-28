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
import JWT

class EditorViewController: BaseViewController {

    // MARK: - Properties
    
    private let activityIndicator: UIActivityIndicatorView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.hidesWhenStopped = true
        $0.startAnimating()
        return $0
    }(UIActivityIndicatorView(style: .medium))
    
    private var webView: WKWebView!
    private var editorEventsHandler: EditorEventsHandler!
    private var previewController = PreviewController()
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
    
    var config: String?
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Configure UI
        configureView()
        
        /// Loading the set url
        load()
    }
    
    private func configureView() {
        /// Setup WebView and layout
        
        editorEventsHandler = EditorEventsHandler(configuration: webViewConfiguration)
        editorEventsHandler.delegate = self
        
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
        guard let url = Bundle.main.url(forResource: "editor", withExtension: "html") else {
            return
        }
        
        var html = ""
        
        do {
            html = try String(contentsOf: url)
        } catch {
            print(error)
        }
        
        var config = config?
            .replacingOccurrences(of: "{KEY}", with: UUID().uuidString)
            .replacingOccurrences(of: "{DOC_URL_PATH}", with: Env.documentServerFilesUrl)
            .replacingOccurrences(of: "{CALLBACK_URL}", with: Env.editorCallbackUrl)
            .toDictionary() ?? [:]
        
        config["token"] = JWT.encode(claims: config, algorithm: .hs256(Env.documentServerJwtSecret.data(using: .utf8)!))
        
        let jsonString = (config.jsonString(prettify: true) ?? "")
            .dropLast()
            .dropFirst()
        
        html = html
            .replacingOccurrences(of: "{document_server_url}", with: Env.documentServerUrl)
            .replacingOccurrences(of: "{external_config}", with: jsonString)
        
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    private func callMethod(function: String, arg: Bool) {
        let javascript = "window.docEditor.\(function)(\(arg))"
        webView.evaluateJavaScript(javascript, completionHandler: nil)
    }
    
    private func callMethod(function: String, arg: String) {
        let javascript = "window.docEditor.\(function)(\"\(arg)\")"
        webView.evaluateJavaScript(javascript, completionHandler: nil)
    }
    
    private func callMethod(function: String, arg: [String: Any]) {
        guard
            let json = try? JSONSerialization.data(withJSONObject: arg, options: []),
            let jsonString = String(data: json, encoding: .utf8)
        else {
            return
        }
        
        let javascript = "window.docEditor.\(function)(\(jsonString))"
        webView.evaluateJavaScript(javascript, completionHandler: nil)
    }
    
    private func displayLoader(show: Bool) {
        show ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        activityIndicator.isHidden = !show
    }
    
    // MARK: - Public
    
    public func showMessage(_ msg: String) {
        callMethod(function: "showMessage", arg: msg)
    }
    
    public func insertImage(_ insertInfo: [String: Any]) {
        callMethod(function: "insertImage", arg: insertInfo)
    }

}

// MARK: - WebView Navigation Delegate

extension EditorViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        /// Handle download link
        if let url = navigationAction.request.url, url.absoluteString.contains("/cache/files/") {
            decisionHandler(.cancel)
            
            displayLoader(show: true)
            
            previewController.present(url: url, in: self) { [weak self] in
                self?.displayLoader(show: false)
            }
            
            return
        }
        
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        displayLoader(show: false)
    }
    
}

// MARK: - WebView UI Delegate

extension EditorViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView?
    {
        webView.load(navigationAction.request)
        return nil;
    }
    
}


// MARK: - EditorEvents Delegate

extension EditorViewController: EditorEventsDelegate {
    func onAppReady() {
        print("⚡️ ONLYOFFICE Document Editor is ready")
//        showMessage("ONLYOFFICE Document Editor is ready.")
    }
    
    func onDocumentReady() {
        print("⚡️ Document is loaded")
    }
    
    func onDownloadAs(fileType: String, url: String) {
        print("⚡️ ONLYOFFICE Document Editor create file: \(url)")
    }
    
    func onError(code: String, description: String) {
        print("⚡️ ONLYOFFICE Document Editor reports an error: code \(code), description \(description)");
        showAlert(title: "Error: \(code)", message: description)
    }
    
    func onInfo(mode: String) {
        print("⚡️ ONLYOFFICE Document Editor is opened in mode \(mode)");
    }
    
    func onRequestClose() {
        print("⚡️ ONLYOFFICE Document Editor is Request Close");
    }
    
    func onRequestInsertImage(type: String) {
        print("⚡️ The user is trying to insert an image by clicking the Image from Storage button")
        insertImage([
            "c": type,
            "fileType": "png",
            "url": " https://helpcenter.onlyoffice.com/images/logonew.png"
        ])
    }
    
    func onRequestUsers() {
        print("⚡️ The commenter can select other users for mention in the comments")
    }
    
    func onWarning(code: String, description: String) {
        print("⚡️ ONLYOFFICE Document Editor reports a warning: code \(code), description \(description)");
        showAlert(title: "Warning: \(code)", message: description)
    }
    
}
