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
    
    func testGetGoalsOfTypeNoGo(){
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
            APIServiceManager.sharedInstance.getGoalsOfType(.NoGoGoalString) { (success, message, code, goals, err) in
                if let goalsUnwrap = goals {
                    if success {
                        for goal in goalsUnwrap {
                            print(goal.goalType)
                            XCTAssertFalse(goal.goalType! != GoalType.NoGoGoalString.rawValue )
                        }
                        expectation.fulfill()
                    } else {
                        XCTFail(message!)
                    }
                }
            }

        }
        waitForExpectationsWithTimeout(10.0, handler:nil)
        
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
                let bodyBudgetSocialGoal: [String: AnyObject] = [
                    "@type": "BudgetGoal",
                    "_links": ["yona:activityCategory":
                        ["href": socialActivityCategoryLink!]
                    ],
                    "maxDurationMinutes": "10"
                ]
                APIServiceManager.sharedInstance.getActivityLinkForActivityName(.newsString, onCompletion: { (success, newsActivityCategoryLink, message, code) in
                    let bodyBudgetNewsGoal: [String: AnyObject] = [
                        "@type": "BudgetGoal",
                        "_links": [
                            "yona:activityCategory": ["href": newsActivityCategoryLink!]
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
                                                        XCTAssertFalse(goal.goalType! != GoalType.BudgetGoalString.rawValue)
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
                    //set body for budget social goal
                    let bodyTimeZoneSocialGoal: [String: AnyObject] = [
                        "@type": "TimeZoneGoal",
                        "_links": [
                            "yona:activityCategory": ["href": socialActivityCategoryLink!]
                        ],
                        "zones": ["8:00-17:00", "20:00-22:00", "22:00-20:00"]
                    ]
                APIServiceManager.sharedInstance.getActivityLinkForActivityName(.newsString, onCompletion: { (success, newsActivityCategoryLink, message, code) in
                        //set body for goal
                        let bodyTimeZoneNewsGoal: [String: AnyObject] = [
                            "@type": "TimeZoneGoal",
                            "_links": [
                                "yona:activityCategory": ["href": newsActivityCategoryLink!]
                            ],
                            "zones": ["8:00-17:00", "20:00-22:00"]
                        ]
                    
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
                                                        XCTAssertFalse(goal.goalType! != GoalType.TimeZoneGoalString.rawValue)
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
    
    func testGetAllTheGoalsArray() {
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
            
            APIServiceManager.sharedInstance.getAllTheGoalsArray{ (success, message, code, goals, error) in
                print(goals)
                XCTAssertTrue(success, "Received Goals")
                expectation.fulfill()
            }
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
            APIServiceManager.sharedInstance.getActivitiesArray{ (success, message, server, activities, error) in
                if success {
                    //Get all the goals
                    APIServiceManager.sharedInstance.getUserGoals(activities!){ (success, serverMessage, serverCode, goals, err) in
                        if(success){
                            for goal in goals! {
                                print(goal.goalType)
                                print(goal.activityCategoryLink)
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
            print("PASSWORD:   " + KeychainManager.sharedInstance.getYonaPassword()!)
            print("USER ID:   " + KeychainManager.sharedInstance.getUserID()!)

            APIServiceManager.sharedInstance.getActivityLinkForActivityName(.socialString) { (success, socialActivityCategoryLink, message, code) in
                if success {
                    //set body for budget social goal
                    let socialActivityCategoryLinkReturned = socialActivityCategoryLink
                    print("socialActivityCategoryLinkReturned: " + socialActivityCategoryLinkReturned!)
                    
                    let bodyTimeZoneSocialGoal: [String:AnyObject] = [
                        "@type": "TimeZoneGoal",
                        "_links": [
                            "yona:activityCategory": ["href": socialActivityCategoryLinkReturned!] 
                        ] ,
                        "zones": ["8:00-17:00", "20:00-22:00", "22:00-20:00"]
                    ]
                    APIServiceManager.sharedInstance.postUserGoals(bodyTimeZoneSocialGoal, onCompletion: {
                        (success, serverMessage, serverCode, goal, err) in
                        if success {
                            APIServiceManager.sharedInstance.getActivitiesArray{ (success, message, server, activities, error) in
                                if success {
                                    //Get the goals again to see if the goals have been updated after our post
                                    APIServiceManager.sharedInstance.getUserGoals(activities!){ (success, serverMessage, serverCode, goals, err) in
                                        print(goals)
                                        //we want to remove the news goal so find it
                                        for goal in goals! {
                                            //Now we Identify the goals by their activity category links
                                            if goal.activityCategoryLink == socialActivityCategoryLink {
                                                print(goal.activityCategoryLink)
                                                XCTAssertTrue(goal.activityCategoryLink == socialActivityCategoryLink, "Goal has been posted")
                                                expectation.fulfill()
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            XCTFail(serverMessage!)
                        }
                    })

                }
            }
        }

        waitForExpectationsWithTimeout(100.0, handler:nil)

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
            
            let newsActivityCategoryLink = "http://85.222.227.142/activityCategories/743738fd-052f-4532-a2a3-ba60dcb1adbf"
            let postGoalBody = [
                "@type": "BudgetGoal",
                "_links": [
                    "yona:activityCategory": ["href": newsActivityCategoryLink]
                ],
                "maxDurationMinutes": "30"
            ]

            APIServiceManager.sharedInstance.postUserGoals(postGoalBody, onCompletion: {
                (success, serverMessage, serverCode, goal, err) in
                APIServiceManager.sharedInstance.postUserGoals(postGoalBody, onCompletion: {
                    (success, serverMessage, serverCode, goal, err) in
                    //see what message from the server...in this case we are trying to remove a goal you are not allowed to remove
                    if let serverMessage = serverMessage {
                        XCTAssertTrue(serverMessage == "Cannot add second goal on activity category 'News'", serverMessage ?? "Unknown error")
                        expectation.fulfill()
                        print(serverMessage)
                    }
                })
            })
        }
        waitForExpectationsWithTimeout(10.0, handler:nil)
    }
    
    func testPostNewsGoalAsNoGo() {
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
            
            let newsActivityCategoryLink = "http://85.222.227.142/activityCategories/743738fd-052f-4532-a2a3-ba60dcb1adbf"
            let postGoalBody = [
                "@type": "BudgetGoal",
                "_links": [
                    "yona:activityCategory": ["href": newsActivityCategoryLink]
                ],
                "maxDurationMinutes": "0"
            ]
   
            APIServiceManager.sharedInstance.postUserGoals(postGoalBody, onCompletion: {
                (success, serverMessage, serverCode, goal, err) in
                APIServiceManager.sharedInstance.getGoalsOfType(.NoGoGoalString, onCompletion: { (success, message, server, goals, error) in
                    //see what message from the server...in this case we are trying to remove a goal you are not allowed to remove
                    if success {
                        for goal in goals! {
                            print(goal)
                            //if we find the News Goal we just posted as No Go then test passes
                            if goal.activityCategoryLink == newsActivityCategoryLink {
                                expectation.fulfill()
                            }
                        }
                    } else {
                        XCTFail(message!)
                    }
                })

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
            
            APIServiceManager.sharedInstance.getActivityLinkForActivityName(.gamblingString) { (success, gamblingActivityCategoryLink, message, code) in
                if success {
                    //the no go goal types are already there (I.e. gambling)
                    APIServiceManager.sharedInstance.getGoalsOfType(.NoGoGoalString) { (success, message, code, goals, error) in
                        for goal in goals! {
                            //so get this goal
                            if goal.goalType == GoalType.NoGoGoalString.rawValue {
                                //Now try to delete the Gambling goal, which we cannot error = "error.goal.cannot.add.second.on.activity.category"
                                APIServiceManager.sharedInstance.deleteUserGoal(goal.goalID!) { (success, serverMessage, serverCode) in
                                    if let serverCode = serverCode,
                                        let serverMessage = serverMessage{
                                        //we expect the server to say you cannot delete a mandatory goal like gambling
                                        XCTAssertTrue(serverCode == YonaConstants.serverCodes.cannotRemoveMandatoryGoal, serverMessage)
                                        expectation.fulfill()
                                    }
                                }
                            }
                        }

                    }

                    
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
                APIServiceManager.sharedInstance.getActivitiesArray{ (success, message, server, activities, error) in
                    if success {
                        APIServiceManager.sharedInstance.getUserGoals(activities!){ (success, serverMessage, serverCode, goals, err) in
                            if(success){
                                for goal in goals! {
                                    print("Goal ID Before" + goal.goalID!)

                                    APIServiceManager.sharedInstance.getUsersGoalWithID(goal.goalID!, onCompletion: { (success, serverMessage, serverCode, goalReturned, err) in
                                        print(goalReturned?.activityCategoryLink)
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
            
                    let newsActivityCategoryLink = "http://85.222.227.142/activityCategories/743738fd-052f-4532-a2a3-ba60dcb1adbf"
                    let postGoalBody = [
                        "@type": "BudgetGoal",
                        "_links": [
                            "yona:activityCategory": ["href": newsActivityCategoryLink]
                        ],
                        "maxDurationMinutes": "30"
                    ]
                    
                    APIServiceManager.sharedInstance.postUserGoals(postGoalBody) {
                        (success, serverMessage, serverCode, goal, err) in
                        if success {
                            //then once it is posted we can delete it
                            APIServiceManager.sharedInstance.deleteUserGoal(goal!.goalID!) { (success, serverMessage, serverCode) in
                                if success {
                                    expectation.fulfill()
                                } else {
                                    XCTFail(serverMessage!)
                                }
                            }
                        } else {
                            XCTFail(serverMessage!)
                        }
                    }
        }
        
        waitForExpectationsWithTimeout(100.0, handler:nil)
        
    }

}
