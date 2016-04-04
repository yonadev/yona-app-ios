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
            print("Post response")
            XCTAssert((APIServiceManager.sharedInstance.newUser) != nil)
            
            let result = APIServiceManager.sharedInstance.newUser!
            let mobileNumber = result.mobileNumber
            XCTAssertTrue(mobileNumber == body["mobileNumber"])
            
            APIServiceManager.sharedInstance.deleteUser({ (success) in
                print("Delete response")
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
             "mobileNumber": "+31033409377",
             "nickname": "RQ"]
        
        UserManager.sharedInstance.makePostRequest(path, password: password, body: body) { json, err in
            if let json = json,
                let code = json["mobileNumberConfirmationCode"]{
                //store the json in an object
                APIServiceManager.sharedInstance.newUser = Users.init(userData: json)
                let userID = APIServiceManager.sharedInstance.newUser?.userID
                let pathMobileConfirm = YonaConstants.environments.test + YonaConstants.commands.users + userID! + YonaConstants.commands.mobileConfirm
                let httpHeader = ["Content-Type": "application/json", "Yona-Password": password,"id":userID!]
                UserManager.sharedInstance.makeRequest(pathMobileConfirm, password: password, userID: userID!, body:["code": code], httpMethod: "POST", httpHeader: httpHeader, onCompletion: { success in
                    XCTAssertTrue(success)
                    let deletePath = path + userID!
                    UserManager.sharedInstance.makeRequest(deletePath, password: password, userID: userID!, body:[:], httpMethod: "DELETE", httpHeader: httpHeader, onCompletion: { success in
                        if(success){
                            expectation.fulfill()
                        }
                    })
                })
                
            }
        }
        waitForExpectationsWithTimeout(15.0, handler:nil)
    }
    
    func testConfirmMobileOTPResend() {
        let path = "http://85.222.227.142/users/"
        let password = NSUUID().UUIDString
        let expectation = expectationWithDescription("Waiting to respond")
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31622324577",
             "nickname": "RQ"]
        
        UserManager.sharedInstance.makePostRequest(path, password: password, body: body) { json, err in
            if let json = json {
                //store the json in an object
                APIServiceManager.sharedInstance.newUser = Users.init(userData: json)
                let userID = APIServiceManager.sharedInstance.newUser?.userID
                let pathMobileConfirm = YonaConstants.environments.test + YonaConstants.commands.users + userID! + YonaConstants.commands.mobileConfirm
                let httpHeader = ["Content-Type": "application/json", "Yona-Password": password,"id":userID!]

                UserManager.sharedInstance.makeRequest(pathMobileConfirm, password: password, userID: userID!, body:[:], httpMethod: "POST", httpHeader: httpHeader, onCompletion: { success in
                        XCTAssertTrue(success)
                        let deletePath = path + userID!
                        UserManager.sharedInstance.makeRequest(deletePath, password: password, userID: userID!, body:[:], httpMethod: "DELETE", httpHeader: httpHeader, onCompletion: { success in
                            if(success){
                                expectation.fulfill()
                            }
                        })
                })
            }
        }
        waitForExpectationsWithTimeout(15.0, handler:nil)
    }
    
    func testUserReturned() {
        let path = "http://85.222.227.142/users/"
        let keychain = KeychainSwift()
        guard let yonaPassword = keychain.get(YonaConstants.keychain.yonaPassword) else { return }
        let expectation = expectationWithDescription("Waiting to respond")
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+39992727777",
             "nickname": "RQ"]
        UserManager.sharedInstance.makePostRequest(path, password: yonaPassword, body: body) { json, err in
            if let json = json {
                let user = Users.init(userData: json)
                //store the json in an object
                APIServiceManager.sharedInstance.newUser = user
                let userID = user.userID
                let httpHeader = ["Content-Type": "application/json", "Yona-Password": yonaPassword, "id":userID!, "includePrivateData":"true"]
                let getUserPath = path + userID!
                
                UserManager.sharedInstance.makeRequest(getUserPath, password: yonaPassword, userID: userID!, body: [:], httpMethod: YonaConstants.httpMethods.get, httpHeader: httpHeader, onCompletion: { success in
                    XCTAssert((APIServiceManager.sharedInstance.newUser) != nil)
                    
                    let result = APIServiceManager.sharedInstance.newUser!
                    let mobileNumber = result.mobileNumber
                    XCTAssertTrue(mobileNumber == body["mobileNumber"])
                    XCTAssertTrue(success)
                    let deletePath = path + userID!
                    UserManager.sharedInstance.makeRequest(deletePath, password: yonaPassword, userID: userID!, body:[:], httpMethod: "DELETE", httpHeader: httpHeader, onCompletion: { success in
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
