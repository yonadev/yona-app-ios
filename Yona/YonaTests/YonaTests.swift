//
//  YonaTests.swift
//  YonaTests
//
//  Created by Alessio Roberto on 23/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import XCTest

@testable import Yona

class YonaTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testUserRequestReturnsData() {
        let expectation = expectationWithDescription("Waiting to respond")
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31825459377",
             "nickname": "RQ"]

        let password = "1234"
        
        APIServiceManager.sharedInstance.postUser(body, password: password) { (flag) in
            XCTAssert(APIServiceManager.sharedInstance.newUser != nil)
            
            let result = APIServiceManager.sharedInstance.newUser!
            let mobileNumber = result.mobileNumber
            XCTAssertTrue(mobileNumber == body["mobileNumber"])
            
            APIServiceManager.sharedInstance.deleteUser(password, onCompletion: { (success) in
                XCTAssertTrue(success)
                expectation.fulfill()
            })
        }

        waitForExpectationsWithTimeout(5.0, handler:nil)
    }
    
    func testDeletionOfUser() {
        
    }
}
