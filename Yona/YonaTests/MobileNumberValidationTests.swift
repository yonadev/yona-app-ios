//
//  MobileNumberValidationTests.swift
//  YonaTests
//
//  Created by Vishal Revdiwala on 07/08/18.
//  Copyright © 2018 Yona. All rights reserved.
//

import XCTest
@testable import Yona


class MobileNumberValidationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMobileNumberStartsWithPlus(){
        let mobileNumberWithPlus = "+310987654321"
        XCTAssertTrue(mobileNumberWithPlus.isValidMobileNumber())
    }
    
    func testMobileNumberStartsWithoutPlus(){
        let mobileNumberWithoutPlus = "310987654321"
        XCTAssertFalse(mobileNumberWithoutPlus.isValidMobileNumber())
    }
    
    func testMobileNumberHasMinimumSixDigits(){
        let sixDigitMobileNumber = "+310987"
        XCTAssertTrue(sixDigitMobileNumber.isValidMobileNumber())
    }
    
    func testMobileNumberHasMorethanTwentyDigits(){
        let moreThanTwentyDigitMobileNumber = "+31098712344556612345678934567893456789345678"
        XCTAssertFalse(moreThanTwentyDigitMobileNumber.isValidMobileNumber())
    }
    
    func testFormatDutchCountryCodePrefix() {
        let mobileNumber = "+310987654321"
        let formattedMobileNumber = "+31987654321"
        let result = mobileNumber.formatDutchCountryCodePrefix()
        XCTAssertEqual(result, formattedMobileNumber)
    }
    
    
    
}
