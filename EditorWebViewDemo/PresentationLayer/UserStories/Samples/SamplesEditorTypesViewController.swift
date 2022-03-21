//
//  SamplesEditorTypesViewController.swift
//  EditorWebViewDemo
//
//  Created by Alexander Yuzhin on 18.03.2022.
//  Copyright © 2022 Ascensio System SIA. All rights reserved.
//

import UIKit

class SamplesEditorTypesViewController: BaseTableViewController {

    // MARK: - Properties
    
    var tableData: [[String: Any]]? {
        didSet {
            tableView?.reloadData()
        }
    }
    
    // MARK: - Lifecycle Methods
    
    init() {
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - Table view data source

extension SamplesEditorTypesViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableData?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tableData?[section]["samples"] as? [Any])?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableData?[section]["type"] as? String
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let editor = tableData?[indexPath.section] as? [String: Any],
            let samples = editor["samples"] as? [[String: Any]]
        else { return UITableViewCell() }
        
        let cell = UITableViewCell()
        cell.textLabel?.text = samples[indexPath.row]["title"] as? String
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let editor = tableData?[indexPath.section] as? [String: Any],
           let samples = editor["samples"] as? [[String: Any]],
           let config = samples[indexPath.row]["config"] as? String
        {
            navigator.navigate(to: .editor(config: config))
        }
    }


}
