//
//  ShopNetwork.swift
//  OpenShop
//
//  Created by Jefferson Setiawan on 21/07/19.
//  Copyright © 2019 Jefferson Setiawan. All rights reserved.
//

import Foundation

public class ShopNetwork {
    public init() {}
    public func checkShopNameValidation(shopName: String, completion: (Bool) -> Void) {
        guard !shopName.contains("no") else {
            completion(false)
            return
        }
        completion(true)
    }
    
    public func requestShopDomainSuggestion(shopName: String, completion: (String) -> Void) {
        let domainEquivalent = shopName.replacingOccurrences(of: " ", with: "-")
        completion("\(domainEquivalent)-2")
    }
    
    public func checkShopDomainValidation(shopDomain: String, completion: (Bool) -> Void) {
        guard shopDomain.contains("-2") else {
            completion(false)
            return
        }
        completion(true)
    }
    
    public func openShop(shopName: String, shopDomain: String, cityId: Int, postalCode: String, completion: (Bool) -> Void) {
        guard cityId == 2 else {
            completion(false)
            return
        }
        completion(true)
    }
}
