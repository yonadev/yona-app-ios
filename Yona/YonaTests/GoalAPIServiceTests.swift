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
                let activityID = "cb580b4e-9670-4454-a5ca-3414f79f17b3"

                if let json = json {
                    //store the json in an object
                    let user = Users.init(userData: json)
                    APIServiceManager.sharedInstance.newUser = user
                    APIServiceManager.sharedInstance.getActivityCategoryWithID(activityID, onCompletion: { success, json, err in
                        if success{
                            print(json)
                            let postGoalBody = [
                                "@type": "BudgetGoal",
                                "activityCategoryName": "gambling"
                            ]

                            //confirm mobile number check, static code
                            APIServiceManager.sharedInstance.postUserGoals(postGoalBody, onCompletion: {
                                success, json, err in
                                if(success){
                                    expectation.fulfill()
                                }
                            })                        }
                    })

                }
        })
        waitForExpectationsWithTimeout(10.0, handler:nil)

    }
    
    func testDeleteGoal() {
        //create a user
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
        let httpHeader = ["Content-Type": "application/json", "Yona-Password": yonaPassword]
        Manager.sharedInstance.makeRequest(path, body: body, httpMethod:YonaConstants.httpMethods.post, httpHeader: httpHeader, onCompletion: { success, json, err in
            if success == false{
                XCTFail()
            }
            let activityID = "cb580b4e-9670-4454-a5ca-3414f79f17b3"
            
            if let json = json {
                //store the json in an object
                let user = Users.init(userData: json)
                APIServiceManager.sharedInstance.newUser = user
                
                //get possible activities
                APIServiceManager.sharedInstance.getActivityCategories({ (success) in
                    if success {
                        APIServiceManager.sharedInstance.getActivityCategoryWithID(activityID, onCompletion: { success, json, err in
                            if success{
                                print(json)
                                let activity = APIServiceManager.sharedInstance.newActivities!.activities[0]
                                let categoryName = activity.activityCategoryName! as String
                                let postGoalBody = [
                                    "@type": "TimeZoneGoal" ,
                                    "activityCategoryName": categoryName
                                ]
                                
                                //Add a users goals
                                APIServiceManager.sharedInstance.postUserGoals(postGoalBody, onCompletion: {
                                    success, json, err in
                                    if success == false {
                                        print(json!["message"] as! [BodyDataDictionary])
                                    }
                                    //delete user goals
//                                    APIServiceManager.sharedInstance.deleteUserGoal(<#T##goalID: String##String#>, onCompletion: <#T##APIResponse##APIResponse##(Bool) -> Void#>)({ (success) in
//                                        if(success){
//                                            expectation.fulfill()
//                                        }
//                                    })
                                    
                                })
                            }
                        })
                    }
                })

                
            }
        })
        waitForExpectationsWithTimeout(10.0, handler:nil)
        
    }

}
