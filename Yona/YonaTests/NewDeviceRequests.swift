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
        var randomPhoneNumber = Int(arc4random_uniform(9999999))
        let password = NSUUID().UUIDString
        let keychain = KeychainSwift()
        keychain.set(password, forKey: YonaConstants.keychain.yonaPassword)
        
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]
        //Get user goals
        APIServiceManager.sharedInstance.postUser(body) { (success, message, code, users) in
            if success == false{
                XCTFail()
            }
            
            APIServiceManager.sharedInstance.putNewDevice("+31343" + String(randomPhoneNumber), onCompletion: { (success, message, code) in
                if success{
                    expectation.fulfill()
                }
            })
        }
        waitForExpectationsWithTimeout(10.0, handler:nil)
    }
}