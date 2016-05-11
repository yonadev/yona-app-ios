//
//  PinResetAPIServiceTests.swift
//  Yona
//
//  Created by Ben Smith on 21/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import XCTest
@testable import Yona

class PinResetAPIServiceTests: XCTestCase {

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
    
    func testUserRequestPinReset() {
        let expectation = expectationWithDescription("Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999))
        
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+316" + String(randomPhoneNumber),
             "nickname": "RQ"]
        
        UserRequestManager.sharedInstance.postUser(body, confirmCode: nil) { (success, message, code, user) in
            print("PASSWORD:   " + KeychainManager.sharedInstance.getYonaPassword()!)
            print("USER ID:   " + KeychainManager.sharedInstance.getUserID()!)
            
            //confirm mobile number check, static code
            UserRequestManager.sharedInstance.confirmMobileNumber(["code":YonaConstants.testKeys.otpTestCode]) { success, message, code in
                if(success){
                    PinResetRequestManager.sharedInstance.pinResetRequest{ (success, pincode, message, code) in
                        XCTAssert(success, pincode!)
                        expectation.fulfill()
                    }
                }
            }

            
        }
        waitForExpectationsWithTimeout(100.0, handler:nil)
    }
    
    func testUserRequestPinVerify() {
        let expectation = expectationWithDescription("Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999))
        
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+316" + String(randomPhoneNumber),
             "nickname": "RQ"]
        
        UserRequestManager.sharedInstance.postUser(body, confirmCode: nil) { (success, message, code, user) in
            print("PASSWORD:   " + KeychainManager.sharedInstance.getYonaPassword()!)
            print("USER ID:   " + KeychainManager.sharedInstance.getUserID()!)
            
            //confirm mobile number check, static code
            UserRequestManager.sharedInstance.confirmMobileNumber(["code":YonaConstants.testKeys.otpTestCode]) { success, message, code in
                if(success){
                    //reset pincode
                    PinResetRequestManager.sharedInstance.pinResetRequest{ (success, pincode, message, code) in
                        //the user waits 24 hours and then 
                        let bodyVerifyPin = ["code": YonaConstants.testKeys.otpTestCode]
                        //reset verify code withotp
                        PinResetRequestManager.sharedInstance.pinResetVerify(bodyVerifyPin) { (success, pincode, message, code) in
                            XCTAssert(success, message!)
                            if success {
                                XCTAssert(success, message!)
                                expectation.fulfill()
                            }
                        }
                    }
                }
            }
            
        }
        waitForExpectationsWithTimeout(100.0, handler:nil)
    }
    
    func testUserRequestPinClear() {
        let expectation = expectationWithDescription("Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999))
        
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+316" + String(randomPhoneNumber),
             "nickname": "RQ"]
        
        UserRequestManager.sharedInstance.postUser(body, confirmCode: nil) { (success, message, code, user) in
            print("PASSWORD:   " + KeychainManager.sharedInstance.getYonaPassword()!)
            print("USER ID:   " + KeychainManager.sharedInstance.getUserID()!)
            
            //confirm mobile number check, static code
            UserRequestManager.sharedInstance.confirmMobileNumber(["code":YonaConstants.testKeys.otpTestCode]) { success, message, code in
                if(success){
                    PinResetRequestManager.sharedInstance.pinResetRequest{ (success, pincode, message, code) in
                        if success {
                            let bodyVerifyPin = ["code": YonaConstants.testKeys.otpTestCode]
                            //reset verify code withotp
                            PinResetRequestManager.sharedInstance.pinResetVerify(bodyVerifyPin) { (success, nil, message, code) in
                                XCTAssert(success, message!)
                                if success {
                                    PinResetRequestManager.sharedInstance.pinResetClear({ (success, nil, message, code) in
                                        XCTAssert(success, message!)
                                        if success {
                                            XCTAssert(success, message!)
                                            expectation.fulfill()
                                        }
                                    })
                                }
                            }
                            
                        }
                    }
                }
            }
            
        }
        waitForExpectationsWithTimeout(10.0, handler:nil)
    }

}
