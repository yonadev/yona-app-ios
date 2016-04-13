//
//  GoalAPIServiceTests.swift
//  Yona
//
//  Created by Ben Smith on 12/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import XCTest
@testable import Yona

class GoalAPIServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
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
    
    func testGetUserGoal(){
        //setup
        let path = "http://85.222.227.142/users/"
        let keychain = KeychainSwift()
        guard let yonaPassword = keychain.get(YonaConstants.keychain.yonaPassword) else { return }
        let expectation = expectationWithDescription("Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999))
        
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]
        //    func makeUserRequest(path: String, password: String, userID: String, body: UserData, httpMethod: String, httpHeader:[String:String], onCompletion: APIServiceResponse) {
        let httpHeader = ["Content-Type": "application/json", "Yona-Password": yonaPassword]
        
        //Get user goals
        Manager.sharedInstance.makeRequest(path, body: body, httpMethod:YonaConstants.httpMethods.post, httpHeader: httpHeader, onCompletion: { success, json, err in
            if success == false{
                XCTFail()
            }
            if let json = json {
                //store the json in an object
                let user = Users.init(userData: json)
                APIServiceManager.sharedInstance.newUser = user
                //confirm mobile number check, static code
                APIServiceManager.sharedInstance.getUserGoals{ (success) in
                    if(success){
                        expectation.fulfill()
                    }
                }
            }
        })
        waitForExpectationsWithTimeout(10.0, handler:nil)
        
    }
    
    func testPostUserGoal(){
        //setup
        let path = "http://85.222.227.142/users/"
        let keychain = KeychainSwift()
        guard let yonaPassword = keychain.get(YonaConstants.keychain.yonaPassword) else { return }
        let expectation = expectationWithDescription("Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999)) //phone number mustbe unique
        
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]
        //    func makeUserRequest(path: String, password: String, userID: String, body: UserData, httpMethod: String, httpHeader:[String:String], onCompletion: APIServiceResponse) {
        let httpHeader = ["Content-Type": "application/json", "Yona-Password": yonaPassword]
        
        //Get user goals
        Manager.sharedInstance.makeRequest(path, body: body, httpMethod:YonaConstants.httpMethods.post, httpHeader: httpHeader, onCompletion: { success, json, err in
                if success == false{
                    XCTFail()
                }
            
                if let json = json {
                    let postGoalBody = [
                        "@type": "BudgetGoal",
                        "activityCategoryName": "gambling"
                    ]
                    //store the json in an object
                    let user = Users.init(userData: json)
                    APIServiceManager.sharedInstance.newUser = user
                    //confirm mobile number check, static code
                    APIServiceManager.sharedInstance.postUserGoals(postGoalBody, onCompletion: {
                        success in
                        if(success){
                            expectation.fulfill()
                        }
                    })
                }
        })
        waitForExpectationsWithTimeout(10.0, handler:nil)

    }

}
