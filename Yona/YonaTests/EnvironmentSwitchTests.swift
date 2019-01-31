//
//  EnvironmentSwitchTests.swift
//  YonaTests
//
//  Created by Vishal Revdiwala on 6/12/18.
//  Copyright © 2018 Yona. All rights reserved.
//

import XCTest
@testable import Yona

class EnvironmentSwitchTests: XCTestCase {
    
    let welcome = WelcomeViewController()
    let user = UserRequestManager.sharedInstance
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.m
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRemoveWhiteSpacesFromString() {
        let expectedURL = "https://app.prd.yona.nu/"
        let result = welcome.removeWhitespaceFromURL(url: "https://app.prd.yona.nu/      ")
        XCTAssertEqual(result, expectedURL)
    }
    
    func testcompareAndSwapSchemes_positive(){
        let userDBURL = "http://app.prd.yona.nu/xyz"
        let environmentURL = "https://app.prd.yona.nu/"
        let keychainURL = "/xyz"
        let expectedURL = "https://app.prd.yona.nu/xyz"
        let result = UserRequestManager.sharedInstance.compareAndSwapSchemes(userURLStr: userDBURL, environmentBaseURLStr: environmentURL, storedUserUrlStr: keychainURL)
         XCTAssertEqual(result, expectedURL)
    }
    
    func testcompareAndSwapSchemes_negative(){
        let userDBURL = "https://app.prd.yona.nu/xyz"
        let environmentURL = "https://app.prd.yona.nu/"
        let keychainURL = "/xyz"
        let expectedURL = keychainURL
        let result = UserRequestManager.sharedInstance.compareAndSwapSchemes(userURLStr: userDBURL, environmentBaseURLStr: environmentURL, storedUserUrlStr: keychainURL)
         XCTAssertEqual(result, expectedURL)
    }
}
