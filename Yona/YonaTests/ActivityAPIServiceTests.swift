//
//  ActivityAPIServiceTests.swift
//  Yona
//
//  Created by Ben Smith on 13/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import XCTest
@testable import Yona

class ActivityAPIServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testGetActivityCategories() {
        let expectation = expectationWithDescription("Waiting to respond")
        
        APIServiceManager.sharedInstance.getActivityCategories { (success) in
            if success{
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(10.0, handler:nil)
    }
    
    func testGetActivityCategoryWithID() {
        let expectation = expectationWithDescription("Waiting to respond")
        let activityID = "cb580b4e-9670-4454-a5ca-3414f79f17b3"
        APIServiceManager.sharedInstance.getActivityCategoryWithID(activityID, onCompletion: { success, json, err in
            if success{
                print(json)
                expectation.fulfill()
            }
        })
        waitForExpectationsWithTimeout(10.0, handler:nil)
    }
}
