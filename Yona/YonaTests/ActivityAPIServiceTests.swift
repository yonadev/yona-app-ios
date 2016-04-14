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
    
    func testGetActivitiesArray() {
        //setup
        let path = "http://85.222.227.142/users/"
        let keychain = KeychainSwift()
        guard let yonaPassword = keychain.get(YonaConstants.keychain.yonaPassword) else { return }
        let expectation = expectationWithDescription("Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999))
        
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]
        //    func makeUserRequest(path: String, password: String, userID: String, body: UserData, httpMethod: String, httpHeader:[String:String], onCompletion: APIServiceResponse) {
        let httpHeader = ["Content-Type": "application/json", "Yona-Password": yonaPassword]
        
        //Get user goals
        Manager.sharedInstance.makeRequest(path, body: body, httpMethod:YonaConstants.httpMethods.post, httpHeader: httpHeader, onCompletion: { success, json, err in
            if success == false{
                XCTFail()
            }
            
            APIServiceManager.sharedInstance.getActivitiesArray({ (success, message, code, activities, error) in
                print(activities)
                XCTAssertTrue(success, "Received Activities")
                expectation.fulfill()
            })
        })
    }
}
