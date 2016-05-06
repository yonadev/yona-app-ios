//
//  PutNewDeviceRequests.swift
//  Yona
//
//  Created by Ben Smith on 18/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import XCTest
@testable import Yona

class NewDeviceAPIServiceTests: XCTestCase {
    
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
    
    func testPutNewDevice() {
        let expectation = expectationWithDescription("Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999))
        let password = NSUUID().UUIDString
        let keychain = KeychainSwift()
        keychain.set(password, forKey: YonaConstants.keychain.yonaPassword)
        
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]
        //Get user goals
        APIServiceManager.sharedInstance.postUser(body, confirmCode: nil) { (success, message, code, users) in
            if success == false{
                XCTFail()
            }
            
            let bodyConfirm =
            [
                "code": "1234"
            ]
            print("PASSWORD" + KeychainManager.sharedInstance.getYonaPassword()!)
            print("MOBILE NUMBER: +31343" + String(randomPhoneNumber))
            //confirm mobile
            APIServiceManager.sharedInstance.confirmMobileNumber(bodyConfirm){ (success, message, server) in
                if success {
                    //create a new device request
                    NewDeviceRequestManager.sharedInstance.putNewDevice { (success, message, code, deviceCode) in
                        XCTAssert(success, message!)
                        if success {
                            expectation.fulfill()
                        }
                    }
                }

            }
            

        }
        waitForExpectationsWithTimeout(10.0, handler:nil)
    }
    
    func testGetNewDevice() {
        let expectation = expectationWithDescription("Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999))
        let password = NSUUID().UUIDString
        let keychain = KeychainSwift()
        keychain.set(password, forKey: YonaConstants.keychain.yonaPassword)
        
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]
        //Get user goals
        APIServiceManager.sharedInstance.postUser(body, confirmCode: nil) { (success, message, code, users) in
            if success == false{
                XCTFail()
            }
            
            let bodyConfirm =
                [
                    "code": "1234"
            ]
            print("PASSWORD" + KeychainManager.sharedInstance.getYonaPassword()!)
            print("MOBILE NUMBER: +31343" + String(randomPhoneNumber))
            //confirm mobile
            APIServiceManager.sharedInstance.confirmMobileNumber(bodyConfirm){ (success, message, server) in
                if success {
                    //create a new device request, get the messages back and device passcode created by server
                    NewDeviceRequestManager.sharedInstance.putNewDevice { (success, message, serverCode, addDevicePassCode) in
                            NewDeviceRequestManager.sharedInstance.getNewDevice(addDevicePassCode!, mobileNumber: body[YonaConstants.jsonKeys.mobileNumberKeys]!) { (success, message, server, user) in
                                XCTAssert(success, message!)
                                print(addDevicePassCode!)
                                print(user)

                                if success {
                                    expectation.fulfill()
                                }
                            }
                    }
                }
                
            }
            
            
        }
        waitForExpectationsWithTimeout(100.0, handler:nil)
    }
    
    func testDeleteNewDeviceRequest() {
        let expectation = expectationWithDescription("Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999))
        let password = NSUUID().UUIDString
        let keychain = KeychainSwift()
        keychain.set(password, forKey: YonaConstants.keychain.yonaPassword)
        
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]
        //Get user goals
        APIServiceManager.sharedInstance.postUser(body, confirmCode: nil) { (success, message, code, users) in
            if success == false{
                XCTFail()
            }
            
            let bodyConfirm =
                [
                    "code": "1234"
            ]
            print("PASSWORD" + KeychainManager.sharedInstance.getYonaPassword()!)
            print("MOBILE NUMBER: +31343" + String(randomPhoneNumber))
            //confirm mobile
            APIServiceManager.sharedInstance.confirmMobileNumber(bodyConfirm){ (success, message, server) in
                if success {
                    //create a new device request, get the messages back and device passcode created by server
                    NewDeviceRequestManager.sharedInstance.putNewDevice { (success, message, serverCode, addDevicePassCode) in
                            NewDeviceRequestManager.sharedInstance.deleteNewDevice({ (success, message, code) in
                                XCTAssert(success, message!)
                                if success {
                                    expectation.fulfill()
                                }
                            })
                        }
                    }
                }
                
            }
        waitForExpectationsWithTimeout(100.0, handler:nil)
    }
}