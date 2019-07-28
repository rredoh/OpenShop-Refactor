//
//  PostalCodeTableViewController.swift
//  OpenShop
//
//  Created by Jefferson Setiawan on 21/07/19.
//  Copyright © 2019 Jefferson Setiawan. All rights reserved.
//

import UIKit

class PostalCodeTableViewController: UITableViewController {
    public var postalCodes = [String]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    public var onSelectPostalCode: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Pilih Kode Pos"
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "postalCodeCell")
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postalCodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postalCodeCell", for: indexPath)
        
        cell.textLabel?.text = postalCodes[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPostalCode = postalCodes[indexPath.row]
        onSelectPostalCode?(selectedPostalCode)
        self.navigationController?.popViewController(animated: true)
    }
}
