//
//  YonaTests.swift
//  YonaTests
//
//  Created by Alessio Roberto on 23/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import XCTest

@testable import Yona

class YonaTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testUserRequestReturnsData() {
        let expectation = expectationWithDescription("Waiting to respond")
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31033409377",
             "nickname": "RQ"]
        
        APIServiceManager.sharedInstance.postUser(body) { (flag) in
            XCTAssert(APIServiceManager.sharedInstance.newUser != nil)
            
            let result = APIServiceManager.sharedInstance.newUser!
            let mobileNumber = result.mobileNumber
            XCTAssertTrue(mobileNumber == body["mobileNumber"])
            
            APIServiceManager.sharedInstance.deleteUser({ (success) in
                XCTAssertTrue(success)
                expectation.fulfill()
            })
            

        }

        waitForExpectationsWithTimeout(5.0, handler:nil)
    }
    
    func testConfirmMobile() {
        let path = "http://85.222.227.142/users/"
        let password = NSUUID().UUIDString
        let expectation = expectationWithDescription("Waiting to respond")
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+3123223465",
             "nickname": "RQ"]
        
        UserManager.sharedInstance.makePostRequest(path, password: password, body: body) { json, err in
            if let json = json,
                let code = json["mobileNumberConfirmationCode"]{
                //store the json in an object
                APIServiceManager.sharedInstance.newUser = Users.init(userData: json)
                let userID = APIServiceManager.sharedInstance.newUser?.userID
                let pathMobileConfirm = YonaPath.environments.test + YonaPath.commands.users + userID! + YonaPath.commands.mobileConfirm

                UserManager.sharedInstance.makeRequest(pathMobileConfirm, password: password, userID: userID!, body:["code": code], httpMethod: "POST", onCompletion: { success in
                    XCTAssertTrue(success)
                    let deletePath = path + userID!
                    UserManager.sharedInstance.makeRequest(deletePath, password: password, userID: userID!, body:[:], httpMethod: "DELETE", onCompletion: { success in
                        if(success){
                            expectation.fulfill()
                        }
                    })
                })
                
            }
        }
        waitForExpectationsWithTimeout(15.0, handler:nil)
    }

}
