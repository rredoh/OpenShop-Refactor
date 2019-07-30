//
//  OpenShopTests.swift
//  OpenShopTests
//
//  Created by Jefferson Setiawan on 25/07/19.
//  Copyright © 2019 Jefferson Setiawan. All rights reserved.
//

import XCTest
@testable import OpenShop

class OpenShopTests: XCTestCase {
    var viewModel: OpenShopViewModel!
    var shopNetwork: ShopNetwork!
    
    override func setUp() {
        self.shopNetwork = ShopNetwork()
        self.viewModel = OpenShopViewModel(shopNetwork: shopNetwork)
    }
    
    func testShouldShowErrorWhenShopNameEmpty() {
        let expect = expectation(description: "error when shop name is empty")
        viewModel.shopNameErrorDidChanged = { errorMessage in
            if errorMessage == ErrorString.emptyShopName {
                expect.fulfill()
            }
        }
        viewModel.shopNameDidChanged("")
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldShowErrorWhenShopDomainEmpty() {
        let expect = expectation(description: "error when shop domain is empty")
        viewModel.shopDomainErrorDidChanged = { errorMessage in
            if errorMessage == ErrorString.emptyShopDomain {
                expect.fulfill()
            }
        }
        viewModel.checkDomainValidation(shopDomain: "")
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldErrorWhenShopNameBelow3Characters() {
        let expect = expectation(description: "error when below 3 characters")
        viewModel.shopNameErrorDidChanged = { errorMessage in
            if errorMessage == ErrorString.below3Characters {
                expect.fulfill()
            }
        }
        viewModel.shopNameDidChanged("as")
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShopNameShouldErrorWhenBelow3Characters() {
        let expect = expectation(description: "Should show error below 3 characters")
        viewModel.shopNameErrorDidChanged = { message in
            if message == ErrorString.below3Characters {
                expect.fulfill()
            }
        }
        
        viewModel.shopNameDidChanged("aa")
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShopNameShouldErrorIfContainLeadingSpace() {
        let expect = expectation(description: "Should show error contain leading space")
        viewModel.shopNameErrorDidChanged = { message in
            if message == ErrorString.shopNameContainWhitespace {
                expect.fulfill()
            }
        }
        
        viewModel.shopNameDidChanged(" Toko Saya")
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShopNameShouldErrorIfContainTrailingSpace() {
        let expect = expectation(description: "Should show error contain trailing space")
        viewModel.shopNameErrorDidChanged = { message in
            if message == ErrorString.shopNameContainWhitespace {
                expect.fulfill()
            }
        }
        
        viewModel.shopNameDidChanged("Toko ")
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // Addon
    func testShouldShowErrorWhenShopNameNotAvailable() {
        let expect = expectation(description: "Should show error when shop name not available")
        shopNetwork.checkShopNameValidation = { _, completion in
            completion(false)
        }
        viewModel.shopNameErrorDidChanged = { message in
            if message == ErrorString.shopNameNotAvailable {
                expect.fulfill()
            }
        }
        viewModel.shopNameDidChanged("Toko")
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldShowDomainSuggestion() {
        let expect = expectation(description: "shop domain should be suggested")
        viewModel.onGetShopDomainSuggestion = { domainSuggestion in
            expect.fulfill()
        }
        
        viewModel.shopNameDidChanged("Toko Saya")
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldShowErrorWhenDomainNotAvailable() {
        //TODO custom response in ShopNetwork
        shopNetwork.checkShopDomainValidation = { _, completion in
            completion(false)
        }
        let expect = expectation(description: "show error when domain not available")
        viewModel.shopDomainErrorDidChanged = { errorMessage in
            if errorMessage == ErrorString.shopDomainNotAvailable {
                expect.fulfill()
            }
        }
        
        viewModel.checkDomainValidation(shopDomain: "toko-saya")
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldNotShowErrorWhenDomainAvailable() {
        shopNetwork.checkShopDomainValidation = { _, completion in
            completion(true)
        }
        let expect = expectation(description: "should not show error when domain available")
        expect.isInverted = true
        viewModel.shopDomainErrorDidChanged = { errorMessage in
            if errorMessage != nil {
                expect.fulfill()
            }
        }
        
        viewModel.checkDomainValidation(shopDomain: "toko-saya-2")
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldShowErrorWhenShopDomainBelow3Characters() {
        let expect = expectation(description: "should show error when shop domain below 3 characters")
        viewModel.shopDomainErrorDidChanged = { errorMessage in
            if errorMessage == ErrorString.below3Characters {
                expect.fulfill()
            }
        }
        
        viewModel.checkDomainValidation(shopDomain: "to")
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldNotSuggestDomainAfterUserManuallyInputShopDomain() {
        let expect = expectation(description: "should not suggest domain after user typing in shop domain")
        expect.isInverted = true
        expect.expectedFulfillmentCount = 2
        viewModel.onGetShopDomainSuggestion = { shopDomain in
            expect.fulfill()
        }
        let shopName = "toko toko"
        viewModel.shopNameDidChanged(shopName)
        viewModel.checkDomainValidation(shopDomain: "toko-saya")
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldShowErrorWhenUserTapPostalCodeBeforeSelectACity() {
        let expect = expectation(description: "should show error when user tap postal code before select a city")
        viewModel.cityErrorDidChanged = { errorMessage in
            if errorMessage == ErrorString.notSelectCityFirst {
                expect.fulfill()
            }
        }
        viewModel.tapPostalCodeTrigger()
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldResetPostalCodeAfterChangeCity() {
        let expect = expectation(description: "postal code reset")
        viewModel.postalCodeErrorDidChanged = { _ in
            expect.fulfill()
        }
        viewModel.shopNameDidChanged("asd")
        viewModel.changeCity(City(id: 1, name: "Jakarta", postalCodes: ["14240", "14241"]))
        viewModel.tapPostalCodeTrigger()
        viewModel.changePostalCode("14240")
        viewModel.changeCity(City(id: 2, name: "Jakarta", postalCodes: ["14240", "14241"]))
        viewModel.submitForm()
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldNotSuggestDomainIfUserManuallyInputTheDomain() {
        let expect = expectation(description: "should not suggest domain if user already input a domain")
        expect.isInverted = true
        viewModel.onGetShopDomainSuggestion = { _ in
            expect.fulfill()
        }
        viewModel.checkDomainValidation(shopDomain: "toko-saya")
        viewModel.shopNameDidChanged("change toko")
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShowErrorWhenSubmitFormWithEmptyForm() {
        let expect = expectation(description: "should show error when form is empty")
        expect.expectedFulfillmentCount = 4
        viewModel.shopNameErrorDidChanged = { errorMessage in
            if errorMessage == ErrorString.emptyShopName {
                expect.fulfill()
            }
        }
        
        viewModel.shopDomainErrorDidChanged = { errorMessage in
            if errorMessage == ErrorString.emptyShopDomain {
                expect.fulfill()
            }
        }
        
        viewModel.cityErrorDidChanged = { errorMessage in
            if errorMessage == ErrorString.emptyCity {
                expect.fulfill()
            }
        }
        viewModel.postalCodeErrorDidChanged = { errorMessage in
            if errorMessage == ErrorString.emptyPostalCode {
                expect.fulfill()
            }
        }
        viewModel.submitForm()
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testFailedSubmitForm() {
        shopNetwork.openShop = { _, _, _, _, completion in
            completion(false)
        }
        let expect = expectation(description: "should failed open shop")
        viewModel.onFailedOpenShop = { _ in
            expect.fulfill()
        }
        
        viewModel.shopNameDidChanged("toko saya")
        viewModel.checkDomainValidation(shopDomain: "toko-saya-2")
        viewModel.changeCity(City(id: 1, name: "Jakarta", postalCodes: ["14240", "14241"]))
        viewModel.tapPostalCodeTrigger()
        viewModel.changePostalCode("14240")
        viewModel.submitForm()
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSuccessSubmitForm() {
        let expect = expectation(description: "should success open shop")
        viewModel.onSuccessOpenShop = {
            expect.fulfill()
        }
        
        viewModel.shopNameDidChanged("toko saya")
        viewModel.checkDomainValidation(shopDomain: "toko-saya-2")
        viewModel.changeCity(City(id: 2, name: "Surabaya", postalCodes: ["14240", "14241"]))
        viewModel.tapPostalCodeTrigger()
        viewModel.changePostalCode("14240")
        viewModel.submitForm()
        waitForExpectations(timeout: 1, handler: nil)
    }
}
