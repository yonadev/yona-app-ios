//
//  BuddyRequestManager.swift
//  Yona
//
//  Created by Ben Smith on 11/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class BuddyRequestManager {
    let APIService = APIServiceManager.sharedInstance
    let APIUserRequestManager = UserRequestManager.sharedInstance
    static let sharedInstance = BuddyRequestManager()
    var buddy: Buddies?
    var buddies: [Buddies] = []
    private init() {}

    
    private func genericBuddyRequest(httpMethod: httpMethods, buddyBody: BodyDataDictionary?, buddy: Buddies?, onCompletion: APIBuddiesResponse) {
        UserRequestManager.sharedInstance.getUser(GetUserRequest.notAllowed){ (success, serverMessage, serverCode, user) in
            switch httpMethod {
            case .get:
                if let buddieLink = user?.buddiesLink {
                    ActivitiesRequestManager.sharedInstance.getActivityCategories{ (success, message, serverCode, activities, error) in
                        if success {
                            self.APIService.callRequestWithAPIServiceResponse(nil, path: buddieLink, httpMethod: httpMethod) { (success, json, error) in
                                if success {
                                    self.buddies.removeAll()
                                    if let json = json {
                                        if let embedded = json[postBuddyBodyKeys.embedded.rawValue],
                                            let yonaBuddies = embedded[postBuddyBodyKeys.yonaBuddies.rawValue] as? NSArray{
                                            //iterate messages
                                            for buddy in yonaBuddies {
                                                if let buddy = buddy as? BodyDataDictionary {
                                                    self.buddy = Buddies.init(buddyData: buddy, allActivity: activities!)
                                                    
                                                    if let buddy = self.buddy {
                                                        if buddy.UserRequestmobileNumber.characters.count > 0 {
                                                            self.buddies.append(buddy)
                                                        }
                                                    }
                                                }
                                            }
                                            onCompletion(success, serverMessage, serverCode, nil, self.buddies)
                                        } else { //we just get a buddy response back
                                            self.buddy = Buddies.init(buddyData: json, allActivity: activities!)
                                            onCompletion(success, serverMessage, serverCode, self.buddy, nil)
                                        }
                                    } else {
                                        onCompletion(success, serverMessage, serverCode, nil, nil) //failed json response
                                    }
                                } else {
                                    onCompletion(success, serverMessage, serverCode, nil, nil)
                                }
                            }
                        }
                    }
                        
                } else {
                    onCompletion(false, YonaConstants.YonaErrorTypes.GetBuddyLinkFail.localizedDescription, self.APIService.determineErrorCode(YonaConstants.YonaErrorTypes.GetBuddyLinkFail), nil, nil)
                }
                break
            case .post:
                if let buddieLink = user?.buddiesLink {
                    self.APIService.callRequestWithAPIServiceResponse(buddyBody, path: buddieLink, httpMethod: httpMethod) { (success, json, error) in
                        if success {
                            if let json = json {
                                self.buddy = Buddies.init(buddyData: json, allActivity: [])
                                onCompletion(success, serverMessage, serverCode, self.buddy, nil) //failed to get user
                            } else {
                                onCompletion(success, serverMessage, serverCode, nil, nil) //failed json response
                            }
                        } else {
                            onCompletion(success, serverMessage, serverCode, nil, nil)
                        }
                    }
                } else {
                    onCompletion(false, YonaConstants.YonaErrorTypes.GetBuddyLinkFail.localizedDescription, self.APIService.determineErrorCode(YonaConstants.YonaErrorTypes.GetBuddyLinkFail), nil, nil)
                }
                break
            case .put:

                break
            case .delete:
                if let editBuddyLink = buddy?.editLink {
                    self.APIService.callRequestWithAPIServiceResponse(nil, path: editBuddyLink, httpMethod: httpMethod) { (success, json, error) in
                        onCompletion(success, serverMessage, serverCode, nil, nil)
                    }
                } else {
                    onCompletion(false, YonaConstants.YonaErrorTypes.GetBuddyLinkFail.localizedDescription, self.APIService.determineErrorCode(YonaConstants.YonaErrorTypes.GetBuddyLinkFail), nil, nil)
                }
                break
            }
        }
    }
    
    func requestNewbuddy(buddyBody: BodyDataDictionary, onCompletion: APIBuddiesResponse) {
        self.genericBuddyRequest(httpMethods.post, buddyBody: buddyBody, buddy: nil, onCompletion: onCompletion)
    }
    
    func getAllbuddies(onCompletion: APIBuddiesResponse) {
        self.genericBuddyRequest(httpMethods.get, buddyBody: nil, buddy: nil, onCompletion: onCompletion)
    }
    
    func deleteBuddy(buddy: Buddies?, onCompletion: APIBuddiesResponse) {
        self.genericBuddyRequest(httpMethods.delete, buddyBody: nil, buddy: buddy, onCompletion: onCompletion)
    }

}