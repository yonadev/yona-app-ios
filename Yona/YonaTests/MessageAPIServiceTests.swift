//
//  MessageAPIServiceTests.swift
//  Yona
//
//  Created by Ben Smith on 17/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//
import Foundation
import XCTest

@testable import Yona

class MessageAPIServiceTests: XCTestCase {
    
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
    
    func testGetMessages() {
        //setup
        let expectation = expectationWithDescription("Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(99999999))
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]
        
        //Post user data
        UserRequestManager.sharedInstance.postUser(body, confirmCode: nil) { (success, message, code, user) in
            if success {
                //confirm mobile number check, static code
                UserRequestManager.sharedInstance.confirmMobileNumber(["code":YonaConstants.testKeys.otpTestCode], onCompletion: { success, message, code in
                    MessageRequestManager.sharedInstance.getMessages(10, page: 1, onCompletion: { (success, serverMessage, serverCode, message, messages) in
                        if(success){
                            expectation.fulfill()
                        }
                    })

                })
            } else {
                XCTFail(message ?? "Unknown error")
            }
        }
        waitForExpectationsWithTimeout(10.0, handler:nil)
    }
}