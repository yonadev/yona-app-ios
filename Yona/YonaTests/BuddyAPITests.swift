//
//  BuddyAPITests.swift
//  Yona
//
//  Created by Ben Smith on 11/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
import XCTest
@testable import Yona

class BuddyAPITests: XCTestCase {
    
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

    func testPostBuddy(){
        let expectation = expectationWithDescription("Waiting to respond")
        
        let randomPhoneNumber = String(Int(arc4random_uniform(9999999)))
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31999" + randomPhoneNumber,
             "nickname": "RQ"]
        
        UserRequestManager.sharedInstance.postUser(body, confirmCode: nil) { (success, message, code, user) in
            print("PASSWORD:   " + KeychainManager.sharedInstance.getYonaPassword()!)
            print("USER ID:   " + KeychainManager.sharedInstance.getUserID()!)
            UserRequestManager.sharedInstance.confirmMobileNumber(["code":YonaConstants.testKeys.otpTestCode], onCompletion: { (success, message, code) in
                UserRequestManager.sharedInstance.postUser(body, confirmCode: nil) { (success, message, code, user) in
                    let postBuddyBody: [String:AnyObject] = [
                        "sendingStatus": "REQUESTED",
                        "receivingStatus": "REQUESTED",
                        "message": "Hi there, would you want to become my buddy?",
                        "_embedded": [
                            "yona_user": [
                                "emailAddress": "richard@quin.net",
                                "firstNameKey": "Richard",
                                "lastNameKeys": "Quin",
                                "mobileNumberKeys": "+3169993999399393"
                            ]
                        ]
                    ]
                    BuddyRequestManager.sharedInstance.requestNewbuddy(postBuddyBody, onCompletion: { (success, message, code) in
                        XCTAssert(success, message!)
                        if success {
                            expectation.fulfill()
                        }
                    })
                }
            })
        }
        waitForExpectationsWithTimeout(100.0, handler:nil)
    }
}