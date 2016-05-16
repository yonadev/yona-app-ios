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
        let expectation = expectationWithDescription("Waiting to respond")
        
        var randomPhoneNumber = String(Int(arc4random_uniform(9999999)))
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31999" + randomPhoneNumber,
             "nickname": "RQ"]
        
        UserRequestManager.sharedInstance.postUser(body, confirmCode: nil) { (success, message, code, user) in
            print("PASSWORD:   " + KeychainManager.sharedInstance.getYonaPassword()!)
            print("USER ID:   " + KeychainManager.sharedInstance.getUserID()!)
            UserRequestManager.sharedInstance.confirmMobileNumber(["code":YonaConstants.testKeys.otpTestCode], onCompletion: { (success, message, code) in
                randomPhoneNumber = String(Int(arc4random_uniform(9999999)))
                
                let postBuddyBody: [String:AnyObject] = [
                    postBuddyBodyKeys.sendingStatus.rawValue: buddyRequestStatus.REQUESTED.rawValue,
                    postBuddyBodyKeys.receivingStatus.rawValue: buddyRequestStatus.REQUESTED.rawValue,
                    postBuddyBodyKeys.message.rawValue: "Hi there, would you want to become my buddy?",
                    postBuddyBodyKeys._embedded.rawValue: [
                        postBuddyBodyKeys.yona_user.rawValue: [
                            addUserKeys.emailAddress.rawValue: "richard@quin.net",
                            addUserKeys.firstNameKey.rawValue: "Richard",
                            addUserKeys.lastNameKeys.rawValue: "Quin",
                            addUserKeys.mobileNumberKeys.rawValue: "+31999" + randomPhoneNumber
                        ]
                    ]
                ]
                
                BuddyRequestManager.sharedInstance.requestNewbuddy(postBuddyBody, onCompletion: { (success, message, code) in
                    XCTAssert(success, message!)
                    if success {
                        MessageRequestManager.sharedInstance.getMessages(10, page: 1, onCompletion: { (success, serverMessage, serverCode, message, messages) in
                            if(success){
                                expectation.fulfill()
                            }
                        })
                    }
                })
            })
        }
        waitForExpectationsWithTimeout(100.0, handler:nil)
    }
}