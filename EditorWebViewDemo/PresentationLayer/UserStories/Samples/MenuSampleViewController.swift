//
//  MenuSampleViewController.swift
//  EditorWebViewDemo
//
//  Created by Alexander Yuzhin on 18.03.2022.
//  Copyright © 2022 Ascensio System SIA. All rights reserved.
//

import UIKit

class MenuSampleViewController: BaseTableViewController {

    // MARK: - Properties
    
    private let tableData: [[String: Any]] = [
        [
            "title": "Using DocumentServer",
            "destination": Destination.documentServer,
            "description": "This category demonstrates an example of integrating ONLYOFFICE editors via WebView based on a demonstration example of the ONLYOFFICE DocumentServer."
        ],[
            "title": "Using API Configuration",
            "destination": Destination.sampleCategory,
            "description": "This category demonstrates an example of the integration of ONLYOFFICE editors via WebView based on configuration and processing the events described in the api.onlyoffice.com/editors documentation."
        ]
    ]
    
    // MARK: - Lifecycle Methods
    
    init() {
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "ONLYOFFICE Editors Sample"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = tableData[indexPath.section]["title"] as? String
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let destination = tableData[indexPath.section]["destination"] as? Destination {
            navigator.navigate(to: destination)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return tableData[section]["description"] as? String
    }
}
