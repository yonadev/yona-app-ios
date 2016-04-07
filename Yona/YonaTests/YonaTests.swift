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
             "mobileNumber": "+31645346271",
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
        waitForExpectationsWithTimeout(50.0, handler:nil)
    }
    
    func testConfirmMobileReturnsData(){

        //setup
        let path = "http://85.222.227.142/users/"
        let keychain = KeychainSwift()
        guard let yonaPassword = keychain.get(YonaConstants.keychain.yonaPassword) else { return }
        let expectation = expectationWithDescription("Waiting to respond")
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31033438377",
             "nickname": "RQ"]
        //    func makeUserRequest(path: String, password: String, userID: String, body: UserData, httpMethod: String, httpHeader:[String:String], onCompletion: APIServiceResponse) {
        let httpHeader = ["Content-Type": "application/json", "Yona-Password": yonaPassword]

        //Post user data
        UserManager.sharedInstance.makeUserRequest(path, body: body, httpMethod:YonaConstants.httpMethods.post, httpHeader: httpHeader, onCompletion: { json, err in
            if let json = json,
                let code = json["mobileNumberConfirmationCode"]{
                //store the json in an object
                let user = Users.init(userData: json)
                APIServiceManager.sharedInstance.newUser = user
                let userID = APIServiceManager.sharedInstance.newUser?.userID
                let pathMobileConfirm = YonaConstants.environments.test + YonaConstants.commands.users + userID! + YonaConstants.commands.mobileConfirm
                let httpHeader = ["Content-Type": "application/json", "Yona-Password": yonaPassword,"id":userID!]
                
                //Request user data
                UserManager.sharedInstance.makeRequest(pathMobileConfirm, body:["code": code], httpMethod: "POST", httpHeader: httpHeader, onCompletion: { success in
                    //if mobile confirm success
                    XCTAssertTrue(success)
                    if let deletePath = user.editLink{
                        //delete user so works on next test
                        UserManager.sharedInstance.makeRequest(deletePath, body:nil, httpMethod: "DELETE", httpHeader: httpHeader, onCompletion: { success in
                            if(success){
                                expectation.fulfill()
                            }
                        })
                    }
                })
            }
        })
        waitForExpectationsWithTimeout(15.0, handler:nil)
    }
    
    func testConfirmMobileOTPResend() {
        let path = "http://85.222.227.142/users/"
        let keychain = KeychainSwift()
        guard let yonaPassword = keychain.get(YonaConstants.keychain.yonaPassword) else { return }
        let expectation = expectationWithDescription("Waiting to respond")
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31622324577",
             "nickname": "RQ"]
        let httpHeader = ["Content-Type": "application/json", "Yona-Password": yonaPassword]

        UserManager.sharedInstance.makeUserRequest(path, body: body, httpMethod: YonaConstants.httpMethods.post, httpHeader: httpHeader, onCompletion: { json, err in
            if let json = json {
                //store the json in an object
                let user = Users.init(userData: json)
                APIServiceManager.sharedInstance.newUser = user
                let userID = APIServiceManager.sharedInstance.newUser?.userID
                let pathMobileConfirm = YonaConstants.environments.test + YonaConstants.commands.users + userID! + YonaConstants.commands.mobileConfirm
                let httpHeader = ["Content-Type": "application/json", "Yona-Password": yonaPassword,"id":userID!]

                UserManager.sharedInstance.makeRequest(pathMobileConfirm, body:nil, httpMethod: "POST", httpHeader: httpHeader, onCompletion: { success in
                        XCTAssertTrue(success)
                        if let deletePath = user.editLink{
                            UserManager.sharedInstance.makeRequest(deletePath, body:nil, httpMethod: "DELETE", httpHeader: httpHeader, onCompletion: { success in
                                if(success){
                                    expectation.fulfill()
                                }
                            })
                        }
                })
            }
        })
        waitForExpectationsWithTimeout(15.0, handler:nil)
    }
    
    func testUserReturned() {
        //setup new user
        let path = "http://85.222.227.142/users/"
        let keychain = KeychainSwift()
        guard let yonaPassword = keychain.get(YonaConstants.keychain.yonaPassword) else { return }
        let expectation = expectationWithDescription("Waiting to respond")
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31888233699",
             "nickname": "RQ"]
        let httpHeader = ["Content-Type": "application/json", "Yona-Password": yonaPassword]

        //post new user data
        UserManager.sharedInstance.makeUserRequest(path, body: body, httpMethod: YonaConstants.httpMethods.post, httpHeader: httpHeader, onCompletion: { json, err in
            if let json = json {
                //get the response of new user and store it
                let user = Users.init(userData: json)
                //store the json in an object
                
                //if the response is not nil
                APIServiceManager.sharedInstance.newUser = user
                let mobileNumber = user.mobileNumber
                
                
                if let getSelfLink = user.getSelfLink, let userID = user.userID {
                    let httpHeader = ["Content-Type": "application/json", "Yona-Password": yonaPassword]
                    
                    //get request to get user we just created!
                    UserManager.sharedInstance.makeUserRequest(getSelfLink, body: nil, httpMethod: YonaConstants.httpMethods.get, httpHeader: httpHeader, onCompletion: { json, err in
                        
                        if let json = json{
                            let userReturned = Users.init(userData: json)
                            //test if the posted mobile number is the one returned by our get request
                            XCTAssertTrue(mobileNumber == userReturned.mobileNumber)
                        }
                        //now tidy up and delete the user
                        if let deletePath = user.editLink{
                            let httpHeaderDelete = ["Content-Type": "application/json", "Yona-Password": yonaPassword,"id":userID]

                            UserManager.sharedInstance.makeRequest(deletePath, body:nil, httpMethod: "DELETE", httpHeader: httpHeaderDelete, onCompletion: { success in
                                if(success){
                                    expectation.fulfill()
                                }
                            })
                        }
                    })
                }
            }
        })
        waitForExpectationsWithTimeout(15.0, handler:nil)

    }
    
    func testUpdateUser(){
        let path = "http://85.222.227.142/users/"
        let keychain = KeychainSwift()
        guard let yonaPassword = keychain.get(YonaConstants.keychain.yonaPassword) else { return }
        let expectation = expectationWithDescription("Waiting to respond")
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31548576199",
             "nickname": "RQ"]
        let httpHeader = ["Content-Type": "application/json", "Yona-Password": yonaPassword]
        
        //post new user data
        UserManager.sharedInstance.makeUserRequest(path, body: body, httpMethod: YonaConstants.httpMethods.post, httpHeader: httpHeader, onCompletion: { json, err in
            if let json = json {
                //get the response of new user and store it
                let originalUser = Users.init(userData: json)
                
                //if the response is not nil
                APIServiceManager.sharedInstance.newUser = originalUser
                
                if let getEditLink = originalUser.editLink, let userID = originalUser.userID {
                    let httpHeader = ["Content-Type": "application/json", "Yona-Password": yonaPassword]
                    
                    let bodyUpdate =
                        ["firstName": "Ben",
                            "lastName": "Smith",
                            "mobileNumber": "+3199999999",
                            "nickname": "BTS"]
                    
                    //get request to get user we just created!
                    UserManager.sharedInstance.makeUserRequest(getEditLink, body: bodyUpdate, httpMethod: YonaConstants.httpMethods.put, httpHeader: httpHeader, onCompletion: { json, err in
                        
                        if let json = json{
                            let userReturned = Users.init(userData: json)
                            //test if name returned is updated
                            XCTAssertTrue(bodyUpdate["firstName"] == userReturned.firstName)
                            //name returned is different to what was originally posted
                            XCTAssertFalse(bodyUpdate["firstName"] == originalUser.firstName)

                        }
                        //now tidy up and delete the user
                        if let deletePath = originalUser.editLink{
                            let httpHeaderDelete = ["Content-Type": "application/json", "Yona-Password": yonaPassword, "id":userID]
                            
                            UserManager.sharedInstance.makeRequest(deletePath, body:bodyUpdate, httpMethod: YonaConstants.httpMethods.delete, httpHeader: httpHeaderDelete, onCompletion: { success in
                                if(success){
                                    expectation.fulfill()
                                }
                            })
                        }
                    })
                }
            }
        })
        waitForExpectationsWithTimeout(15.0, handler:nil)

    }
    
    func testConfirmMobileNumber(){
        //setup
        let path = "http://85.222.227.142/users/"
        let keychain = KeychainSwift()
        guard let yonaPassword = keychain.get(YonaConstants.keychain.yonaPassword) else { return }
        let expectation = expectationWithDescription("Waiting to respond")
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31888259687878",
             "nickname": "RQ"]
        let httpHeader = ["Content-Type": "application/json", "Yona-Password": yonaPassword]
        
        //Post user data
        UserManager.sharedInstance.makeUserRequest(path, body: body, httpMethod:YonaConstants.httpMethods.post, httpHeader: httpHeader, onCompletion: { json, err in
            if let json = json,
                let code = json["mobileNumberConfirmationCode"]{
                //store the json in an object
                let user = Users.init(userData: json)
                APIServiceManager.sharedInstance.newUser = user
                //confirm mobile number check
                APIServiceManager.sharedInstance.confirmMobileNumber(["code":code], onCompletion: { (success) in
                    if(success){
                        expectation.fulfill()
                    }
                    //now tidy up and delete the user
                    if let deletePath = user.editLink{
                        UserManager.sharedInstance.makeRequest(deletePath, body:body, httpMethod: YonaConstants.httpMethods.delete, httpHeader: httpHeader, onCompletion: { success in
                            if(success){
                                expectation.fulfill()
                            }
                        })
                    }
                })
                
            }
        })
        waitForExpectationsWithTimeout(100.0, handler:nil)
    }

}
