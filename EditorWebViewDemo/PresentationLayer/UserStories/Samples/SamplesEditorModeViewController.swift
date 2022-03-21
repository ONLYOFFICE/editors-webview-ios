//
//  SamplesEditorModeViewController.swift
//  EditorWebViewDemo
//
//  Created by Alexander Yuzhin on 18.03.2022.
//  Copyright © 2022 Ascensio System SIA. All rights reserved.
//

import UIKit

class SamplesEditorModeViewController: BaseTableViewController {

    // MARK: - Properties
    
    private let samplesUrl = Bundle.main.url(forResource: "samples", withExtension: "plist")
    private var tableData: [[String: Any]]?
    
    // MARK: - Lifecycle Methods
    
    init() {
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "ONLYOFFICE Editor Sample"
        
        loadData()
    }
    
    private func loadData() {
        if let url = samplesUrl {
            do {
                let infoPlistData = try Data(contentsOf: url)
                tableData = try PropertyListSerialization.propertyList(from: infoPlistData, options: [], format: nil) as? [[String: Any]]
                tableView.reloadData()
            } catch {
                print(error)
            }
        }
    }
}

// MARK: - Table view data source

extension SamplesEditorModeViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = tableData?[indexPath.row]["category"] as? String
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let title = tableData?[indexPath.row]["category"] as? String,
           let editors = tableData?[indexPath.row]["editors"] as? [[String: Any]]
        {
            navigator.navigate(to: .sampleType(title: title, data: editors))
        }
    }
}
