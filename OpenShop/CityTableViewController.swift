//
//  CityTableViewController.swift
//  OpenShop
//
//  Created by Jefferson Setiawan on 21/07/19.
//  Copyright © 2019 Jefferson Setiawan. All rights reserved.
//

import UIKit

class CityTableViewController: UITableViewController {
    public var cities: [City] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    public var onSelectCity: ((City) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Pilih Kota"
        self.cities = [
            City(id: 1, name: "Jakarta Utara", postalCodes: ["14240", "14241", "14242"]),
            City(id: 2, name: "Surabaya", postalCodes: ["60111", "60115", "60119"])
        ]
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cityCell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)

        cell.textLabel?.text = cities[indexPath.row].name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCity = cities[indexPath.row]
        onSelectCity?(selectedCity)
        self.navigationController?.popViewController(animated: true)
    }
}
