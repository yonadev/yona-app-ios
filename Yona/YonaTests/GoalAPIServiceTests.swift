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
    
    func testGetGoalsOfTypeBudgetGoal(){
        //setup
        let expectation = expectationWithDescription("Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999))
        
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
            //we need to now get the activity link from our activities
            APIServiceManager.sharedInstance.getActivityLinkForActivityName(.socialString, onCompletion: { (success, socialActivityCategoryLink, message, code) in
                    //set body for goal
                    let bodyBudgetSocialGoal = [
                        "@type": "BudgetGoal",
                        "_links": [
                            "yona:activityCategory": ["href": socialActivityCategoryLink]
                        ],
                        "maxDurationMinutes": "10"
                    ]
                    APIServiceManager.sharedInstance.getActivityLinkForActivityName(.newsString, onCompletion: { (success, newsActivityCategoryLink, message, code) in

                        let bodyBudgetNewsGoal = [
                            "@type": "BudgetGoal",
                            "_links": [
                                "yona:activityCategory": ["href": newsActivityCategoryLink]
                            ],
                            "maxDurationMinutes": "30"
                        ]
                        
                        //now we can post the goal
                        APIServiceManager.sharedInstance.postUserGoals(bodyBudgetSocialGoal, onCompletion: { (success, message, code, goal, error) in
                            if success {
                                //now we can post the goal
                                APIServiceManager.sharedInstance.postUserGoals(bodyBudgetNewsGoal, onCompletion: { (success, message, code, goal, error) in
                                    if success {
                                        //no
                                        APIServiceManager.sharedInstance.getGoalsOfType(.BudgetGoalString, onCompletion: { (success, message, code, goals, err) in
                                            if let goalsUnwrap = goals {
                                                if success {
                                                    for goal in goalsUnwrap {
                                                        print(goal.goalType)
                                                        XCTAssertFalse(goal.goalType! != YonaConstants.GoalType.BudgetGoalString.rawValue)
                                                    }
                                                    expectation.fulfill()
                                                } else {
                                                    XCTFail(message!)
                                                }
                                            }
                                        })
                                    } else {
                                        XCTFail(message!)
                                    }
                                })
                            } else {
                                XCTFail(message!)
                            }
                        })
                })
            })
        }
        waitForExpectationsWithTimeout(10.0, handler:nil)

    }
    
    func testGetGoalsOfTypeTimeZone(){
        //setup
        let expectation = expectationWithDescription("Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999))
        var newsActivityCategoryLink: String?
        var socialActivityCategoryLink: String?
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
            //we need to now get the activity link from our activities
            APIServiceManager.sharedInstance.getActivityLinkForActivityName(.socialString, onCompletion: { (success, socialActivityCategoryLink, message, code) in
                    if success {
                        //set body for budget social goal
                        let bodyTimeZoneSocialGoal = [
                            "@type": "TimeZoneGoal",
                            "_links": [
                                "yona:activityCategory": ["href": socialActivityCategoryLink]
                            ],
                            "zones": ["8:00-17:00", "20:00-22:00", "22:00-20:00"]
                        ]
                    }
                APIServiceManager.sharedInstance.getActivityLinkForActivityName(.newsString, onCompletion: { (success, newsActivityCategoryLink, message, code) in
                    if success {
                        //set body for goal
                        let bodyTimeZoneNewsGoal = [
                            "@type": "TimeZoneGoal",
                            "_links": [
                                "yona:activityCategory": ["href": newsActivityCategoryLink]
                            ],
                            "zones": ["8:00-17:00", "20:00-22:00"]
                        ]
                    }
                    
                        //add budget goal
                        APIServiceManager.sharedInstance.postUserGoals(bodyTimeZoneSocialGoal, onCompletion: { (success, message, code, goal, error) in
                            if success {

                                APIServiceManager.sharedInstance.postUserGoals(bodyTimeZoneNewsGoal, onCompletion: { (success, message, code, goal, error) in
                                    if success {
                                        //no
                                        APIServiceManager.sharedInstance.getGoalsOfType(.TimeZoneGoalString, onCompletion: { (success, message, code, goals, err) in
                                            if let goalsUnwrap = goals {
                                                if success {
                                                    for goal in goalsUnwrap {
                                                        print(goal.goalType)
                                                        XCTAssertFalse(goal.goalType! != YonaConstants.GoalType.TimeZoneGoalString.rawValue)
                                                    }
                                                    expectation.fulfill()
                                                } else {
                                                    XCTFail(message!)
                                                }
                                            }
                                        })
                                    } else {
                                        XCTFail(message!)
                                    }
                                })
                            } else {
                                XCTFail(message!)
                            }
                        })
                })
                    
            })
            
        }
        waitForExpectationsWithTimeout(10.0, handler:nil)
        
    }
    
    func testGetGoalArray() {
        //setup
        let expectation = expectationWithDescription("Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999))
        
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
            
            APIServiceManager.sharedInstance.getGoalsArray({ (success, message, code, goals, error) in
                print(goals)
                XCTAssertTrue(success, "Received Goals")
                expectation.fulfill()
            })
        }
        waitForExpectationsWithTimeout(10.0, handler:nil)

    }
    
    func testGetUserGoal(){
        //setup
        let expectation = expectationWithDescription("Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999))
        
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]
        //Create user
        APIServiceManager.sharedInstance.postUser(body) { (success, message, code, users) in
            if success == false{
                XCTFail()
            }
            print("PASSWORD:" + KeychainManager.sharedInstance.getYonaPassword()!)
            //Get all the goals
            APIServiceManager.sharedInstance.getUserGoals{ (success, serverMessage, serverCode, goals, err) in
                if(success){
                    for goal in goals! {
                        print(goal.goalType)
                        print(goal.activityCategoryName)
                        //delete user goals
                        APIServiceManager.sharedInstance.deleteUserGoal(goal.goalID!, onCompletion: { (success, serverMessage, serverCode) in
                            if success == false {
                                XCTFail(serverMessage! + goal.goalID! ?? "Unknown error")
                            }
                        })
                    }
                    expectation.fulfill()
                } else {
                    XCTFail(serverMessage ?? "Unknown error")
                }
            }
        }
        waitForExpectationsWithTimeout(10.0, handler:nil)
        
    }
    
    func testPostUserGoal(){
        //setup
        let expectation = expectationWithDescription("Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999)) //phone number mustbe unique
        
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]
        
        //Create user
        //Create user
        APIServiceManager.sharedInstance.postUser(body) { (success, message, code, users) in
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
            }
        waitForExpectationsWithTimeout(10.0, handler:nil)

    }
    
    func testPostSameGoalTwiceCheckCorrectServerResponse() {
        //setup
        let expectation = expectationWithDescription("Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999)) //phone number mustbe unique
        
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]

        //Create user
        APIServiceManager.sharedInstance.postUser(body) { (success, message, code, users) in
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
                    XCTAssertTrue(serverCode == YonaConstants.serverCodes.cannotAddSecondGoalOnSameCategory, serverMessage ?? "Unknown error")
                    expectation.fulfill()
                    print(serverMessage)
                }
            })
        }
        waitForExpectationsWithTimeout(10.0, handler:nil)
    }
    
    func testDeleteAMandatoryGoal() {
        //setup
        let expectation = expectationWithDescription("Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999)) //phone number mustbe unique
        
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]
        //Create user
        APIServiceManager.sharedInstance.postUser(body) { (success, message, code, users) in
            if success == false{
                XCTFail()
            }
            print(KeychainManager.sharedInstance.getYonaPassword())
            print(KeychainManager.sharedInstance.getUserID())
            
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
                            XCTAssertTrue(serverCode == YonaConstants.serverCodes.cannotRemoveMandatoryGoal, serverMessage)
                            expectation.fulfill()
                        }
                    })
                }
            }
        }

        waitForExpectationsWithTimeout(10.0, handler:nil)
        
    }
    
    
    func testGetGoalWithID() {
        //setup
        let expectation = expectationWithDescription("Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999)) //phone number mustbe unique
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]
        //Create user
        APIServiceManager.sharedInstance.postUser(body) { (success, message, code, users) in
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
                        if let messageUnwrapped = serverMessage{
                            XCTFail(messageUnwrapped ?? "Unknown error")
                        }
                    }
                }
            } else {
                if let messageUnwrapped = message{
                    XCTFail(messageUnwrapped ?? "Unknown error")
                }
            }
        }
        waitForExpectationsWithTimeout(10.0, handler:nil)

    }
    
    func testDeleteGoal() {
        //setup
        let expectation = expectationWithDescription("Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999)) //phone number mustbe unique
        
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]
        //Create user
        APIServiceManager.sharedInstance.postUser(body) { (success, message, code, users) in
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
        }
        waitForExpectationsWithTimeout(100.0, handler:nil)
        
    }

}
