//
//  MessageAPIServiceTests.swift
//  Yona
//
//  Created by Ben Smith on 17/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//
import Foundation
import XCTest

@testable import Yona

class MessageAPIServiceTests: XCTestCase {
    
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
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    //this is a bit of a fake unit test and only works if the account with mobile number +31623434234234234 and user ID 8f548970-a9e0-46ec-9f0f-84249d60466d exists ....
    func testGetMessages() {
        let expectation = self.expectation(description: "Waiting to respond")
        
        let randomPhoneNumber = String(Int(arc4random_uniform(9999999)))
        let body =
            ["firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31999" + randomPhoneNumber,
             "nickname": "RQ"]
        
        UserRequestManager.sharedInstance.postUser(body, confirmCode: nil) { (success, servermessage, servercode, user) in
            print("PASSWORD:   " + KeychainManager.sharedInstance.getYonaPassword()!)
            print("USER ID:   " + KeychainManager.sharedInstance.getUserID()!)
            UserRequestManager.sharedInstance.confirmMobileNumber(["code":YonaConstants.testKeys.otpTestCode], onCompletion: { (success, servermessage, servercode) in
                
                let postBuddyBody: [String:AnyObject] = [
                    postBuddyBodyKeys.sendingStatus.rawValue: buddyRequestStatus.REQUESTED.rawValue,
                    postBuddyBodyKeys.receivingStatus.rawValue: buddyRequestStatus.REQUESTED.rawValue,
                    postBuddyBodyKeys.message.rawValue: "Hi there, would you want to become my buddy?",
                    postBuddyBodyKeys.embedded.rawValue: [
                        postBuddyBodyKeys.yonaUser.rawValue: [
                            addUserKeys.emailAddress.rawValue: "richard@quin.net",
                            addUserKeys.firstNameKey.rawValue: "Richard",
                            addUserKeys.lastNameKeys.rawValue: "Quin",
                            addUserKeys.mobileNumberKeys.rawValue: "+31623434234234234" //this is the number of the person you are adding as a buddy
                        ]
                    ]
                ]
                
                BuddyRequestManager.sharedInstance.requestNewbuddy(postBuddyBody, onCompletion: { (success, servermessage, servercode, buddy, buddies) in
                    XCTAssert(success, servermessage!)
                    if success {
                            //faking the path and password to see what messages the user with +31623434234234234 number has, they should have one message
                            let path = "users/8f548970-a9e0-46ec-9f0f-84249d60466d/messages/" + "?size=" + "10" + "&page=" + "0"
                            KeychainManager.sharedInstance.setPassword("1234")
                            //fake call to get messages going directly into the API
                            //Normally you would call:
                            //    func getMessages(size: Int, page: Int, onCompletion: APIMessageResponse)
                            //To get the messages for the current user, but in this unit test we have to force the password and user ID to be one we know to test we get messages
                            APIServiceManager.sharedInstance.callRequestWithAPIServiceResponse(nil, path: path, httpMethod: .get) { success, json, error in
                                if let json = json {
                                    if let embedded = json[getMessagesKeys.embedded.rawValue] as? BodyDataDictionary,
                                        let yonaMessages = embedded[getMessagesKeys.yonaMessages.rawValue] as? NSArray{
                                        var messages = [Message]()
                                        //iterate messages
                                        for message in yonaMessages {
                                            if let message = message as? BodyDataDictionary {
                                                let message = Message.init(messageData: message)
                                                messages.append(message)
                                            }
                                        }
                                        XCTAssert(messages.count > 0)
                                        expectation.fulfill()
                                    } else {
                                        XCTAssert(success, (error?.localizedDescription)!)
                                    }
                                } else {
                                    XCTAssert(success, (error?.localizedDescription)!)
                                }
                            }
                    } else {
                        XCTAssert(success, servermessage!)
                    }
                })
            })
        }
        waitForExpectations(timeout: 100.0, handler:nil)
    }
}
