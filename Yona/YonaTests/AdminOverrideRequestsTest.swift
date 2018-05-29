//
//  AdminOverrideRequestTests.swift
//  Yona
//
//  Created by Ben Smith on 03/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

import XCTest
@testable import Yona

class AdminOverrideRequestTests: XCTestCase {
    
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
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testAdminRequestOverride() {
        let expectation = self.expectation(description: "Waiting to respond")
        
        let body =
            ["firstName": "Ben",
             "lastName": "Smith",
             "mobileNumber": "+31625222867",
             "nickname": "BTS"]
        UserRequestManager.sharedInstance.postUser(body, confirmCode: nil) { (success, message, code, user) in
            print("PASSWORD:   " + KeychainManager.sharedInstance.getYonaPassword()!)
            print("USER ID:   " + KeychainManager.sharedInstance.getUserID()!)
            UserRequestManager.sharedInstance.postUser(body, confirmCode: nil) { (success, message, code, user) in
                if code == YonaConstants.serverCodes.errorUserExists {
                    AdminRequestManager.sharedInstance.adminRequestOverride(body, onCompletion: { (success, message, code) in
                        //if success then the user is sent OTP code, they are taken to this screen, get an OTP in text message must enter it
                        if success {
                            //send the OTP code with the post user request
                            UserRequestManager.sharedInstance.postUser(body, confirmCode: YonaConstants.testKeys.otpTestCode, onCompletion: { (success, message, code, user) in
                                XCTAssert(success, message!)
                                if success{
                                    expectation.fulfill()
                                }
                            })
                        }
                    })
                }
            }
        }
        waitForExpectations(timeout: 10.0, handler:nil)
        
    }
}
