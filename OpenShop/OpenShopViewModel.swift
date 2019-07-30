//
//  OpenShopViewModel.swift
//  OpenShop
//
//  Created by Jefferson Setiawan on 25/07/19.
//  Copyright © 2019 Jefferson Setiawan. All rights reserved.
//

import Foundation

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

struct OpenShopValidityStatus: OptionSet {
    static let validShopName = OpenShopValidityStatus(rawValue: 1 << 0)
    static let validShopDomain = OpenShopValidityStatus(rawValue: 1 << 1)
    static let validCity = OpenShopValidityStatus(rawValue: 1 << 2)
    static let validPostalCode = OpenShopValidityStatus(rawValue: 1 << 3)
    
    static let allValid: OpenShopValidityStatus = [.validShopName, .validShopDomain, .validCity, .validPostalCode]
    
    let rawValue: Int
}

public typealias ErrorDidChanged = (String?) -> Void
public typealias OnGetShopDomainSuggestion = (String) -> Void

public struct OpenShopViewModel {
    
    // MARK: Output
    public var shopNameErrorDidChanged: ErrorDidChanged?
    public var shopDomainErrorDidChanged: ErrorDidChanged?
    public var cityErrorDidChanged: ErrorDidChanged?
    public var onGetShopDomainSuggestion: OnGetShopDomainSuggestion?
    public var onCityChanged: ((String) -> Void)?
    public var goToPostalCode: (([String]) -> Void)?
    public var onPostalCodeChange: ((String) -> Void)?
    public var postalCodeErrorDidChanged: ErrorDidChanged?
    public var onSuccessOpenShop: (() -> Void)?
    public var onFailedOpenShop: ((String) -> Void)?
    
    private let shopNetwork: ShopNetwork
    private var validityStatus: OpenShopValidityStatus = []
    
    // private properties
    private var isUserChangeDomainManually = false
    private var shopName: String?
    private var shopDomain: String?
    private var selectedCity: City?
    private var selectedPostalCode: String? {
        didSet {
            if selectedPostalCode == nil {
                validityStatus.remove(.validPostalCode)
            } else {
                validityStatus.insert(.validPostalCode)
            }
        }
    }
    
    public init(shopNetwork: ShopNetwork = ShopNetwork()) {
        self.shopNetwork = shopNetwork
    }
    
    // user ketik shop name, validasi > 3
    // ga blh ada spasi di awal dan akhir
    // pengecekan server, kalau gagal, munculin error
    // minta server untuk dptin suggestion shop domain
    public mutating func shopNameDidChanged(_ shopName: String) {
        self.shopName = shopName
        validityStatus.remove(.validShopName)
        guard !shopName.isEmpty else {
            shopNameErrorDidChanged?(ErrorString.emptyShopName)
            return
        }
        guard shopName.count >= 3 else {
            shopNameErrorDidChanged?(ErrorString.below3Characters)
            return
        }
        
        guard shopName.trimmingCharacters(in: .whitespaces) == shopName else {
            shopNameErrorDidChanged?(ErrorString.shopNameContainWhitespace)
            return
        }
        
        suggestShopDomain(shopName: shopName)
        
        shopNetwork.checkShopNameValidation(shopName) { isSuccess in
            if isSuccess {
                shopNameErrorDidChanged?(nil)
                validityStatus.insert(.validShopName)
            } else {
                shopNameErrorDidChanged?(ErrorString.shopNameNotAvailable)
            }
        }
    }
    
    // user ganti, ngecek ke server apakah valid atau ga
    public mutating func checkDomainValidation(shopDomain: String) {
        isUserChangeDomainManually = true
        self.shopDomain = shopDomain
        validityStatus.remove(.validShopDomain)
        guard !shopDomain.isEmpty else {
            shopDomainErrorDidChanged?(ErrorString.emptyShopDomain)
            return
        }
        guard shopDomain.count >= 3 else {
            shopDomainErrorDidChanged?(ErrorString.below3Characters)
            return
        }
        shopNetwork.checkShopDomainValidation(shopDomain) { isValid in
            if isValid {
                shopDomainErrorDidChanged?(nil)
                validityStatus.insert(.validShopDomain)
            } else {
                shopDomainErrorDidChanged?(ErrorString.shopDomainNotAvailable)
            }
        }
    }
    
    public mutating func suggestShopDomain(shopName: String) {
        guard isUserChangeDomainManually == false else { return }
        shopNetwork.requestShopDomainSuggestion(shopName) { (shopDomainSuggestion) in
            self.validityStatus.insert(.validShopDomain)
            self.shopDomain = shopDomainSuggestion
            onGetShopDomainSuggestion?(shopDomainSuggestion)
            shopDomainErrorDidChanged?(nil)
        }
    }
    
    public mutating func changeCity(_ city: City) {
        self.selectedCity = city
        self.selectedPostalCode = nil
        self.validityStatus.insert(.validCity)
        onCityChanged?(city.name)
    }
    
    public func tapPostalCodeTrigger() {
        guard let city = selectedCity else {
            cityErrorDidChanged?(ErrorString.notSelectCityFirst)
            return
        }
        
        cityErrorDidChanged?(nil)
        goToPostalCode?(city.postalCodes)
    }
    
    public mutating func changePostalCode(_ postalCode: String) {
        selectedPostalCode = postalCode
        onPostalCodeChange?(postalCode)
    }
    
    public func submitForm() {
        if !validityStatus.contains(.validShopName) {
            if shopName?.isEmpty == true || shopName == nil {
                shopNameErrorDidChanged?(ErrorString.emptyShopName)
            }
        }
        
        if !validityStatus.contains(.validShopDomain) {
            if shopDomain?.isEmpty == true || shopDomain == nil {
                shopDomainErrorDidChanged?(ErrorString.emptyShopDomain)
            }
        }
        
        if !validityStatus.contains(.validCity) {
            cityErrorDidChanged?(ErrorString.emptyCity)
        }
        if !validityStatus.contains(.validPostalCode) {
            postalCodeErrorDidChanged?(ErrorString.emptyPostalCode)
        }
        guard validityStatus == .allValid else {
            return
        }
        
        shopNetwork.openShop(shopName!, shopDomain!, selectedCity!.id, selectedPostalCode!) { isSuccess in
            if isSuccess {
                onSuccessOpenShop?()
            } else {
                onFailedOpenShop?("Kesalahan pada server")
            }
        }
    }
}
