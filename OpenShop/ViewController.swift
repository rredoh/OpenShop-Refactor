//
//  ViewController.swift
//  OpenShop
//
//  Created by Jefferson Setiawan on 16/07/19.
//  Copyright © 2019 Jefferson Setiawan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var shopNameTextField: UITextField!
    @IBOutlet var shopDomainTextField: UITextField!
    @IBOutlet var shopNameErrorLabel: UILabel!
    @IBOutlet var shopDomainErrorLabel: UILabel!
    @IBOutlet var cityNameLabel: UILabel!
    @IBOutlet var cityNameButton: UIButton!
    @IBOutlet var cityNameErrorLabel: UILabel!
    @IBOutlet var postalCodeLabel: UILabel!
    @IBOutlet var postalCodeButton: UIButton!
    @IBOutlet var postalCodeErrorLabel: UILabel!
    @IBOutlet var openShopButton: UIButton!
    
    private let shopNetwork = ShopNetwork()
    
    // MARK: Local properties
    
    private var selectedCity: City? {
        didSet {
            cityNameLabel.text = selectedCity?.name ?? "Pilih Kota"
            cityNameErrorLabel.text = nil
        }
    }
    
    private var selectedPostalCode: String? {
        didSet {
            postalCodeLabel.text = selectedPostalCode
            postalCodeErrorLabel.text = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Buka Tokomu"
        shopNameErrorLabel.text = nil
        shopDomainErrorLabel.text = nil
        cityNameErrorLabel.text = nil
        postalCodeErrorLabel.text = nil
        
        shopNameTextField.addTarget(self, action: #selector(shopNameDidChange), for: .editingChanged)
        shopDomainTextField.addTarget(self, action: #selector(shopDomainDidChange), for: .editingChanged)
        
        postalCodeButton.addTarget(self, action: #selector(postalCodeTapped), for: .touchUpInside)
        
        openShopButton.addTarget(self, action: #selector(didTapOpenShop), for: .touchUpInside)
    }
    
    @objc private func postalCodeTapped() {
        guard selectedCity != nil else {
            cityNameErrorLabel.text = ErrorString.notSelectCityFirst
            return
        }
        cityNameErrorLabel.text = nil
        performSegue(withIdentifier: "toPostalCode", sender: nil)
    }
    
    @objc private func shopNameDidChange() {
        let shopName = shopNameTextField.text ?? ""
        
        // MARK: Shop Name Validation
        
        guard shopName.count >= 3 else {
            shopNameErrorLabel.text = ErrorString.below3Characters
            return
        }
        
        // contain space at the beginning or end
        guard shopName.trimmingCharacters(in: .whitespaces) == shopName else {
            shopNameErrorLabel.text = ErrorString.shopNameContainWhitespace
            return
        }
        shopNetwork.checkShopNameValidation(shopName: shopName) { isSuccess in
            if !isSuccess {
                shopNameErrorLabel.text = ErrorString.shopNameNotAvailable
            } else {
                shopNameErrorLabel.text = nil
            }
        }
        
        shopNetwork.requestShopDomainSuggestion(shopName: shopName) { shopDomainSuggestion in
            shopDomainTextField.text = shopDomainSuggestion
            shopDomainErrorLabel.text = nil
        }
    }
    
    @objc private func shopDomainDidChange() {
        let shopDomain = shopDomainTextField.text ?? ""
        shopNetwork.checkShopDomainValidation(shopDomain: shopDomain) { isSuccess in
            if !isSuccess {
                shopDomainErrorLabel.text = ErrorString.shopDomainNotAvailable
            } else {
                shopDomainErrorLabel.text = nil
            }
        }
    }
    
    @objc private func didTapOpenShop() {
        if shopNameTextField?.text == nil || shopNameTextField?.text == "" {
            shopNameErrorLabel.text = ErrorString.emptyShopName
        }
        if shopDomainTextField?.text == nil || shopDomainTextField?.text == "" {
            shopDomainErrorLabel.text = ErrorString.emptyShopDomain
        }
        
        if selectedCity == nil {
            cityNameErrorLabel.text = ErrorString.emptyCity
        }
        
        if selectedPostalCode == nil {
            postalCodeErrorLabel.text = ErrorString.emptyPostalCode
        }
        // valid shop name
        // valid shop domain
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { fatalError("Invalid segue identifier \(String(describing: segue.identifier)).") }
        
        if identifier == "toCity" {
            if let destination = segue.destination as? CityTableViewController {
                destination.onSelectCity = { [weak self] city in
                    self?.selectedCity = city
                }
            }
        }
        
        if identifier == "toPostalCode" {
            if let destination = segue.destination as? PostalCodeTableViewController {
                destination.postalCodes = selectedCity?.postalCodes ?? []
                destination.onSelectPostalCode = { [weak self] postalCode in
                    self?.selectedPostalCode = postalCode
                }
            }
        }
    }
}

public struct ErrorString {
    public static let below3Characters = "Harus lebih dari 3 karakter"
    public static let shopNameContainWhitespace = "Tidak boleh ada spasi di awal atau akhir nama toko"
    public static let shopNameNotAvailable = "Nama Toko tidak tersedia"
    public static let shopDomainNotAvailable = "Domain Toko tidak tersedia"
    public static let notSelectCityFirst = "Harap Pilih kota terlebih dahulu"
    public static let emptyShopName = "Harap Masukkan Nama Toko"
    public static let emptyShopDomain = "Harap Masukkan Domain Toko"
    public static let emptyCity = "Harap Pilih Kota"
    public static let emptyPostalCode = "Harap Pilih Kode Pos"
}
