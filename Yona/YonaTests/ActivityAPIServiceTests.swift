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
        APIServiceManager.sharedInstance.getActivityCategories{ (success, serverMessage, serverCode, activities, err) in
            if success{
                for activity in activities! {
                    print(activity.activityCategoryName)
                }
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(10.0, handler:nil)
    }
    
    func testGetActivityCategoryWithID() {
        let expectation = expectationWithDescription("Waiting to respond")
        APIServiceManager.sharedInstance.getActivityCategories{ (success, serverMessage, serverCode, activities, err) in
            if success {
                let activity = activities![0]
                print(activity)

                APIServiceManager.sharedInstance.getActivityCategoryWithID(activity.activityID!, onCompletion: { (success, serverMessage, serverCode, activity, err) in
                    if success{
                        print(activity)
                        expectation.fulfill()
                    }
                })
            }
        }

        waitForExpectationsWithTimeout(10.0, handler:nil)
    }
}
