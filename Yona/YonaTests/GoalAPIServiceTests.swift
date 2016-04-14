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
    
    func testGetGoalArray() {
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
            
            APIServiceManager.sharedInstance.getGoalsArray({ (success, message, code, goals, error) in
                print(goals)
                XCTAssertTrue(success, "Received Goals")
                expectation.fulfill()
            })
        })
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
            //Get all the goals
            APIServiceManager.sharedInstance.getUserGoals{ (success, serverMessage, serverCode, goals, err) in
                if(success){
                    for goal in goals! {
                        print(goal.goalType)
                        print(goal.activityCategoryName)
                        //delete user goals
                        APIServiceManager.sharedInstance.deleteUserGoal(goal.goalID!, onCompletion: { (success, serverMessage, serverCode) in
                            if success == false {
                                XCTFail("Failed to delete goal" + goal.goalID!)
                            }
                        })
                    }
                    expectation.fulfill()
                } else {
                    if let json = json {
                        XCTFail(json[YonaConstants.serverResponseKeys.message] as! String)
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
        
        //Create user
        Manager.sharedInstance.makeRequest(path, body: body, httpMethod:YonaConstants.httpMethods.post, httpHeader: httpHeader, onCompletion: { success, json, err in
                if success == false{
                    XCTFail()
                }
                print(KeychainManager.sharedInstance.getYonaPassword())

                //Get their goals (usere are always created with a gambling goal that cannot be removed
                APIServiceManager.sharedInstance.getUserGoals{ (success, serverMessage, serverCode, goals, err) in
                    if success {
                        print(goals)
                        var currentGoal:Goal?
                        //we want to remove the news goal so find it
                        for goal in goals! {
                            if goal.activityCategoryName == "news" {
                                currentGoal = goal
                            }
                        }
                        //body we want to post
                        let postGoalBody = [
                            "@type": "BudgetGoal",
                            "activityCategoryName": "news"
                        ]
                        //if we found the goal we want to remove it before we can post it else we get the server message "error.goal.cannot.add.second.on.activity.category"
                        if let currentGoal = currentGoal {
                            let currentGoalID = currentGoal.goalID!
                            print(currentGoalID)
                            print(currentGoal)
                            APIServiceManager.sharedInstance.deleteUserGoal(currentGoalID, onCompletion: { (success, serverMessage, serverCode) in
                                if success {
                                    APIServiceManager.sharedInstance.postUserGoals(postGoalBody, onCompletion: {
                                        (success, serverMessage, serverCode, goal, err) in
                                        if success {
                                            //Get the goals again to see if the goals have been updated after our post
                                            APIServiceManager.sharedInstance.getUserGoals{ (success, serverMessage, serverCode, goals, err) in
                                                print(goals)
                                                var currentGoalAfterPost:Goal?
                                                //we want to remove the news goal so find it
                                                for goal in goals! {
                                                    if goal.activityCategoryName == "news" {
                                                        currentGoalAfterPost = goal
                                                    }
                                                }
                                                //now we have the goal we posted...returned from current goals, so check it's category is the
                                                if let currentGoalAfterPost = currentGoalAfterPost {
                                                    let currentGoalAfterPostID = currentGoalAfterPost.goalID!
                                                    print(currentGoalAfterPostID)
                                                    XCTAssertTrue(currentGoalAfterPost.activityCategoryName == postGoalBody["activityCategoryName"], "Goal has been posted")
                                                    expectation.fulfill()
                                                }
                                            }
                                        } else {
                                            XCTFail()
                                        }
                                    })
                                } else {
                                    //see what message from the server...in this case we are trying to remove a goal you are not allowed to remove
                                    if let serverCode = serverCode where
                                        serverCode == YonaConstants.serverCodes.cannotRemoveMandatoryGoal {
                                            print(serverMessage)
                                        
                                    }
                                }


                            })
                        } else { //if we cannot find a "news" goal then we need to post it
                            APIServiceManager.sharedInstance.postUserGoals(postGoalBody, onCompletion: {
                                (success, serverMessage, serverCode, goal, err) in
                                if success {
                                    APIServiceManager.sharedInstance.getUserGoals{ (success, serverMessage, serverCode, goals, err) in
                                        print(goals)
                                        var currentGoal:Goal?
                                        //we want to remove the news goal so find it
                                        for goal in goals! {
                                            if goal.activityCategoryName == "news" {
                                                currentGoal = goal
                                            }
                                        }
                                        if let currentGoal = currentGoal {
                                            XCTAssertTrue(currentGoal.activityCategoryName == postGoalBody["activityCategoryName"], "Goal has been posted")
                                            expectation.fulfill()
                                        }
                                    }
                                } else {
                                    XCTFail()
                                }
                            })
                        }

                    }
                    
                }
            })
        waitForExpectationsWithTimeout(10.0, handler:nil)

    }
    
    func testPostSameGoalTwiceCheckCorrectServerResponse() {
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
        
        //Create user
        Manager.sharedInstance.makeRequest(path, body: body, httpMethod:YonaConstants.httpMethods.post, httpHeader: httpHeader, onCompletion: { success, json, err in
            if success == false{
                XCTFail()
            }
            print(KeychainManager.sharedInstance.getYonaPassword())
            
            //We want to post a gambling goal, but it is already there so we know the server will response negatively
            let postGoalBody = [
                "@type": "BudgetGoal",
                "activityCategoryName": "gambling"
            ]

            APIServiceManager.sharedInstance.postUserGoals(postGoalBody, onCompletion: {
                (success, serverMessage, serverCode, goal, err) in
                //see what message from the server...in this case we are trying to remove a goal you are not allowed to remove
                if let serverCode = serverCode,
                    let serverMessage = serverMessage {
                    XCTAssertTrue(serverCode == YonaConstants.serverCodes.cannotAddSecondGoalOnSameCategory, serverMessage!)
                    expectation.fulfill()
                    print(serverMessage)
                }
            })
        })
        waitForExpectationsWithTimeout(10.0, handler:nil)
    }
    
    func testDeleteAMandatoryGoal() {
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
        
        //Create user
        Manager.sharedInstance.makeRequest(path, body: body, httpMethod:YonaConstants.httpMethods.post, httpHeader: httpHeader, onCompletion: { success, json, err in
            if success == false{
                XCTFail()
            }
            print(KeychainManager.sharedInstance.getYonaPassword())
            
            //Get their goals (usere are always created with a gambling goal that cannot be removed
            APIServiceManager.sharedInstance.getUserGoals{ (success, serverMessage, serverCode, goals, err) in
                if success {
                    print(goals)
                    var currentGoal:Goal?
                    //Get the gambling goal as we need the ID to remove it
                    for goal in goals! {
                        if goal.activityCategoryName == "gambling" {
                            currentGoal = goal
                        }
                    }
                    //if we found the goal we want to remove it before we can post it else we get the server message "error.goal.cannot.add.second.on.activity.category"
                    APIServiceManager.sharedInstance.deleteUserGoal(currentGoal!.goalID!, onCompletion: { (success, serverMessage, serverCode) in
                        if let serverCode = serverCode,
                            let serverMessage = serverMessage{
                            //we expect the server to say you cannot delete a mandatory goal like gambling
                            XCTAssertTrue(serverCode == YonaConstants.serverCodes.cannotRemoveMandatoryGoal, serverMessage!)
                            expectation.fulfill()
                        }
                    })
                }
                
            }
        })
        waitForExpectationsWithTimeout(10.0, handler:nil)
        
    }
    
    
    func testGetGoalWithID() {
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
            if success {
                APIServiceManager.sharedInstance.getUserGoals{ (success, serverMessage, serverCode, goals, err) in
                    if(success){
                        for goal in goals! {
                            print("Goal ID Before" + goal.goalID!)

                            APIServiceManager.sharedInstance.getUsersGoalWithID(goal.goalID!, onCompletion: { (success, serverMessage, serverCode, goalReturned, err) in
                                print(goalReturned?.activityCategoryName)
                                print(goalReturned?.goalType)
                                print(goalReturned?.goalID)
                                
                                if success {
                                    expectation.fulfill()
                                    XCTAssert(goal.goalID == goalReturned?.goalID)
                                }

                            })
                        }

                    } else {
                        if let json = json {
                            XCTFail(json[YonaConstants.serverResponseKeys.message] as! String)
                        }
                    }
                }
            } else {
                XCTFail(json![YonaConstants.serverResponseKeys.message] as! String)
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
            
            //store the json in an object
            APIServiceManager.sharedInstance.getUserGoals { (success, serverMessage, serverCode, goalArray, err) in
                if success{
                    var currentGoal:Goal?

                    //look for a goal "news"
                    for goal in goalArray! {
                        if goal.activityCategoryName == "news" {
                            currentGoal = goal
                        }
                    }
                    let postGoalBody = [
                        "@type": "BudgetGoal",
                        "activityCategoryName": "news"
                    ]
                    //If our goal is already there, we can delete it
                    if let currentGoal = currentGoal { //if we found a goal with news (this is a removeable goal)
                        APIServiceManager.sharedInstance.deleteUserGoal(currentGoal.goalID!, onCompletion: { (success, serverMessage, serverCode) in
                            if success {
                                expectation.fulfill()
                            } else {
                                XCTFail("Failed to delete")
                            }
                        })
                    } else { //if there is not news goal then post it...
                        APIServiceManager.sharedInstance.postUserGoals(postGoalBody, onCompletion: {
                            (success, serverMessage, serverCode, goal, err) in
                            //then once it is posted we can delete it
                                APIServiceManager.sharedInstance.deleteUserGoal(goal!.goalID!, onCompletion: { (success, serverMessage, serverCode) in
                                    if success {
                                        expectation.fulfill()
                                    } else {
                                        XCTFail("Failed to delete")
                                    }
                                })
                        })
                    }
                }
            }
        })
        waitForExpectationsWithTimeout(100.0, handler:nil)
        
    }

}
