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
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testGetGoalsOfTypeNoGo(){
        //setup
        let expectation = self.expectation(description: "Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999))
        
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]
        
        //Get user goals
        UserRequestManager.sharedInstance.postUser(body, confirmCode: nil) { (success, message, code, users) in
            if success == false{
                XCTFail()
            }
            //confirm mobile number check, static code
            UserRequestManager.sharedInstance.confirmMobileNumber(["code":YonaConstants.testKeys.otpTestCode]) { success, message, code in
                if(success){
                    ActivitiesRequestManager.sharedInstance.getActivitiesNotAddedWithTheUsersGoals{ (success, message, code, activities, goals, error) in
                        if let goalsUnwrap = goals {
                            if success {
                                let nogoGoals = GoalsRequestManager.sharedInstance.sortGoalsIntoArray(.NoGoGoalString, goals: goalsUnwrap)
                                XCTAssert(nogoGoals.count > 0 , message!) //if we don't get one nogo goal back
                                expectation.fulfill()
                            } else {
                                XCTFail(message!)
                            }
                        }
                    }
                }
            }


        }
        waitForExpectations(timeout: 10.0, handler:nil)
        
    }
    
    func testGetGoalsOfTypeBudgetGoal(){
        //setup
        let expectation = self.expectation(description: "Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999))
        
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]

        //Get user goals
        UserRequestManager.sharedInstance.postUser(body, confirmCode: nil) { (success, message, code, users) in
            if success == false{
                XCTFail()
            }
            //confirm mobile number check, static code
            UserRequestManager.sharedInstance.confirmMobileNumber(["code":YonaConstants.testKeys.otpTestCode]) { success, message, code in
                if(success){
                    UserRequestManager.sharedInstance.getUser(.allowed) { (success, message, code, user) in
                        //we need to now get the activity link from our activities
                        ActivitiesRequestManager.sharedInstance.getActivityLinkForActivityName(.socialString) { (success, socialActivityCategoryLink, message, code) in
                        //set body for goal
                        let bodyBudgetSocialGoal: [String: AnyObject] = [
                            "@type": "BudgetGoal",
                            "_links": ["yona:activityCategory":
                                ["href": socialActivityCategoryLink!]
                            ],
                            "maxDurationMinutes": "10"
                        ]
                            //now we can post the goal
                            GoalsRequestManager.sharedInstance.postUserGoals(bodyBudgetSocialGoal) { (success, message, code, goal, goals, error) in
                                if success {
                                    ActivitiesRequestManager.sharedInstance.getActivityLinkForActivityName(.newsString) { (success, newsActivityCategoryLink, message, code) in
                                        let bodyBudgetNewsGoal: [String: AnyObject] = [
                                            "@type": "BudgetGoal",
                                            "_links": [
                                                "yona:activityCategory": ["href": newsActivityCategoryLink!]
                                            ],
                                            "maxDurationMinutes": "30"
                                        ]
                                        
                                        //now we can post the goal
                                        GoalsRequestManager.sharedInstance.postUserGoals(bodyBudgetNewsGoal) { (success, message, code, goal, nil, error) in
                                                if success {
                                                    ActivitiesRequestManager.sharedInstance.getActivitiesNotAddedWithTheUsersGoals{ (success, message, code, activities, goals, error) in
                                                        if let goalsUnwrap = goals {
                                                            if success {
                                                                let budgetGoals = GoalsRequestManager.sharedInstance.sortGoalsIntoArray(.BudgetGoalString, goals: goalsUnwrap)
                                                                XCTAssert(budgetGoals.count == 2 , message!) //there should be 2 goals returned              
                                                                expectation.fulfill()
                                                            } else {
                                                                XCTFail(message!)
                                                            }
                                                        }
                                                    }
                                                } else {
                                                    XCTFail(message!)
                                                }
                                            }
                                        }
                                } else {
                                    XCTFail(message!)
                                }
                            }
                        }
                    }
                } else {
                    XCTFail(message!)
                }
            }
        }
        waitForExpectations(timeout: 10.0, handler:nil)

    }
    
    func testGetGoalsOfTypeTimeZone(){
        //setup
        let expectation = self.expectation(description: "Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999))

        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]
        //Get user goals
        UserRequestManager.sharedInstance.postUser(body, confirmCode: nil) { (success, message, code, users) in
            if success == false{
                XCTFail()
            }
            //confirm mobile number check, static code
            UserRequestManager.sharedInstance.confirmMobileNumber(["code":YonaConstants.testKeys.otpTestCode]) { success, message, code in
                if(success){
                    //we need to now get the activity link from our activities
                    ActivitiesRequestManager.sharedInstance.getActivityLinkForActivityName(.socialString, onCompletion: { (success, socialActivityCategoryLink, message, code) in
                            //set body for budget social goal
                            let bodyTimeZoneSocialGoal: [String: AnyObject] = [
                                "@type": "TimeZoneGoal",
                                "_links": [
                                    "yona:activityCategory": ["href": socialActivityCategoryLink!]
                                ],
                                "zones": ["8:00-17:00", "20:00-22:00", "22:00-20:00"]
                            ]
                        ActivitiesRequestManager.sharedInstance.getActivityLinkForActivityName(.newsString, onCompletion: { (success, newsActivityCategoryLink, message, code) in
                                //set body for goal
                                let bodyTimeZoneNewsGoal: [String: AnyObject] = [
                                    "@type": "TimeZoneGoal",
                                    "_links": [
                                        "yona:activityCategory": ["href": newsActivityCategoryLink!]
                                    ],
                                    "zones": ["8:00-17:00", "20:00-22:00"]
                                ]
                            
                                //add budget goal
                                GoalsRequestManager.sharedInstance.postUserGoals(bodyTimeZoneSocialGoal, onCompletion: { (success, message, code, goal, nil, error) in
                                    if success {

                                        GoalsRequestManager.sharedInstance.postUserGoals(bodyTimeZoneNewsGoal, onCompletion: { (success, message, code, goal, nil, error) in
                                            if success {
                                                //now we can call getActivitiesNotAddedWithTheUsersGoals in Activtities request manager, this will return the UI the activties not yet added to display in a list, along with the users goals (that is part of getting activities not added) meaning the UI does not have to call the get goals part at all reducing the calls to it
                                                ActivitiesRequestManager.sharedInstance.getActivitiesNotAddedWithTheUsersGoals{ (success, message, code, activities, goals, error) in
                                                    if let goalsUnwrap = goals {
                                                        if success {
                                                            let timeZoneGoals = GoalsRequestManager.sharedInstance.sortGoalsIntoArray(.TimeZoneGoalString, goals: goalsUnwrap)
                                                            XCTAssert(timeZoneGoals.count == 2 , message!) //there should be 2 goals returned
                                                            expectation.fulfill()
                                                        } else {
                                                            XCTFail(message!)
                                                        }
                                                    }
                                                }
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
            }
        }
        waitForExpectations(timeout: 100.0, handler:nil)
        
    }
    
    func testGetUserGoal(){
        //setup
        let expectation = self.expectation(description: "Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999))
        
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]
        //Create user
        UserRequestManager.sharedInstance.postUser(body, confirmCode: nil) { (success, message, code, users) in
            if success == false{
                XCTFail()
            }
            print("PASSWORD:" + KeychainManager.sharedInstance.getYonaPassword()!)
            //confirm mobile number check, static code
            UserRequestManager.sharedInstance.confirmMobileNumber(["code":YonaConstants.testKeys.otpTestCode]) { success, message, code in
                if(success){
                    ActivitiesRequestManager.sharedInstance.getActivityCategories{ (success, message, server, activities, error) in
                        if success {
                            //Get all the goals
                            GoalsRequestManager.sharedInstance.getAllTheGoals(activities!){ (success, serverMessage, serverCode, nil, goals, err) in
                                if(success){
                                    for goal in goals! {
                                        print(goal.goalType)
                                        print(goal.activityCategoryLink)
                                        //delete user goals
                                        GoalsRequestManager.sharedInstance.deleteUserGoal(goal.goalID!, onCompletion: { (success, serverMessage, serverCode) in
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
            }
        }
        waitForExpectations(timeout: 10.0, handler:nil)
        
    }
    
    func testUpdateUserGoal(){
        //setup
        let expectation = self.expectation(description: "Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999)) //phone number mustbe unique
        
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]
        
        //Create user
        //Create user
        UserRequestManager.sharedInstance.postUser(body, confirmCode: nil) { (success, message, code, users) in
            if success == false{
                XCTFail()
            }
            print("PASSWORD:   " + KeychainManager.sharedInstance.getYonaPassword()!)
            print("USER ID:   " + KeychainManager.sharedInstance.getUserID()!)
            //confirm mobile number check, static code
            UserRequestManager.sharedInstance.confirmMobileNumber(["code":YonaConstants.testKeys.otpTestCode]) { success, message, code in
                if(success){
                    ActivitiesRequestManager.sharedInstance.getActivityLinkForActivityName(.socialString) { (success, socialActivityCategoryLink, message, code) in
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
                            GoalsRequestManager.sharedInstance.postUserGoals(bodyTimeZoneSocialGoal, onCompletion: {
                                (success, serverMessage, serverCode, goal, nil, err) in
                                if success {
                                    let newBodyTimeZoneSocialGoal: [String:AnyObject] = [
                                        "@type": "TimeZoneGoal",
                                        "_links": [
                                            "yona:activityCategory": ["href": socialActivityCategoryLinkReturned!]
                                        ] ,
                                        "zones": ["8:00-17:00"]
                                    ]
                                    GoalsRequestManager.sharedInstance.updateUserGoal(goal?.editLinks, body: newBodyTimeZoneSocialGoal) { (success, message, server, goal, goals, error) in
                                        if success {
                                            expectation.fulfill()
                                        }
                                    }
                                } else {
                                    XCTFail(serverMessage!)
                                }
                            })
                            
                        }
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 100.0, handler:nil)
        
    }
    
    func testPostUserGoal(){
        //setup
        let expectation = self.expectation(description: "Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999)) //phone number mustbe unique
        
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]
        
        //Create user
        UserRequestManager.sharedInstance.postUser(body, confirmCode: nil) { (success, message, code, users) in
            if success == false{
                XCTFail()
            }
            print("PASSWORD:   " + KeychainManager.sharedInstance.getYonaPassword()!)
            print("USER ID:   " + KeychainManager.sharedInstance.getUserID()!)
            //confirm mobile number check, static code
            UserRequestManager.sharedInstance.confirmMobileNumber(["code":YonaConstants.testKeys.otpTestCode]) { success, message, code in
                if(success){
                    ActivitiesRequestManager.sharedInstance.getActivityLinkForActivityName(.socialString) { (success, socialActivityCategoryLink, message, code) in
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
                            GoalsRequestManager.sharedInstance.postUserGoals(bodyTimeZoneSocialGoal, onCompletion: {
                                (success, serverMessage, serverCode, goal, nil, err) in
                                if success {
                                    ActivitiesRequestManager.sharedInstance.getActivityCategories{ (success, message, server, activities, error) in
                                        if success {
                                            //Get the goals again to see if the goals have been updated after our post
                                            GoalsRequestManager.sharedInstance.getAllTheGoals(activities!){ (success, serverMessage, serverCode, nil, goals, err) in
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
            }
        }

        waitForExpectations(timeout: 100.0, handler:nil)

    }
    
    func testPostSameGoalTwiceCheckCorrectServerResponse() {
        //setup
        let expectation = self.expectation(description: "Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999)) //phone number mustbe unique
        
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]

        //Create user
        UserRequestManager.sharedInstance.postUser(body, confirmCode: nil) { (success, message, code, users) in
            if success == false{
                XCTFail()
            }
            //confirm mobile number check, static code
            UserRequestManager.sharedInstance.confirmMobileNumber(["code":YonaConstants.testKeys.otpTestCode]) { success, message, code in
                if(success){
                    print(KeychainManager.sharedInstance.getYonaPassword())
                    
                    let newsActivityCategoryLink = "http://85.222.227.142/activityCategories/743738fd-052f-4532-a2a3-ba60dcb1adbf"
                    let postGoalBody = [
                        "@type": "BudgetGoal",
                        "_links": [
                            "yona:activityCategory": ["href": newsActivityCategoryLink]
                        ],
                        "maxDurationMinutes": "30"
                    ]

                    GoalsRequestManager.sharedInstance.postUserGoals(postGoalBody, onCompletion: {
                        (success, serverMessage, serverCode, goal, nil, err) in
                        GoalsRequestManager.sharedInstance.postUserGoals(postGoalBody, onCompletion: {
                            (success, serverMessage, serverCode, goal, nil, err) in
                            //see what message from the server...in this case we are trying to remove a goal you are not allowed to remove
                            if let serverMessage = serverMessage {
                                XCTAssertTrue(serverMessage == "Cannot add second goal on activity category 'News'", serverMessage ?? "Unknown error")
                                expectation.fulfill()
                                print(serverMessage)
                            }
                        })
                    })
                }
            }
        }
        waitForExpectations(timeout: 10.0, handler:nil)
    }
    
    func testPostNewsGoalAsNoGo() {
        //setup
        let expectation = self.expectation(description: "Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999)) //phone number mustbe unique
        
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]
        
        //Create user
        UserRequestManager.sharedInstance.postUser(body, confirmCode: nil) { (success, message, code, users) in
            if success == false{
                XCTFail()
            }
            //confirm mobile number check, static code
            UserRequestManager.sharedInstance.confirmMobileNumber(["code":YonaConstants.testKeys.otpTestCode]) { success, message, code in
                if(success){
                    print(KeychainManager.sharedInstance.getYonaPassword())
                    
                    let newsActivityCategoryLink = "http://85.222.227.142/activityCategories/743738fd-052f-4532-a2a3-ba60dcb1adbf"
                    let postGoalBody = [
                        "@type": "BudgetGoal",
                        "_links": [
                            "yona:activityCategory": ["href": newsActivityCategoryLink]
                        ],
                        "maxDurationMinutes": "0"
                    ]
           
                    GoalsRequestManager.sharedInstance.postUserGoals(postGoalBody, onCompletion: {
                        (success, serverMessage, serverCode, goal, goals, err) in
                        ActivitiesRequestManager.sharedInstance.getActivitiesNotAddedWithTheUsersGoals{ (success, message, server, nil, goals, error) in
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
                        }

                    })
                }
            }
        }
        waitForExpectations(timeout: 10.0, handler:nil)
    }
    
    func testDeleteAMandatoryGoal() {
        //setup
        let expectation = self.expectation(description: "Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999)) //phone number mustbe unique
        
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]
        //Create user
        UserRequestManager.sharedInstance.postUser(body, confirmCode: nil) { (success, message, code, users) in
            if success == false{
                XCTFail()
            }
            //confirm mobile number check, static code
            UserRequestManager.sharedInstance.confirmMobileNumber(["code":YonaConstants.testKeys.otpTestCode]) { success, message, code in
                if(success){
                    print(KeychainManager.sharedInstance.getYonaPassword())
                    print(KeychainManager.sharedInstance.getUserID())
                    
                    ActivitiesRequestManager.sharedInstance.getActivityLinkForActivityName(.gamblingString) { (success, gamblingActivityCategoryLink, message, code) in
                        if success {
                            //As the user has just been created there is one mandatory goal, Gambling, this has no editlink so cannot be removed
                            ActivitiesRequestManager.sharedInstance.getActivitiesNotAddedWithTheUsersGoals { (success, message, code, nil, goals, error) in
                                for goal in goals! {
                                    //so get this goal
                                    if goal.goalType == GoalType.NoGoGoalString.rawValue {
                                        //Now try to delete the Gambling goal, which we cannot error = "error.goal.cannot.add.second.on.activity.category"
                                        if let _ = goal.editLinks {
                                            XCTFail("Gambling should not have an editlink, therefore this test has failed and Bert needs to fix it, probably")
                                        } else {
                                            expectation.fulfill()
                                        }
                                    }
                                }

                            }

                            
                        }
                    }
                }
            }
        }

        waitForExpectations(timeout: 100.0, handler:nil)
        
    }
    
    
    func testGetGoalWithID() {
        //setup
        let expectation = self.expectation(description: "Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999)) //phone number mustbe unique
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]
        //Create user
        UserRequestManager.sharedInstance.postUser(body, confirmCode: nil) { (success, message, code, users) in
            if success {
                //confirm mobile number check, static code
                UserRequestManager.sharedInstance.confirmMobileNumber(["code":YonaConstants.testKeys.otpTestCode]) { success, message, code in
                    if(success){
                        ActivitiesRequestManager.sharedInstance.getActivityCategories{ (success, message, server, activities, error) in
                            if success {
                                GoalsRequestManager.sharedInstance.getAllTheGoals(activities!){ (success, serverMessage, serverCode, nil, goals, err) in
                                    if(success){
                                        for goal in goals! {
                                            print("Goal ID Before" + goal.goalID!)

                                            GoalsRequestManager.sharedInstance.getUsersGoalWithSelfLinkID(goal.selfLinks!, onCompletion: { (success, serverMessage, serverCode, goalReturned, nil, err) in
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
                    }
                }
            } else {
                if let messageUnwrapped = message{
                    XCTFail(messageUnwrapped ?? "Unknown error")
                }
            }
        }
        waitForExpectations(timeout: 10.0, handler:nil)

    }
    
    func testDeleteGoal() {
        //setup
        let expectation = self.expectation(description: "Waiting to respond")
        let randomPhoneNumber = Int(arc4random_uniform(9999999)) //phone number mustbe unique
        
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31343" + String(randomPhoneNumber),
             "nickname": "RQ"]
        //Create user
        UserRequestManager.sharedInstance.postUser(body, confirmCode: nil) { (success, message, code, users) in
            if success == false{
                XCTFail()
            }
            //confirm mobile number check, static code
            UserRequestManager.sharedInstance.confirmMobileNumber(["code":YonaConstants.testKeys.otpTestCode]) { success, message, code in
                if(success){
                    let newsActivityCategoryLink = "http://85.222.227.142/activityCategories/743738fd-052f-4532-a2a3-ba60dcb1adbf"
                    let postGoalBody = [
                        "@type": "BudgetGoal",
                        "_links": [
                            "yona:activityCategory": ["href": newsActivityCategoryLink]
                        ],
                        "maxDurationMinutes": "30"
                    ]
                    
                    GoalsRequestManager.sharedInstance.postUserGoals(postGoalBody) {
                        (success, serverMessage, serverCode, goal, nil, err) in
                        if success {
                            //then once it is posted we can delete it
                            GoalsRequestManager.sharedInstance.deleteUserGoal(goal!.editLinks!) { (success, serverMessage, serverCode) in
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
            }
        }
        
        waitForExpectations(timeout: 100.0, handler:nil)
        
    }

}
