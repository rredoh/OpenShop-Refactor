//
//  ShopNetwork.swift
//  OpenShop
//
//  Created by Jefferson Setiawan on 21/07/19.
//  Copyright © 2019 Jefferson Setiawan. All rights reserved.
//

import Foundation

public class ShopNetwork {
    var checkShopNameValidation = _checkShopNameValidation
    var requestShopDomainSuggestion = _requestShopDomainSuggestion
    
    /// Check shop Domain validation.
    ///
    /// - Parameters:
    ///    - shopDomain: Shop Domain
    ///    - completion: (Bool) -> Void, completion after network call
    var checkShopDomainValidation = _checkShopDomainValidation
    /// param: shopName: String, shopDomain: String, cityId: Int, postalCode: String, completion: (Bool) -> Void
    var openShop = _openShop
    public init() {}
}

func _checkShopNameValidation(shopName: String, completion: (Bool) -> Void) {
    guard !shopName.contains("no") else {
        completion(false)
        return
    }
    completion(true)
}

func _requestShopDomainSuggestion(shopName: String, completion: (String) -> Void) {
    let domainEquivalent = shopName.replacingOccurrences(of: " ", with: "-")
    completion("\(domainEquivalent)-2")
}

func _checkShopDomainValidation(shopDomain: String, completion: (Bool) -> Void) {
    guard shopDomain.contains("-2") else {
        completion(false)
        return
    }
    completion(true)
}

func _openShop(shopName: String, shopDomain: String, cityId: Int, postalCode: String, completion: (Bool) -> Void) {
    guard cityId == 2 else {
        completion(false)
        return
    }
    completion(true)
}
