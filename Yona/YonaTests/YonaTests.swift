//
//  YonaTests.swift
//  YonaTests
//
//  Created by Alessio Roberto on 23/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import XCTest
//import APILoginManager

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
    
    func testUserRequestReturnsJSON() {
        let expectation = expectationWithDescription("")
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31612345678",
             "nickname": "RQ"]
        let path = "http://85.222.227.142/users/"
        APILoginManager.sharedInstance.makePostRequest(path, body: body, onCompletion: { json, err in
            if let _ = json {
//                XCTAssert(JSONObject,"JSON Object is emprty")
                expectation.fulfill()
            }
        })

        waitForExpectationsWithTimeout(5.0, handler:nil)
    }
}
