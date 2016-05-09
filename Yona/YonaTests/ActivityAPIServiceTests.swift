//
//  ActivityAPIServiceTests.swift
//  Yona
//
//  Created by Ben Smith on 13/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import XCTest
@testable import Yona

class ActivityAPIServiceTests: XCTestCase {

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
    
    func testGetActivitiesNotAddedAfterAddingNoGoalsOtherThanMandatoryOne() {
        //setup
        let expectation = expectationWithDescription("Waiting to respond")
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
                if success {
                    ActivitiesRequestManager.sharedInstance.getActivitiesNotAdded({ (success, message, code, activities, error) in
                        if success{
                            //we added a social and there is always a gambling goal so only one goal should be passed back
                            for activity in activities! {
                                print(activity.activityCategoryName)
                            }
                            expectation.fulfill()
                        }
                    })
                } else {
                    XCTFail(message!)
                }
            }
        }
        waitForExpectationsWithTimeout(10.0, handler:nil)
    }
    
    func testGetActivitiesNotAddedArrayMethodAfterAddingSocial() {
        //setup
        let expectation = expectationWithDescription("Waiting to respond")
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
                            GoalsRequestManager.sharedInstance.postUserGoals(bodyTimeZoneSocialGoal) {
                                (success, serverMessage, serverCode, goal, nil, err) in
                                if success {
                                    ActivitiesRequestManager.sharedInstance.getActivitiesNotAdded({ (success, message, code, activities, error) in
                                        if success{
                                            //we added a social and there is always a gambling goal so only one goal should be passed back
                                            for activity in activities! {
                                                print(activity.activityCategoryName)
                                            }
                                            expectation.fulfill()
                                        }
                                    })
                                } else {
                                    XCTFail(serverMessage!)
                                }
                            }
                            
                        }
                    }
                }
            }
        }
        waitForExpectationsWithTimeout(10.0, handler:nil)
    }

    
    func testGetActivityCategories() {
        //setup
        let expectation = expectationWithDescription("Waiting to respond")
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
                    ActivitiesRequestManager.sharedInstance.getActivityCategories{ (success, serverMessage, serverCode, activities, err) in
                        if success{
                            for activity in activities! {
                                print(activity.activityCategoryName)
                            }
                            expectation.fulfill()
                        }
                    }
                }
            }
        }
        waitForExpectationsWithTimeout(10.0, handler:nil)
    }
    
    func testGetActivityCategoryWithID() {
        
        //setup
        let expectation = expectationWithDescription("Waiting to respond")
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
                    ActivitiesRequestManager.sharedInstance.getActivityCategories{ (success, serverMessage, serverCode, activities, err) in
                        if success {
                            let activity = activities![0]
                            print(activity)

                            ActivitiesRequestManager.sharedInstance.getActivityCategoryWithID(activity.activityID!, onCompletion: { (success, serverMessage, serverCode, activity, err) in
                                if success{
                                    print(activity)
                                    expectation.fulfill()
                                }
                            })
                        }
                    }
                }
            }
        }

        waitForExpectationsWithTimeout(10.0, handler:nil)
    }
    
    func testGetActivitiesArray() {
        //setup
        let expectation = expectationWithDescription("Waiting to respond")
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
                    ActivitiesRequestManager.sharedInstance.getActivitiesArray({ (success, message, code, activities, error) in
                        print(activities)
                        XCTAssertTrue(success, "Received Activities")
                        expectation.fulfill()
                    })
                }
            }
        }
        waitForExpectationsWithTimeout(10.0, handler:nil)

    }
    //    func getActivityLinkForActivityName(activityName: YonaConstants.CategoryName, onCompletion: APIActivityLinkResponse) {

    func testGetActivityLinkForSocialActivityName() {
        let socialActivityCategoryLink = "http://85.222.227.142/activityCategories/27395d17-7022-4f71-9daf-f431ff4f11e8" // hard code this for now for test
        let expectation = expectationWithDescription("Waiting to respond")
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
                    ActivitiesRequestManager.sharedInstance.getActivityLinkForActivityName(.socialString) { (success, activityID, message, code) in
                        if success{
                            XCTAssertTrue(socialActivityCategoryLink == activityID, "Correct Activity ID for Social received")
                            expectation.fulfill()
                        } else {
                            XCTFail(message!)
                        }
                    }
                }
            }
        }
        

        waitForExpectationsWithTimeout(10.0, handler:nil)
    }
}
