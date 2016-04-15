//
//  YonaTests.swift
//  YonaTests
//
//  Created by Alessio Roberto on 23/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import XCTest

@testable import Yona

class UserAPIServiceTests: XCTestCase {
    
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
    
    func testUserRequestReturnsData() {
        let expectation = expectationWithDescription("Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999))

        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+316" + String(randomPhoneNumber),
             "nickname": "RQ"]
        
        APIServiceManager.sharedInstance.postUser(body) { (success, message, code, user) in
            print("Post response")
            XCTAssert((user) != nil)
            
            let mobileNumber = user!.mobileNumber
            XCTAssertTrue(mobileNumber == body["mobileNumber"])
            
            APIServiceManager.sharedInstance.deleteUser({ (success, serverMessage, serverCode) in
                print("Delete response")
                XCTAssertTrue(success)
                expectation.fulfill()
            })
            

        }
        waitForExpectationsWithTimeout(50.0, handler:nil)
    }
    
    func testConfirmMobileReturnsData(){

        //setup
        let expectation = expectationWithDescription("Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999))

        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]
        //Post user data
        APIServiceManager.sharedInstance.postUser(body) { (success, message, code, user) in
                let code = YonaConstants.testKeys.otpTestCode
                APIServiceManager.sharedInstance.confirmMobileNumber(["code": code], onCompletion: { (succes, message, code) in
                    //if mobile confirm success
                    XCTAssertTrue(success)
                        //delete user so works on next test
                        APIServiceManager.sharedInstance.deleteUser{ (succes, message, code) in
                            if(success){
                                expectation.fulfill()
                            } else {
                                XCTFail(message!)
                            }
                        }
                    
                })
            }
        waitForExpectationsWithTimeout(15.0, handler:nil)
    }
    
    func testConfirmMobileOTPResend() {
        let expectation = expectationWithDescription("Waiting to respond")
        let randomPhoneNumber = String(Int(arc4random_uniform(9999999)))
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+3162" + randomPhoneNumber,
             "nickname": "RQ"]

        //Post user data
        APIServiceManager.sharedInstance.postUser(body) { (success, message, code, user) in
                //confirm mobile number check, static code
                APIServiceManager.sharedInstance.otpResendMobile(nil, onCompletion: { success, message, code in
                    if(success){
                        expectation.fulfill()
                    } else {
                        XCTFail()
                    }
                    
                    //now tidy up and delete the user
                    APIServiceManager.sharedInstance.deleteUser({ (success, message, code) in
                        if(success){
                            expectation.fulfill()
                        } else {
                            XCTFail(message!)
                        }
                    })
                })
        }
        waitForExpectationsWithTimeout(10.0, handler:nil)
    }
    
    func testUserReturned() {
        //setup new user
        let expectation = expectationWithDescription("Waiting to respond")
        let randomPhoneNumber = String(Int(arc4random_uniform(9999999)))
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31999" + randomPhoneNumber,
             "nickname": "RQ"]

        //post new user data
        APIServiceManager.sharedInstance.postUser(body) { (success, message, code, user) in
            if let userUnwrapped = user {
                //if the response is not nil
                let mobileNumber = userUnwrapped.mobileNumber

                //get request to get user we just created!
                APIServiceManager.sharedInstance.getUser{ (success, message, code, user) in
                    if let userUnwrapped = user{
                        //test if the posted mobile number is the one returned by our get request
                        XCTAssertTrue(mobileNumber == userUnwrapped.mobileNumber)
                    }
                    APIServiceManager.sharedInstance.deleteUser({ (success, message, code) in
                        if(success){
                            expectation.fulfill()
                        } else {
                            XCTFail(message!)
                        }
                    })
                }
            }
        }
        
        waitForExpectationsWithTimeout(15.0, handler:nil)

    }
    
    func testUpdateUser(){
        //setup
        let expectation = expectationWithDescription("Waiting to respond")
        let randomPhoneNumber = String(Int(arc4random_uniform(9999999)))
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31999" + randomPhoneNumber,
             "nickname": "RQ"]
        
        //post new user data
        APIServiceManager.sharedInstance.postUser(body) { (success, message, code, user) in
            if let originalUser = user {
                //if the user is not nil
                let bodyUpdate =
                    ["firstName": "Ben",
                        "lastName": "Smith",
                        "mobileNumber": "+3199999999",
                        "nickname": "BTS"]
                
                //get request to get user we just created!
                APIServiceManager.sharedInstance.getUser({ (success, message, code, user) in
                    if let userReturned = user{
                        //test if name returned is updated
                        XCTAssertTrue(bodyUpdate["firstName"] == userReturned.firstName)
                        //name returned is different to what was originally posted
                        XCTAssertFalse(bodyUpdate["firstName"] == originalUser.firstName)
                        
                    }
                    //now tidy up and delete the user
                    APIServiceManager.sharedInstance.deleteUser({ (success, message, code) in
                        if(success){
                            expectation.fulfill()
                        } else {
                            XCTFail(message!)
                        }
                    })
                })
                
            }
        }
        waitForExpectationsWithTimeout(15.0, handler:nil)
    }
    
    func testConfirmMobileNumber(){
        //setup
        let expectation = expectationWithDescription("Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(99999999))
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]
        
        //Post user data
        APIServiceManager.sharedInstance.postUser(body) { (success, message, code, user) in
            if success {
                //confirm mobile number check, static code
                APIServiceManager.sharedInstance.confirmMobileNumber(["code":YonaConstants.testKeys.otpTestCode], onCompletion: { success, message, code in
                    if(success){
                        expectation.fulfill()
                    }
                    //now tidy up and delete the user
                    APIServiceManager.sharedInstance.deleteUser({ (success, message, code) in
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
