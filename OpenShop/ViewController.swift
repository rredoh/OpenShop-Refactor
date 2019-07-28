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
    private var isUserChangeDomainManually = false
    private var viewModel = OpenShopViewModel()
    private var postalCodeList: [String] = []
    
    // MARK: Local properties
    
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
        viewModel.shopNameErrorDidChanged = { errorMessage in
            self.shopNameErrorLabel.text = errorMessage
        }
        
        viewModel.onGetShopDomainSuggestion = { shopDomainSuggestion in
            self.shopDomainTextField.text = shopDomainSuggestion
        }
        
        viewModel.shopDomainErrorDidChanged = { errorMessage in
            self.shopDomainErrorLabel.text = errorMessage
        }
        
        viewModel.onCityChanged = { cityName in
            self.postalCodeLabel.text = "Pilih Kode Pos"
            self.cityNameLabel.text = cityName
            self.cityNameErrorLabel.text = nil
        }
        
        viewModel.cityErrorDidChanged = { errorMessage in
            self.cityNameErrorLabel.text = errorMessage
        }
        
        viewModel.goToPostalCode = { postalCodes in
            self.postalCodeList = postalCodes
            self.performSegue(withIdentifier: "toPostalCode", sender: nil)
        }
        
        viewModel.onPostalCodeChange = { postalCode in
            self.postalCodeLabel.text = postalCode
            self.postalCodeErrorLabel.text = nil
        }
        
        viewModel.postalCodeErrorDidChanged = { errorMessage in
            self.postalCodeErrorLabel.text = errorMessage
        }
        
        viewModel.onSuccessOpenShop = {
            let alertVc = UIAlertController(title: "Sukses", message: "Anda berhasil membuka Toko", preferredStyle: .alert)
            alertVc.addAction(UIAlertAction(title: "Tutup", style: .default))
            self.present(alertVc, animated: true)
        }
        
        viewModel.onFailedOpenShop = { errorMessage in
            let alertVc = UIAlertController(title: "Gagal", message: errorMessage, preferredStyle: .alert)
            alertVc.addAction(UIAlertAction(title: "Tutup", style: .default))
            self.present(alertVc, animated: true)
        }
    }
    
    @objc private func postalCodeTapped() {
        viewModel.tapPostalCodeTrigger()
    }
    
    @objc private func shopNameDidChange() {
        viewModel.shopNameDidChanged(shopNameTextField.text ?? "")
    }
    
    @objc private func shopDomainDidChange() {
        viewModel.checkDomainValidation(shopDomain: shopDomainTextField.text ?? "")
    }
    
    @objc private func didTapOpenShop() {
        viewModel.submitForm()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { fatalError("Invalid segue identifier \(String(describing: segue.identifier)).") }
        
        if identifier == "toCity" {
            if let destination = segue.destination as? CityTableViewController {
                destination.onSelectCity = { [weak self] city in
                    self?.viewModel.changeCity(city)
                }
            }
        }
        
        if identifier == "toPostalCode" {
            if let destination = segue.destination as? PostalCodeTableViewController {
                destination.postalCodes = self.postalCodeList
                destination.onSelectPostalCode = { [weak self] postalCode in
                    self?.viewModel.changePostalCode(postalCode)
                }
            }
        }
    }
}
